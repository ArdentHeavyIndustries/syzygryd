package com.syzygryd;

import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

public class ActionRunner extends Thread {
	
	private static int SECOND_IN_MILLIS = 1000;
	private static int LOAD_TIMEOUT = 60 * SECOND_IN_MILLIS;	// XXX REVISIT (was 10 minutes)
	private static int ARBITRARY_SLEEP_BETWEEN_SETS = 3 * SECOND_IN_MILLIS;
	private static int STOP_TIMEOUT = 10 * SECOND_IN_MILLIS;
	private static int INTERVAL_BETWEEN_DURATION_NOTIFICATIONS = 5 * SECOND_IN_MILLIS;
	
	private boolean running = false;
	
   // XXX this is stupid now that there's just one, we should get rid of the array and just use a single OSCSender
	private OSCSender[] statusRecipients = null;
	
	private ConcurrentLinkedQueue<Action> actionQ = new ConcurrentLinkedQueue<Action>();
	
	/**
	 * action to be immediately executed; preempts queue
	 */
	private AtomicReference<Action> pendingAction = new AtomicReference<Action>();
	private Action currentAction = null;
	
	/**
	 * blocks until load has finished
	 */
	private CountDownLatch loadPending;
	
	/**
	 * blocks until action has completed or is interrupted by a new, immediate action
	 */
	private CountDownLatch actionRunning;
	
	/**
	 * blocks until action has ended
	 */
	private CountDownLatch endPending;
	
	public ActionRunner() {
		initLocks();
	}
	
	/**
	 * resets locks
	 */
	private void initLocks() {
		loadPending = new CountDownLatch(1);
		actionRunning = new CountDownLatch(1);
		endPending = new CountDownLatch(1);
	}
	
	@Override
	public void run() {

      Logger.info("Before infinite loop in ActionRunner.run()");
		while (true) {  // don't stop til you get enough
         Logger.debug("Beginning of loop in ActionRunner.run()");
         try {
			// determine next action in this order:
			
			// 1. existing pending action (which would have been set via actNow())
			currentAction = popPendingAction();
         Logger.debug("Popped pending action, if applicable: " + (currentAction == null ? null : currentAction.toString()));
			
			// 2. action at head of queue
			if (currentAction == null) {
				currentAction = getHead(); // try the salmon.  tip your waitron.
            Logger.debug("Getting action at the head of the queue, if applicable: " + (currentAction == null ? null : currentAction.toString()));
			}
			
			// 3. play next track
			if (currentAction == null) {
				currentAction = ActionFactory.createAction(Action.ActionType.playnext, null);
            Logger.debug("Default fallthrough creating new action: " + (currentAction == null ? null : currentAction.toString()));
			}
			
			// attempt to start.  if it succeeds, perform load
         Logger.debug("Starting action: " + (currentAction == null ? null : currentAction.toString()));
         // for the common case of opening a new set,
         // currentAction.start() actually executes the open command
         // on the *.als file, which will start live if needed, and
         // load the set.
			if (currentAction.start()) {
            Logger.debug("Action start returned true: " + (currentAction == null ? null : currentAction.toString()));
				setRunning(true);
				boolean loaded = true;
				int duration = currentAction.getDuration();
				int remaining = duration;
				// first wait for the action to load if necessary
				// NB, dude: loading must finish (or be cleanly canceled) before you try to load another action
				if (currentAction.requiresLoad()) {
               Logger.debug("Action requires load: " + (currentAction == null ? null : currentAction.toString()));
					loaded = false;
					Logger.info("Waiting (up to " + LOAD_TIMEOUT + " ms) for load...");
					try {
						loaded = loadPending.await(LOAD_TIMEOUT, TimeUnit.MILLISECONDS);
					} catch (InterruptedException ie) {
						// NIL;
					}
				} else {
               Logger.warn("Action does not require load.  I didn't think that could happen: " + (currentAction == null ? null : currentAction.toString()));
            }

            // XXX resume here
				if (loaded) {
               Logger.info("Done loading");
					// action is now running; wait until it's done or someone interrupts us
					Logger.info("Playing for up to " + remaining + " ms ...");
					boolean interrupted = false;
					while(remaining > 0 && !interrupted) {
						int sleepDuration = Math.min(INTERVAL_BETWEEN_DURATION_NOTIFICATIONS, remaining);
						sendTimeRemainingMessage(remaining, currentAction.getId(), currentAction.getLightingProgram() );
						try {
							interrupted = actionRunning.await(sleepDuration, TimeUnit.MILLISECONDS);
						} catch (InterruptedException ie) {
							// NIL;
						}
						remaining -= INTERVAL_BETWEEN_DURATION_NOTIFICATIONS;
					}
					sendTimeRemainingMessage(0, currentAction.getId(), currentAction.getLightingProgram());
               if (interrupted) {
                  Logger.info("Set was prematurely interrupted");
               } else {
                  Logger.debug("Set played to completion");
               }
				} else {
               Logger.warn("Done waiting " + LOAD_TIMEOUT + " ms, but load did not occur");
            }
				setRunning(false);
				Logger.info("Stopping...");
            // this stops playing in live
				currentAction.stop();
            // really waiting for live to stop
            boolean ended = false;
            // XXX renamed quit to stop, b/c it doesn't quit
            Logger.debug("Waiting (up to " + STOP_TIMEOUT + " ms) for stop...");
				try {
					ended = endPending.await(STOP_TIMEOUT, TimeUnit.MILLISECONDS);
				} catch (InterruptedException ie) {
					// NOP
				}
            if (ended) {
               Logger.info("Stopped.");
            } else {
               Logger.warn("Done waiting " + STOP_TIMEOUT + " ms, but stop did not occur");
               // XXX should we kill live now?
            }

            Logger.info("Waiting " + ARBITRARY_SLEEP_BETWEEN_SETS + " ms between sets");
				try {
					Thread.sleep(ARBITRARY_SLEEP_BETWEEN_SETS);
				} catch (InterruptedException ie) {
					// NOP
				}
            Logger.debug("Done waiting");

			} else {
            Logger.warn("Action start returned false: " + (currentAction == null ? null : currentAction.toString()));
            // XXX should we kill live if this happens ?
         }
			
			// reset locks
			initLocks();
         } catch (Exception e) {
            Logger.warn("Caught exception in ActionRunner run loop", e);
            // XXX now what?
         }
         Logger.debug("End of loop in ActionRunner.run()");
		}
	}
	
	/**
	 * make action happen right now
	 * @param a action to perform
	 */
	public synchronized void actNow(Action a) {
		setPendingAction(a);
		// countdown latch will pass right through, causing it to immediately stop
      Logger.debug("counting down action running");
		actionRunning.countDown();
	}
	
	/**
	 * called after an action that required loading
	 * has completed loading 
	 */
	public void actionLoaded() {
      Logger.debug("counting down load pending");
		loadPending.countDown();
	}
	
	/**
	 * called after an action that requires shutdown 
	 * has finished shutting down
	 */
	public void actionEnded() {
      Logger.debug("counting down end pending");
		endPending.countDown();
	}
	
	/**
	 * adds an action to the queue to do now or later.
	 * if 'q' is false, interrupts current action & does
	 * the specified action.
	 * 
	 * if 'q' is true, adds to the end of the current list of
	 * queued actions
	 * @param q true if it should be queued
	 * @param a action to perform
	 */
	public void injectAction(boolean q, Action a) {
		if (q) {
			queue(a);
		} else {
			actNow(a);
		}
	}
	
	/**
	 * atomically queues up an action
	 * @param a action to queue
	 */
	public synchronized void queue(Action a) {
		actionQ.add(a);
	}
	
	/**
	 * atomically remove front of queue
	 * @return action from head of queue
	 */
	public Action getHead() {
		return actionQ.poll();
	}

	/**
	 * get all queued actions
	 * @return array of queued actions, where 0 = head
	 */
	public Action[] getQueue() {
		return (Action[])(actionQ.toArray());
	}
	
	/**
	 * removes a given action from the queue
	 * @param a action to remove
	 * @return true if item was in queue & removed
	 */
	public boolean removeFromQueue(Action a) {
		return actionQ.remove(a);
	}
	
	/**
	 * clears out queue
	 */
	public void clearQueue() {
		actionQ = new ConcurrentLinkedQueue<Action>();
	}
	
	/**
	 * atomically sets pendingAction
	 * @param a new action
	 */
	public void setPendingAction(Action a) {
		pendingAction.set(a);
	}
	
	/**
	 * atomically returns current pendingAction & clears it
	 * @return current pendingAction
	 */
	public Action popPendingAction() {
		return pendingAction.getAndSet(null);
	}
	
	public boolean isPlaying() {
		return running;
	}
	
	public String queueToString() {
		String queueString = "\"queue\":" + actionQ.toString();
		String pendingString = ",\"pending\":" + pendingAction.toString();
		String out = queueString + pendingString;
		if (currentAction != null) {
			out += ",\"current\":" + currentAction.toString();
		}
		return out;
	}

	/**
	 * indicates that an action is actually in progress
	 * @param state
	 */
	private void setRunning(boolean state) {
		running = state;
	}
	
	/**
	 * provide a list of OSC senders through which time status messages will be sent
	 * to other system components
	 * @param senders
	 */
	public void setStatusRecipients(OSCSender[] senders) {
		statusRecipients = senders;
	}
	
	/**
	 * actually send the time remaining message & set id
	 * @param id of set -- line number in setlist.txt
	 * @param time milliseconds remaining before set ends
	 */
	private void sendTimeRemainingMessage(int id, int time, String lightingProgram) {
		for (OSCSender s : statusRecipients) {
			s.sendTimeRemaining(id, time, lightingProgram);
		}
	}
	
}

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 3
**   tab-width: 3
**   indent-tabs-mode: nil
** End:
**
** vim: softtabstop=3 tabstop=3 expandtab cindent shiftwidth=3
**
*/

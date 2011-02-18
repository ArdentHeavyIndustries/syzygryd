package com.syzygryd;

import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

public class ActionRunner extends Thread {
	
	private static int SECOND_IN_MILLIS = 1000;
	private static int LOAD_TIMEOUT = 600 * SECOND_IN_MILLIS;
	private static int ARBITRARY_SLEEP_BETWEEN_SETS = 3 * SECOND_IN_MILLIS;
	private static int QUIT_TIMEOUT = 10 * SECOND_IN_MILLIS;
	private static int INTERVAL_BETWEEN_DURATION_NOTIFICATIONS = 5 * SECOND_IN_MILLIS;
	
	private boolean running = false;
	
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
		
		while (true) {  // don't stop til you get enough
			// determine next action in this order:
			
			// 1. existing pending action (which would have been set via actNow())
			currentAction = popPendingAction();
			
			// 2. action at head of queue
			if (currentAction == null) {
				currentAction = getHead(); // try the salmon.  tip your waitron.
			}
			
			// 3. play next track
			if (currentAction == null) {
				currentAction = ActionFactory.createAction(Action.ActionType.playnext, null);
			}
			
			// attempt to start.  if it succeeds, perform load
			if(currentAction.start()) {
				setRunning(true);
				boolean loaded = true;
				int duration = currentAction.getDuration();
				int remaining = duration;
				// first wait for the action to load if necessary
				// NB, dude: loading must finish (or be cleanly canceled) before you try to load another action
				if (currentAction.requiresLoad()) {
					loaded = false;
					Logger.info("Waiting for load...");
					try {
						loaded = loadPending.await(LOAD_TIMEOUT, TimeUnit.MILLISECONDS);
					} catch (InterruptedException e) {
						// NIL;
					}

				}
				
				if (loaded) {
					// action is now running; wait until it's done or someone interrupts us
					Logger.info("Playing...");
					boolean interrupted = false;
					while(remaining > 0 && !interrupted) {
						int sleepDuration = Math.min(INTERVAL_BETWEEN_DURATION_NOTIFICATIONS, remaining);
						sendTimeRemainingMessage(remaining, currentAction.getId(), currentAction.getLightingProgram() );
						try {
							interrupted = actionRunning.await(sleepDuration, TimeUnit.MILLISECONDS);
						} catch (InterruptedException e) {
							// NIL;
						}
						remaining -= INTERVAL_BETWEEN_DURATION_NOTIFICATIONS;
					}
					
					sendTimeRemainingMessage(0, currentAction.getId(), currentAction.getLightingProgram());
					
				} 
				setRunning(false);
				Logger.info("Stopping...");
				currentAction.stop();
				try {
					endPending.await(QUIT_TIMEOUT, TimeUnit.MILLISECONDS);
				} catch (InterruptedException e1) {
					// NOP
				}
				Logger.info("Stopped.");
				try {
					Thread.sleep(ARBITRARY_SLEEP_BETWEEN_SETS);
				} catch (InterruptedException e) {
					// 
					// NOP
				}
			}
			
			// reset locks
			initLocks();
		}
	}
	
	/**
	 * make action happen right now
	 * @param a action to perform
	 */
	public synchronized void actNow(Action a) {
		setPendingAction(a);
		// countdown latch will pass right through, causing it to immediately stop
		actionRunning.countDown();
	}
	
	/**
	 * called after an action that required loading
	 * has completed loading 
	 */
	public void actionLoaded() {
		loadPending.countDown();
	}
	
	/**
	 * called after an action that requires shutdown 
	 * has finished shutting down
	 */
	public void actionEnded() {
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

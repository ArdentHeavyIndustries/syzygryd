package com.syzygryd;

import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

public class ActionRunner extends Thread {
	
   // XXX is this still used?
	//private boolean running = false;

   // for variable load timeout
   public boolean liveRunning;

   // for measuring load time
   private long beginLoadTimeMs;
	
   // XXX this is stupid now that there's just one, we should get rid of the array and just use a single OSCSender
	private OSCSender[] statusRecipients = null;
	
	private ConcurrentLinkedQueue<Action> actionQ = new ConcurrentLinkedQueue<Action>();
	
	/**
	 * action to be immediately executed; preempts queue
	 */
	private AtomicReference<Action> pendingAction = new AtomicReference<Action>();
	private Action currentAction = null;

   // XXX we no longer have an explicit initLocks() method creating
   // new CountDownLatch's b/c of the PLAYING-STOPPED-PLAYING
   // situation, and we don't want to prematurely count down stop for
   // a fake case.
   // so we instead set (almost) right before using them.
   // see doStart() for more details.
	/**
	 * blocks until load has finished
	 */
	private CountDownLatch loadPending = null;

   /**
    * blocks until live has started playing
    */
   private CountDownLatch startPending = null;
	
	/**
	 * blocks until action has completed or is interrupted by a new, immediate action
	 */
	private CountDownLatch actionRunning = null;
	
	/**
	 * blocks until action has stopped
	 */
	private CountDownLatch stopPending = null;

   // this is a singleton
   private static ActionRunner instance = null;
	
	private ActionRunner() {
	}

   public static ActionRunner getInstance() {
      if (ActionRunner.instance == null) {
         ActionRunner.instance = new ActionRunner();
      }
      return ActionRunner.instance;
   }
	
	@Override
	public void run() {
      Logger.info("Begin ActionRunner.run()");

      if (Config.SYNC_WATCHDOG_MS > Config.TIME_REMAINING_INTERVAL_MS) {
         Logger.warn("Sync watchdog (" + Config.SYNC_WATCHDOG_MS
                     + " ms) > time remaining interval (" + Config.TIME_REMAINING_INTERVAL_MS
                     + " ms), this could cause bad behavior for the first of each iteration");
      }

      try {
         this.liveRunning = ProcessUtils.isLiveProcessRunning();
         // XXX if live is running, should we try to detect if it is playing, and if so, stop first?
         Logger.info("Live is already running: " + this.liveRunning);
      } catch (SwitcherException se) {
         Logger.warn("Caught exception just trying to tell if live is running, this may be a very bad sign: " + se.getMessage());
         this.liveRunning = false;
      }

      Logger.info("Before infinite loop in ActionRunner.run()");
      // XXX would a web ability to exit be a good or bad idea ?
		while (true) {
         Logger.debug("Beginning of loop in ActionRunner.run()");
         try {
            // determine next action in this order:
            
            // 1. existing pending action (which would have been set via actNow())
            this.currentAction = popPendingAction();
            Logger.debug("Popped pending action, if applicable: " + actionToShortString(this.currentAction));
            
            // 2. action at head of queue
            if (this.currentAction == null) {
               this.currentAction = getHead(); // try the salmon.  tip your waitron.
               Logger.debug("Getting action at the head of the queue, if applicable: " + actionToShortString(this.currentAction));
            }
            
            // 3. play next track
            if (this.currentAction == null) {
               this.currentAction = ActionFactory.createAction(Action.ActionType.playnext, null);
               Logger.debug("Default fallthrough creating new action: " + actionToShortString(this.currentAction));
            }
            
            doAction(this.currentAction);
         } catch (SwitcherException se) {
            Logger.warn("Caught exception in ActionRunner run loop", se);
            ProcessUtils.doLiveQuit();
         }
         Logger.debug("End of loop in ActionRunner.run()");
		}
	}

   private void doAction(Action action)
      throws SwitcherException
   {
      doInit(action);
      doLoad(action);
      doStart(action);
      doRun(action);
      doStop(action);
      doBetween();
   }

   private void doInit(Action action)
      throws SwitcherException
   {
      Logger.debug("Initializing action: " + actionToShortString(action));      
      if (action.requiresLoad()) {
         this.loadPending = new CountDownLatch(1);
      }
      // for the common case of opening a new set (XXX is this the
      // only case in practice?), action.init() actually
      // executes the open command on the *.als file, which will start
      // live if needed, and load the set.
      this.beginLoadTimeMs = System.currentTimeMillis();
      action.init();
      Logger.debug("Action has initialized.");
      //Logger.debug("Action has initialized, set running to true");
      //setRunning(true);
   }

   private void doLoad(Action action)
      throws SwitcherException
   {
      boolean loaded;
      // first wait for the action to load if necessary
      // NB, dude: loading must finish (or be cleanly canceled) before you try to load another action

      int loadTimeoutMs;
      if (this.liveRunning) {
         loadTimeoutMs = Config.LOAD_OTHER_TIMEOUT_MS;
      } else {
         loadTimeoutMs = Config.LOAD_FIRST_TIMEOUT_MS;
      }

      if (action.requiresLoad()) {
         Logger.debug("Action requires load: " + actionToShortString(action));
         Logger.info("Waiting (up to " + loadTimeoutMs + " ms) for load...");
         loaded = doWait(this.loadPending, loadTimeoutMs);
         this.loadPending = null;
      } else {
         Logger.warn("Action does not require load.  I didn't think that could happen in practice: " + actionToShortString(action));
         loaded = true;
      }
      
      if (loaded) {
         long loadTimeMs = System.currentTimeMillis() - this.beginLoadTimeMs;
         Logger.info("Done loading, this took " + loadTimeMs + " ms, out of " + loadTimeoutMs + " ms, giving us " + (loadTimeoutMs - loadTimeMs) + " ms to spare.");
         Logger.debug("Setting live running");
         this.liveRunning = true;
      } else {
         SwitcherException.doThrow("Done waiting " + loadTimeoutMs + " ms, but load did not occur");
      }
   }

   private void doStart(Action action)
      throws SwitcherException
   {
      // we start live playing by pressing space
      boolean started = false;
      int nStartTries = 0;
      Logger.info("Waiting (up to " + Config.MAX_START_TRIES + " iterations) for start");
      while (!started && nStartTries < Config.MAX_START_TRIES) {
         Logger.info("Starting...");
         this.startPending = new CountDownLatch(1);
         action.start();
         Logger.info("Waiting (up to " + Config.START_ITERATION_TIMEOUT_MS + " ms per iteration) for start...");
         started = doWait(this.startPending, Config.START_ITERATION_TIMEOUT_MS);
         this.startPending = null;
         if (!started) {
            Logger.info("Start not yet detected, will (possibly) retry");
            nStartTries++;
         }
      }

      if (started) {
         // Do this here, now, so that we don't get spew from the /sync msgs received in the interim
         Logger.debug("Resetting last sync time");
         Switcher.lastSyncMs = 0;
         // Sometimes instead of just a PLAYING message from live, we
         // get PLAYING-STOPPED-PLAYING in rapid succession.  So wait
         // a little bit and verify that the state is still PLAYING.
         //
         // XXX This implementation somewhat breaks clean OO
         // abstractions here, perhaps we should be reusing
         // startPending and allow for counting up as well as down
         // (although then we'd need a different synchronization
         // construct than CountDownLatch), but I'm being somewhat
         // lazy for now and doing mostly what's easy.
         Logger.debug("Likely done starting, waiting " + Config.STATE_UNCHANGED_WAIT_MS + " ms to make sure we are still started");
         doSleep(Config.STATE_UNCHANGED_WAIT_MS);
         if (action.isStarted()) {
            Logger.info("Done starting");
         } else {
            SwitcherException.doThrow("Initially started, but after a wait of " + Config.STATE_UNCHANGED_WAIT_MS + " ms, we are no longer still started");
         }
      } else {
         SwitcherException.doThrow("Done waiting " + Config.MAX_START_TRIES + " iterations of " + Config.START_ITERATION_TIMEOUT_MS + " ms, but start did not occur");
      }
   }

   private void doRun(Action action)
      throws SwitcherException
   {
      // XXX additionally we could be listening for /sync, and on
      // every iteration here, if we haven't received sync in some
      // amount of time (or since the previous iteration), conclude
      // there's a problem and give up
      // XXX the problem with this is that ShowControl runs on the
      // same host as the switcher, and it is already listening on
      // port 9002, which live uses to broadcast sync.  so in practice
      // live would need to send additionally to a new port and we
      // would have to listen on that.

      // action is now running (live is playing)
      // wait until it's done or someone interrupts us
      int remainingMs = action.getDuration();
      Logger.info("Playing for up to " + remainingMs + " ms ...");
      boolean interrupted = false;
      this.actionRunning = new CountDownLatch(1);
      Logger.debug("NOT resetting last sync time, since we already did that during start");
      boolean firstIteration = true;
      while (remainingMs > 0 && !interrupted) {
         int sleepDurationMs = Math.min(Config.TIME_REMAINING_INTERVAL_MS, remainingMs);
         sendTimeRemainingMessage(remainingMs, action.getId(), action.getLightingProgram() );
         interrupted = doWait(this.actionRunning, sleepDurationMs);
         if (!interrupted && !firstIteration) {
            if (Switcher.lastSyncMs <= 0) {
               SwitcherException.doThrow("More than one full iteration of time remaining has completed, and we still have not received a /sync msg, giving up on Live");
            }
            long now = System.currentTimeMillis();
            long diff = now - Switcher.lastSyncMs;
            if (diff > Config.SYNC_WATCHDOG_MS) {
               SwitcherException.doThrow("It has been " + diff + " ms since a /sync msg, which is longer than the " + Config.SYNC_WATCHDOG_MS + " ms threshold, giving up on Live");
            }
         }
         firstIteration = false;
         remainingMs -= Config.TIME_REMAINING_INTERVAL_MS;
      }
      this.actionRunning = null;
      Switcher.lastSyncMs = -1;
      Logger.debug("No longer waiting for sync messages");
      sendTimeRemainingMessage(0, action.getId(), action.getLightingProgram());

      if (interrupted) {
         Logger.info("Set was prematurely interrupted");
      } else {
         Logger.debug("Set played to completion");
      }
   }

   // also called by ProcessUtils.doLiveQuit()
   protected void doStop(Action action)
      throws SwitcherException
   {
      //Logger.debug("Done running, set running to false");
      //setRunning(false);

      // we stop live playing by pressing space
      Logger.info("Stopping...");
		this.stopPending = new CountDownLatch(1);
      action.stop();
      Logger.debug("Waiting (up to " + Config.STOP_TIMEOUT_MS + " ms) for stop...");
      boolean stopped = doWait(this.stopPending, Config.STOP_TIMEOUT_MS);
      this.stopPending = null;

      if (stopped) {
         // Similar to the case in doStop(), I think instead of just a
         // STOPPED message from live, we can sometimes get
         // STOPPED-PLAYING-STOPPED in rapid succession.
         Logger.debug("Likely done stopping, waiting " + Config.STATE_UNCHANGED_WAIT_MS + " ms to make sure we are still stopped");
         doSleep(Config.STATE_UNCHANGED_WAIT_MS);
         if (action.isStopped()) {
            Logger.info("Done stopping");
         } else {
            SwitcherException.doThrow("Initially stopped, but after a wait of " + Config.STATE_UNCHANGED_WAIT_MS + " ms, we are no longer still stopped");
         }
      } else {
         SwitcherException.doThrow("Done waiting " + Config.STOP_TIMEOUT_MS + " ms, but stop did not occur");
      }
   }

   private void doBetween()
      throws SwitcherException
   {
      // XXX this bothers me
      if (Config.ARBITRARY_SLEEP_BETWEEN_SETS_MS > 0) {
         Logger.info("Waiting " + Config.ARBITRARY_SLEEP_BETWEEN_SETS_MS + " ms between sets");
         doSleep(Config.ARBITRARY_SLEEP_BETWEEN_SETS_MS);
         Logger.debug("Done waiting");
      } else {
         Logger.debug("No arbitrary wait between sets");
      }
   }

   // XXX this probably belongs in some utils class
   /* package */ static boolean doWait(CountDownLatch pending, long timeMs) {
      boolean countedDown = false;
      try {
         countedDown = pending.await(timeMs, TimeUnit.MILLISECONDS);
      } catch (InterruptedException ie) {
         // NIL;
      }
      return countedDown;
   }

   private void doSleep(long timeMs) {
      try {
         Thread.sleep(timeMs);
      } catch (InterruptedException ie) {
         // NOP
      }
   }

   // to prevent NPE's
   private String actionToString(Action action) {
      return action == null ? null : action.toString();
   }
   protected String actionToShortString(Action action) {
      return action == null ? null : action.toShortString();
   }
	
	/**
	 * make action happen right now
	 * @param a action to perform
	 */
	public synchronized void actNow(Action a) {
		setPendingAction(a);
      if (this.actionRunning != null) {
         // countdown latch will pass right through, causing it to immediately stop
         Logger.debug("counting down action running");
         this.actionRunning.countDown();
      } else {
         // this is unexpected, so warn
         Logger.warn("ignoring count down for action running");
      }
	}
	
	/**
	 * called after an action that required loading
	 * has completed loading 
	 */
	public void actionLoaded() {
      if (this.loadPending != null) {
         Logger.debug("counting down load pending");
         this.loadPending.countDown();
      } else {
         // this is unexpected, so warn
         Logger.warn("ignoring count down for load pending");
      }
	}

   /**
    * called after an action that requires starting
    * has completed starting
    */
	public void actionStarted() {
      if (this.startPending != null) {
         Logger.debug("counting down start pending");
         this.startPending.countDown();
      } else {
         // while annoying, this is expected to be possible, so don't warn
         Logger.debug("ignoring count down for start pending (likely due to PLAYING-STOPPED-PLAYING or STOPPED-PLAYING-STOPPED case)");
      }
	}
	
	/**
	 * called after an action that requires stopping
	 * has completed stopping
	 */
	public void actionStopped() {
      if (this.stopPending != null) {
         Logger.debug("counting down stop pending");
         this.stopPending.countDown();
      } else {
         // while annoying, this is expected to be possible, so don't warn
         Logger.debug("ignoring count down for stop pending (likely due to PLAYING-STOPPED-PLAYING or STOPPED-PLAYING-STOPPED case)");
      }
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
	
 	// public boolean isPlaying() {
	// 	return this.running;
	// }
	
	public String queueToString() {
		String queueString = "\"queue\":" + actionQ.toString();
		String pendingString = ",\"pending\":" + pendingAction.toString();
		String out = queueString + pendingString;
		if (this.currentAction != null) {
			out += ",\"current\":" + actionToString(this.currentAction);
		}
		return out;
	}

	/**
	 * indicates that an action is actually in progress
	 * @param state
	 */
	// private void setRunning(boolean running) {
	// 	this.running = running;
	// }
	
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

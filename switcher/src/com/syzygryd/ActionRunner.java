package com.syzygryd;

import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

public class ActionRunner extends Thread {
	
	private static int SECOND_IN_MILLIS = 1000;
	private static int LOAD_TIMEOUT = 600 * SECOND_IN_MILLIS;
	
	private ConcurrentLinkedQueue<Action> actionQ = new ConcurrentLinkedQueue<Action>();
	
	/**
	 * action to be immediately executed; preempts queue
	 */
	private AtomicReference<Action> pendingAction = new AtomicReference<Action>();
	
	/**
	 * blocks until load has finished
	 */
	private CountDownLatch loadPending;
	
	/**
	 * blocks until action has completed or is interrupted by a new, immediate action
	 */
	private CountDownLatch actionRunning;
	
	public ActionRunner() {
		initLocks();
	}
	
	/**
	 * resets locks
	 */
	private void initLocks() {
		loadPending = new CountDownLatch(1);
		actionRunning = new CountDownLatch(1);
	}
	
	@Override
	public void run() {
		
		while (true) {  // don't stop til you get enough
			// determine next action in this order:
			
			// 1. existing pending action (which would have been set via now())
			Action currentAction = popPendingAction();
			
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
				
				boolean loaded = true;
				int duration = currentAction.getDuration();
				// first wait for the action to load if necessary
				// NB, dude: loading must finish (or be cleanly canceled) before you try to load another action
				if (currentAction.requiresLoad()) {
					loaded = false;
					try {
						loaded = loadPending.await(LOAD_TIMEOUT, TimeUnit.MILLISECONDS);
					} catch (InterruptedException e) {
						// NIL;
					}
				}
				
				if (loaded) {
					// action is now running; wait until it's done or someone interrupts us
					try {
						actionRunning.await(duration, TimeUnit.MILLISECONDS);
					} catch (InterruptedException e) {
						// NIL;
					}
				} 
				currentAction.stop();
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
	 * queue up an action
	 * @param a
	 */
	public synchronized void queue(Action a) {
		actionQ.add(a);
	}
	
	public synchronized Action getHead() {
		return actionQ.poll();
	}
	
	public void setPendingAction(Action a) {
		pendingAction.set(a);
	}
	
	public Action popPendingAction() {
		return pendingAction.getAndSet(null);
	}
	
	
	
}

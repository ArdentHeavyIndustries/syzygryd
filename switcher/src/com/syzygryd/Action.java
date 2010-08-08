package com.syzygryd;

import java.util.Properties;

/**
 * An activity that is performed via ActionRunner
 *
 */
public abstract class Action {
	/**
	 * types of actions we support:
	 * playthis: play a track specified by property setid
	 * playnext: play next track in setlist
	 * playprev: play previous track in setlist
	 * 
	 * livespace: send space key to live
	 * liveesc: send esc key to live
	 * livequit: tell live to quit
	 * 
	 * screenshot: current state of the screen
	 * loadtimeout: give up on loading and unblock actionrunner
	 * 
	 */
	public enum ActionType { playthis, playnext, playprev, 
							livespace, liveesc, livequit,
							screenshot, loadtimeout }
	
	/***
	 * indicates that this action plays until stopped
	 */
	public static int DURATION_INFINITE = -1; 
	/***
	 * indicates that we don't yet know how long this will last
	 */
	public static int DURATION_UNKNOWN = -2; 
	
	protected int duration = DURATION_UNKNOWN;
	
	public final ActionType type;
	public final Properties params;
	
	protected boolean asyncLoading = false;
	
	Action(ActionType t, Properties p) {
		type = t;
		params = p;
	}
	
	public abstract boolean start();
	
	public abstract void stop();
	
	/**
	 * indicates that this action loads asynchronously, and that
	 * you probably want to wait for this to finish loading before running it
	 * @return true if waiting for load is recommended
	 */
	public boolean requiresLoad() {
		return asyncLoading;
	}
	
	/**
	 * duration of this action; returns DURATION_INFINITE if
	 * this will play until interrupted
	 * @return duration in ms; DURATION_INFINITE if it goes forever
	 */
	public int getDuration() {
		return duration;
	}
	
}

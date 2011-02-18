package com.syzygryd;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

/**
 * Runs AppleScripts & stashes a reference to an AppleScript engine
 *
 */
public class AppleScriptRunner {
	private static final String liveQuit = "tell application \"Live\"\n quit\nend tell";
	private static final String liveActivate = "tell application \"Live\"\n activate\nend tell";
	private static final String liveSpace = "tell application \"Live\"\nactivate\ntell application \"System Events\"\nkeystroke \" \"\nend tell\nend tell";
	private static final String liveEnter = "tell application \"Live\"\nactivate\ntell application \"System Events\"\nkeystroke return\nend tell\nend tell";

	private static final String liveEsc = "tell application \"Live\"\nactivate\ntell application \"System Events\"\nkey code 53\nend tell\nend tell";
	
	private static ScriptEngineManager mgr = new ScriptEngineManager();
	private static ScriptEngine engine = mgr.getEngineByName("AppleScript");
    
	/**
	 * Runs a passed in script against stashed engine
	 * @param script
	 */
    private static void runScript(String script) {
    	try {
			engine.eval(script);
		} catch (ScriptException e) {
			// TODO Auto-generated catch block
			Logger.warn(e);
		}
    }
    
    /**
     * Quits live
     */
    public static void runLiveQuit() {
		Logger.info("Running live quit script...");
    	runScript(liveQuit);
    }
    
    /**
     * Sends space bar to live
     */
    public static void runLiveSpace() {
    	runScript(liveSpace);
    }
    
    /**
     * Sends space bar to live
     */
    public static void runLiveEnter() {
    	runScript(liveEnter);
    }
    
    /**
     * Sends ESC key to live
     */
    public static void runLiveEsc() {
    	runScript(liveEsc);
    }
    
    /**
     * Brings Live to front
     */
    public static void runLiveActivate() {
    	runScript(liveActivate);
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

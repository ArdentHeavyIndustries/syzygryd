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
		} catch (ScriptException se) {
			// TODO Auto-generated catch block
         // XXX swallowing this is probably bad
			Logger.warn(se);
		}
    }
    
    /**
     * Quits live
     */
   // XXX we should have a more failsafe means for this that forces a quit if this fails
    public static void runLiveQuit() {
		Logger.info("Telling live to quit");
    	runScript(liveQuit);
    }
    
    /**
     * Sends space bar to live
     */
    public static void runLiveSpace() {
       Logger.info("Sending space to live");       
       runScript(liveSpace);
    }
    
    /**
     * Sends enter bar to live
     */
    // public static void runLiveEnter() {
    //    Logger.info("Sending enter to live");
    //    runScript(liveEnter);
    // }
    
    /**
     * Sends ESC key to live
     */
    public static void runLiveEsc() {
       Logger.info("Sending esc to live");       
       runScript(liveEsc);
    }
    
    /**
     * Brings Live to front
     */
    public static void runLiveActivate() {
       // XXX what is this ?  perhaps it's to bring to the foreground?
       // it falls through from the livescreenshot case to the
       // screenshot case in Syzyweb.act()
       Logger.info("Telling live to activate");
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

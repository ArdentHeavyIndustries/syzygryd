package com.syzygryd;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

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

   private static final long APPLESCRIPT_TIMEOUT_MS = 5000;
   // XXX for testing badness
   //private static final long APPLESCRIPT_TIMEOUT_MS = 10;
   
   // XXX for testing only
   // private static boolean debugOutput = false;
   // private static Object debugObject = new Object();
    
	/**
	 * Runs a passed in script against stashed engine
	 * @param script
	 */
   private static void runScript(final String script) {
      // synchronized (debugObject) {
      //    if (!debugOutput) {
      //       Logger.debug("GLOBAL_SCOPE = " + javax.script.ScriptContext.GLOBAL_SCOPE);
      //       Logger.debug("ENGINE_SCOPE = " + javax.script.ScriptContext.ENGINE_SCOPE);
      //       for (Integer scope: engine.getContext().getScopes()) {
      //          Logger.debug("scope " + scope);
      //          javax.script.Bindings bindings = engine.getContext().getBindings(scope.intValue());
      //          for (String key: bindings.keySet()) {
      //             Logger.debug("key: " + key);
      //          }
      //       }
      //       debugOutput = true;
      //    }
      // }

      final CountDownLatch scriptPending = new CountDownLatch(1);
      // these are relatively infrequent enough that I won't worry about a thread pool
      Thread t = new Thread(new Runnable() {
            public void run() {
               // The default timeout, which eventually throws the following,
               // appears to be WAY too long (longer than 90 seconds), and I
               // don't know of any way to set it.
               //   javax.script.ScriptException: Live got an error: AppleEvent timed out.
               // That's why we're running this in a separate thread
               try {
                  Logger.debug("Evaluating AppleScript: \"" + script + "\"");
                  engine.eval(script);
                  Logger.debug("Done evaluating AppleScript");
                  scriptPending.countDown();
               } catch (ScriptException se) {
                  // TODO Auto-generated catch block
                  // XXX swallowing this is probably bad
                  Logger.warn(se);
               }
            }
         });
      Logger.debug("Starting background thread to execute script");
      t.start();

      Logger.debug("Will wait up to " + APPLESCRIPT_TIMEOUT_MS + " ms to execute script");
      boolean scriptSuccessfullyExecuted = false;
      try {
         scriptSuccessfullyExecuted = scriptPending.await(APPLESCRIPT_TIMEOUT_MS, TimeUnit.MILLISECONDS);
      } catch (InterruptedException ie) {
      }

      if (scriptSuccessfullyExecuted) {
         Logger.debug("Script successfully executed");
      } else {
         Logger.warn("Script did not successfully execute in time");
         // XXX we should probably throw an Exception here.  coming soon...
         // Afaik, there's no way to cancel the script, but it's okay, b/c we'll probably be killing Live as a result of it
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

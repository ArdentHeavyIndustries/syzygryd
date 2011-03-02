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
   // code is from http://www.devdaily.com/blog/post/mac-os-x/applescript-simulating-enter-key
   // doesn't work any better for my issues quitting
   // is this shit documented anywhere for real?
	//private static final String liveEnter = "tell application \"Live\"\nactivate\ntell application \"System Events\"\nkey code 36\nend tell\nend tell";

	private static final String liveEsc = "tell application \"Live\"\nactivate\ntell application \"System Events\"\nkey code 53\nend tell\nend tell";
	
	private static ScriptEngineManager mgr = new ScriptEngineManager();
	private static ScriptEngine engine = mgr.getEngineByName("AppleScript");

   private static final long APPLESCRIPT_TIMEOUT_MS = 10000;
   // XXX for testing badness
   //private static final long APPLESCRIPT_TIMEOUT_MS = 10;
   
   // XXX for testing only
   // private static boolean debugOutput = false;
   // private static Object debugObject = new Object();

   private static ScriptException scriptException;
    
	/**
	 * Runs a passed in script against stashed engine
	 * @param script
	 */
   private static void runScript(final String script)
      throws SwitcherException
   {
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
               } catch (ScriptException se) {
                  String msg = "Caught exception (" + se.getMessage() + ") executing AppleScript: \"" + script + "\"";
                  Logger.warn(msg);
                  scriptException = se;
               } finally {
                  scriptPending.countDown();
               }
            }
         });

      // XXX for now only allow one script at a time, at least while we're waiting, due to the primitive exception reporting mechanism used here
      synchronized (mgr) {
         scriptException = null;
         Logger.debug("Starting background thread to execute script");
         t.start();

         Logger.debug("Will wait up to " + APPLESCRIPT_TIMEOUT_MS + " ms to execute script");
         // XXX could we just use t.join(long millis) for this ?
         boolean scriptCompleted = ActionRunner.doWait(scriptPending, APPLESCRIPT_TIMEOUT_MS);
         if (scriptException != null) {
            SwitcherException.doThrow("Script threw exception", scriptException);
         } else if (scriptCompleted) {
            Logger.debug("Script successfully executed");
         } else {
            SwitcherException.doThrow("Script did not successfully execute in time");
         }
      }
   }
    
   /**
    * Quits live
    */
   // XXX we should have a more failsafe means for this that forces a quit if this fails
   public static void runLiveQuit()
      throws SwitcherException
   {
		Logger.info("Telling live to quit");
    	runScript(liveQuit);
   }
    
   /**
    * Sends space bar to live
    */
   public static void runLiveSpace()
      throws SwitcherException
   {
      Logger.info("Sending space to live");       
      runScript(liveSpace);
   }
    
    /**
     * Sends enter to live
     */
   public static void runLiveEnter()
      throws SwitcherException             
   {
      Logger.info("Sending enter to live");
      runScript(liveEnter);
   }
   
   /**
    * Sends ESC key to live
    */
   public static void runLiveEsc()
      throws SwitcherException
   {
      Logger.info("Sending esc to live");       
      runScript(liveEsc);
   }
    
   /**
    * Brings Live to front
    */
   public static void runLiveActivate()
      throws SwitcherException
   {
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

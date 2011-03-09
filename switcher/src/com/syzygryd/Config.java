package com.syzygryd;

import java.io.FileReader;
import java.io.IOException;
import java.lang.NumberFormatException;
import java.util.Properties;

// The idea is *not* to put all possible constants here.
// Only those that we might want to fiddle with in the short term without having to edit the source.
// So timeouts, yes.  Ports, no.
public class Config {

   private static final String PROPS_FILE = "/opt/syzygryd/etc/switcher.properties";
   private Properties defaultProps;
   private Properties props;

	private static final int SECOND_IN_MILLIS = 1000;

   ///////////////////////////////////////////////////////////////////////////////
   // These are the default values, if not set in the properties file.
   // Use String's here, regardless of the final type.
   // These should be consistent with the commented out lines in the
   // example etc/switcher.properties file.

   // from Switcher
   private static final String DEFAULT_ETHERNET_INTERFACE = "en0";

   // from ActionRunning
   // load
   // we want the timeout to load a set to be longer if we might need to first start live
	private static final String DEFAULT_LOAD_FIRST_TIMEOUT_SEC = "90";
	private static final String DEFAULT_LOAD_OTHER_TIMEOUT_SEC = "30";
   // start
   private static final String DEFAULT_START_ITERATION_TIMEOUT_SEC = "5";
   private static final String DEFAULT_MAX_START_TRIES = "6";
   // run
	private static final String DEFAULT_TIME_REMAINING_INTERVAL_SEC = "5";
   private static final String DEFAULT_SYNC_WATCHDOG_SEC = "3";
   // stop
	private static final String DEFAULT_STOP_TIMEOUT_SEC = "5";
   // between
   // XXX is this really needed?  it seems incredibly hacky, and likely no longer required.  nevertheless, keep for now, but make minimal.
	private static final String DEFAULT_ARBITRARY_SLEEP_BETWEEN_SETS_SEC = "1";
   // used for both start and stop
   private static final String DEFAULT_STATE_UNCHANGED_WAIT_SEC = "1";

   // from AppleScriptRunner
   private static final String DEFAULT_APPLESCRIPT_TIMEOUT_SEC = "10";

   // from Logger
   private static final String DEFAULT_VERBOSE = "false";
   private static final String DEFAULT_DEBUG = "true";

   // from ProcessUtils
   private static final String DEFAULT_LIVE_QUIT_ITERATION_SEC = "1";
   private static final String DEFAULT_LIVE_QUIT_MAX_ITER = "5";
   private static final String DEFAULT_KILL_OPEN_SET_PROCESSES_ITERATION_SEC = "1";
   private static final String DEFAULT_KILL_OPEN_SET_PROCESSES_MAX_ITER = "5";

   // from Syzyweb
	private static final String DEFAULT_SCREENSHOT_DELAY_SEC = "1";

   ///////////////////////////////////////////////////////////////////////////////
   // These are the values that will be set based on configuring,
   // and is what other classes should access.
   //
   // In the long term, perhaps this is stupid, and anything should
   // just be calling methods here to get the props, but this is the
   // quickest way with the least changes for now.

   public static String ETHERNET_INTERFACE;
	public static int LOAD_FIRST_TIMEOUT_MS;
	public static int LOAD_OTHER_TIMEOUT_MS;
   public static int START_ITERATION_TIMEOUT_MS;
   public static int MAX_START_TRIES;
	public static int TIME_REMAINING_INTERVAL_MS;
   public static int SYNC_WATCHDOG_MS;
	public static int STOP_TIMEOUT_MS;
	public static int ARBITRARY_SLEEP_BETWEEN_SETS_MS;
   public static int STATE_UNCHANGED_WAIT_MS;
   public static int APPLESCRIPT_TIMEOUT_MS;
   public static boolean VERBOSE;
   public static boolean DEBUG;
   public static int LIVE_QUIT_ITERATION_MS;
   public static int LIVE_QUIT_MAX_ITER;
   public static int KILL_OPEN_SET_PROCESSES_ITERATION_MS;
   public static int KILL_OPEN_SET_PROCESSES_MAX_ITER;
	public static int SCREENSHOT_DELAY_MS;

   public Config() {
   }

   // XXX this is largely copied from controller_display.pde (in processing)

   public void setupProps() {
      // Configure default values, if not set in the file
      defaultProps = new Properties();
      defaultProps.setProperty("ethernetInterface", DEFAULT_ETHERNET_INTERFACE);
      defaultProps.setProperty("loadFirstTimeoutSec", DEFAULT_LOAD_FIRST_TIMEOUT_SEC);
      defaultProps.setProperty("loadOtherTimeoutSec", DEFAULT_LOAD_OTHER_TIMEOUT_SEC);
      defaultProps.setProperty("startIterationTimeoutSec", DEFAULT_START_ITERATION_TIMEOUT_SEC);
      defaultProps.setProperty("maxStartTries", DEFAULT_MAX_START_TRIES);
      defaultProps.setProperty("timeRemainingIntervalSec", DEFAULT_TIME_REMAINING_INTERVAL_SEC);
      defaultProps.setProperty("syncWatchdogSec", DEFAULT_SYNC_WATCHDOG_SEC);
      defaultProps.setProperty("stopTimeoutSec", DEFAULT_STOP_TIMEOUT_SEC);
      defaultProps.setProperty("arbitrarySleepBetweenSetsSec", DEFAULT_ARBITRARY_SLEEP_BETWEEN_SETS_SEC);
      defaultProps.setProperty("stateUnchangedWaitSec", DEFAULT_STATE_UNCHANGED_WAIT_SEC);
      defaultProps.setProperty("applescriptTimeoutSec", DEFAULT_APPLESCRIPT_TIMEOUT_SEC);
      defaultProps.setProperty("verbose", DEFAULT_VERBOSE);
      defaultProps.setProperty("debug", DEFAULT_DEBUG);
      defaultProps.setProperty("liveQuitIterationSec", DEFAULT_LIVE_QUIT_ITERATION_SEC);
      defaultProps.setProperty("liveQuitMaxIter", DEFAULT_LIVE_QUIT_MAX_ITER);
      defaultProps.setProperty("killOpenSetProcessesIterationSec", DEFAULT_KILL_OPEN_SET_PROCESSES_ITERATION_SEC);
      defaultProps.setProperty("killOpenSetProcessesMaxIter", DEFAULT_KILL_OPEN_SET_PROCESSES_MAX_ITER);
      defaultProps.setProperty("screenshotDelaySec", DEFAULT_SCREENSHOT_DELAY_SEC);
  
      // Now set properties from the file, falling back on defaults
      props = new Properties(defaultProps);
      Logger.info("Loading properties from " + PROPS_FILE);
      try {
         props.load(new FileReader(PROPS_FILE));
      } catch (IOException ioe) {
         Logger.warn ("Can't load properties file, will use all default values: " + PROPS_FILE);
      }

      Logger.info("Properties are as follows:");
      for (String key: props.stringPropertyNames()) {
         Logger.info(key + "=" + props.getProperty(key));
      }

      // Now set the public values that existing classes can use to access these, for convenience
      ETHERNET_INTERFACE                   = getStringProperty("ethernetInterface");
      LOAD_FIRST_TIMEOUT_MS                = getIntProperty("loadFirstTimeoutSec") * SECOND_IN_MILLIS;
      LOAD_OTHER_TIMEOUT_MS                = getIntProperty("loadOtherTimeoutSec") * SECOND_IN_MILLIS;
      START_ITERATION_TIMEOUT_MS           = getIntProperty("startIterationTimeoutSec") * SECOND_IN_MILLIS;
      MAX_START_TRIES                      = getIntProperty("maxStartTries");
      TIME_REMAINING_INTERVAL_MS           = getIntProperty("timeRemainingIntervalSec") * SECOND_IN_MILLIS;
      SYNC_WATCHDOG_MS                     = getIntProperty("syncWatchdogSec") * SECOND_IN_MILLIS;
      STOP_TIMEOUT_MS                      = getIntProperty("stopTimeoutSec") * SECOND_IN_MILLIS;
      ARBITRARY_SLEEP_BETWEEN_SETS_MS      = getIntProperty("arbitrarySleepBetweenSetsSec") * SECOND_IN_MILLIS;
      STATE_UNCHANGED_WAIT_MS              = getIntProperty("stateUnchangedWaitSec") * SECOND_IN_MILLIS;
      APPLESCRIPT_TIMEOUT_MS               = getIntProperty("applescriptTimeoutSec") * SECOND_IN_MILLIS;
      VERBOSE                              = getBooleanProperty("verbose");
      DEBUG                                = getBooleanProperty("debug");
      LIVE_QUIT_ITERATION_MS               = getIntProperty("liveQuitIterationSec") * SECOND_IN_MILLIS;
      LIVE_QUIT_MAX_ITER                   = getIntProperty("liveQuitMaxIter");
      KILL_OPEN_SET_PROCESSES_ITERATION_MS = getIntProperty("killOpenSetProcessesIterationSec") * SECOND_IN_MILLIS;
      KILL_OPEN_SET_PROCESSES_MAX_ITER     = getIntProperty("killOpenSetProcessesMaxIter");
      SCREENSHOT_DELAY_MS                  = getIntProperty("screenshotDelaySec") * SECOND_IN_MILLIS;
   }

   private String getStringProperty(String key) {
      // we don't need to separately account for a default value,
      // since this was taken care of when setting up defaultProps and props in setup()
      return props.getProperty(key);
   }

   private int getIntProperty(String key) {
      int value;
      try {
         value = Integer.parseInt(props.getProperty(key));
      } catch (NumberFormatException nfe) {
         try {
            value = Integer.parseInt(defaultProps.getProperty(key));
         } catch (NumberFormatException nfe2) {
            throw new NumberFormatException("Value for property " + key +
                                            " not an int (" + props.getProperty(key) +
                                            "), but neither is the default value either (" + defaultProps.getProperty(key) + ")");
         }
         Logger.warn ("Value for property " + key +
                      " not an int (" + props.getProperty(key) +
                      "), using default value: " + value);
      }
      return value;
   }

   private boolean getBooleanProperty(String key) {
      boolean value;
      try {
         value = Boolean.parseBoolean(props.getProperty(key));
      } catch (NumberFormatException nfe) {
         try {
            value = Boolean.parseBoolean(defaultProps.getProperty(key));
         } catch (NumberFormatException nfe2) {
            throw new NumberFormatException("Value for property " + key +
                                            " not a boolean (" + props.getProperty(key) +
                                            "), but neither is the default value either (" + defaultProps.getProperty(key) + ")");
         }
         Logger.warn ("Value for property " + key +
                      " not an boolean (" + props.getProperty(key) +
                      "), using default value: " + value);
      }
      return value;
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

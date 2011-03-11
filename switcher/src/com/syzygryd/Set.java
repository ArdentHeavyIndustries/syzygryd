package com.syzygryd;

import java.io.IOException;

/**
 * Describes and manages a live set
 *
 */
// XXX using the name "Set" is kind of confusing, given java.util.Set
public class Set {
	//private static OSCSender sender;	// XXX not currently used ?
	private String name = null;
	private String lightingProgram; 
	private int length = 0;
	
	/**
	 * Installs OSCSender that is common to all members of this class
	 * @param s
	 */
	// static void setSender(OSCSender s) {
	// 	sender = s;	// XXX not currently used ?
	// }
	
	/**
	 * Create a new Live set
	 * @param fileName path to live set
	 * @param duration duration of set in seconds
	 */
	public Set(String fileName, int duration, String program) {
		name = fileName;
		length = duration;
		lightingProgram = program;		

		//Logger.debug(this.toString());
	}
	
	/**
	 *
	 * @return Path to live set
	 */
	public String getName() {
		return name;
	}
	
	public String getLightingProgram() {
		return lightingProgram;
	}
	
	/**
	 * 
	 * @return length of set in seconds
	 */
	public int getLength() {
		return length;
	}
	
	public String toString() {
		return "{\"set\":\"" + this.name + "\",\"length\":" + this.length + "}"; 
	}
	
	/**
	 * Opens set using Live
	 */
	public void open()
      throws SwitcherException
   {
      if (ProcessUtils.isOpenSetProcessRunning()) {
         Logger.warn("There is at least one open set process already running.  Will kill before opening a new set.");
         ProcessUtils.killOpenSetProcesses();
      } else {
         Logger.debug("There are no open set processes already running, will proceed with opening a new set.");
      }

      String[] cmd = {"open", getName()};
		Logger.info("Executing \"" + StringUtils.stringArrayToString(cmd) + "\" to play set of length:" + getLength() + " sec.");
      ProcessUtils.doExec(cmd);
	}
	
   /**
    * Starts live playback
    */
   public static void play()
      throws SwitcherException
   {
		//sender.livePlaybackStart();
		AppleScriptRunner.runLiveSpace();
   }

	/**
	 * Pauses live playback
	 */
	public static void stop()
      throws SwitcherException
   {
		//sender.livePlaybackStop();
		AppleScriptRunner.runLiveSpace();
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

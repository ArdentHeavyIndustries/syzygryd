package com.syzygryd;

import java.io.IOException;

/**
 * Describes and manages a live set
 *
 */
public class Set {
	private static OSCSender sender;
	private String name = null;
	private int length = 0;
	
	
	/**
	 * Installs OSCSender that is common to all members of this class
	 * @param s
	 */
	static void setSender(OSCSender s) {
		sender = s;
	}
	
	/**
	 * Create a new Live set
	 * @param fileName path to live set
	 * @param duration duration of set in seconds
	 */
	public Set(String fileName, int duration) {
		name = fileName;
		length = duration;
		
		//System.out.println(this.toString());
	}
	
	/**
	 *
	 * @return Path to live set
	 */
	public String getName() {
		return name;
	}
	
	/**
	 * 
	 * @return length of set in seconds
	 */
	public int getLength() {
		return length;
	}
	
	public String toString() {
		return "set: " + this.name + " length: " + this.length; 
	}
	
	/**
	 * Opens set using Live
	 */
	public void play() {
		System.out.println("Playing " + getName() + " - length:" + getLength() + " sec.");
		
		try {
			Runtime.getRuntime().exec("open \"" + getName() + "\"");
		} catch (IOException e) {
			// NOP
		}
	}
	
	/**
	 * Pauses live playback then quits live
	 */
	public void stop() {
		sender.livePlaybackStop();
		try {
			Thread.sleep(2000); 
		} catch (Exception e) {
			// NOP
		}
		AppleScriptRunner.runLiveQuit();
		try {
			Thread.sleep(2500); 
		} catch (Exception e) {
			// NOP
		}
	}
}

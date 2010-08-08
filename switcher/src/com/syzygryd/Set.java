package com.syzygryd;

import java.io.IOException;

public class Set {
	private static OSCSender sender;
	private String name = null;
	private int length = 0;
	
	
	static void setSender(OSCSender s) {
		sender = s;
	}
	
	public Set(String fileName, int duration) {
		name = fileName;
		length = duration;
		
		//System.out.println(this.toString());
	}
	
	public String getName() {
		return name;
	}
	
	public int getLength() {
		return length;
	}
	
	public String toString() {
		return "set: " + this.name + " length: " + this.length; 
	}
	
	public void play() {
		System.out.println("Playing " + getName() + " - length:" + getLength() + " sec.");
		
		try {
			Runtime.getRuntime().exec("open " + getName());
		} catch (IOException e) {
			// NOP
		}
	}
	
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

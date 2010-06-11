package com.syzygryd;

import java.io.IOException;

import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortOut;

public class Set {
	private String name = null;
	private int length = 0;
	
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
	
	public void stop(OSCPortOut sender) {
		System.out.println("stopping");
		try {
			sender.send(new OSCMessage("/live/stop"));
		} catch (IOException e) {
			// NOP
		}
	}
}

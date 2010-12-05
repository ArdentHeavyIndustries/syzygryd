package com.syzygryd;

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;

import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortOut;

/**
 * Wraps OSC send
 * @author mh
 *
 */
public class OSCSender {
	private OSCPortOut sender;
	public final int OSC_SENDING_PORT;
	private InetAddress addr;
	public static final String MSG_LIVE_PLAY_STOP = "/live/stop";
	public static final String MSG_LIVE_PLAY_START = "/live/play";
	public static final String MSG_SET_TIME_REMAINING = "/syzygryd/remaining";

	OSCSender(InetAddress address, int port) {
		this(port);
		addr = address;
	}

	
	OSCSender(int port) {
		OSC_SENDING_PORT = port;
		try {
			addr =  InetAddress.getLocalHost();
		} catch (UnknownHostException e) {
			// TODO Auto-generated catch block
		}
		init();
	}
	
	/**
	 * sets up sender
	 */
	public void init() {
	
		try {
			sender = new OSCPortOut(addr, OSC_SENDING_PORT);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	/**
	 * tells live to pause output
	 */
	public void livePlaybackStop() {
		System.out.println("Sending OSC message: live stop...");
		send(MSG_LIVE_PLAY_STOP);		
	}
	
	/**
	 * tells live to play audio
	 */
	public void livePlaybackStart() {
		System.out.println("Sending OSC message: live play...");
		send(MSG_LIVE_PLAY_START);		
	}
	
	/**
	 * tells other system components that a set is playing & that it has
	 * some time left
	 * @param set id (index of line in setlist.txt)
	 * @param time milliseconds remaining
	 */
	public void sendTimeRemaining(int time, int set, String lightingProgram) {
		System.out.println("OSC: set " + set + " time remaining " + time + " lightingProgram " + lightingProgram);
		Object[] args = { (Object)time, (Object)set, (Object)lightingProgram};
		send(MSG_SET_TIME_REMAINING, args);
	}
	
	/**
	 * actually sends message.  if live went away, reconnects
	 * @param msg
	 */
	public void send(String msg) {
		send(msg, null);
	}
	
	public void send(String msg, Object[] args) {
		OSCMessage oscmsg;
		if (args != null) {
			oscmsg = new OSCMessage(msg, args);
		} else {
			oscmsg = new OSCMessage(msg);
		}
		
		try {
			sender.send(oscmsg);
		} catch (IOException e) {
			// TODO: reconnect
			// init();
		}
	}
	
}

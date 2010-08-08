package com.syzygryd;

import java.io.IOException;
import java.net.InetAddress;

import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortOut;

public class OSCSender {
	private OSCPortOut sender;
	public static final int OSC_SENDING_PORT = 9000;
	public static final String MSG_LIVE_PLAY_STOP = "/live/stop";
	public static final String MSG_LIVE_PLAY_START = "/live/play";
	
	OSCSender() {
		init();
	}
	
	/**
	 * sets up sender
	 */
	public void init() {
	
		try {
			sender = new OSCPortOut(InetAddress.getLocalHost(), OSC_SENDING_PORT);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public void livePlaybackStop() {
		send(MSG_LIVE_PLAY_STOP);		
	}
	
	public void livePlaybackStart() {
		send(MSG_LIVE_PLAY_START);		
	}
	
	/**
	 * actually sends message.  if live went away, reconnects
	 * @param msg
	 */
	public void send(String msg) {
		try {
			sender.send(new OSCMessage(msg));
		} catch (IOException e) {
			// TODO: reconnect
			// init();
		}
	}
	
}

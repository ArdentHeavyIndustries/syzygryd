package com.syzygryd;

import java.io.IOException;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.Date;

import com.illposed.osc.OSCListener;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortIn;
import com.illposed.osc.OSCPortOut;

public class Switcher {

	public static final int LISTENING_PORT = 9001;
	public static final int SENDING_PORT = 9000;
	public static final int ARG_SETLISTFILENAME = 0;
	private static Setlist list = null;
	private static int SECOND_IN_MILLIS = 1000;
	private static OSCPortOut sender = null;
	private static OSCPortIn portIn = null;
	
	
	public static void main(String[] args) {
		if (args.length != 1) {
			System.err.println("usage: java Switcher <list-filename>.");
			System.exit(-1);
		}
		
		// attempt to load setlist
		try {
			list = new Setlist(args[ARG_SETLISTFILENAME]);
		} catch (Exception e) {
			System.err.println("Unable to load setlist.");
			System.err.println(e.getMessage());
			System.exit(-1);
		}
		
		// setup sender
		try {
			sender = new OSCPortOut(InetAddress.getLocalHost(), SENDING_PORT);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		setupOSCListener();
		
		// for infinity, play the next song, then sleep.
		while(true) {
			Set s = list.getNext();
			s.play();
		
			try {
				Thread.sleep(SECOND_IN_MILLIS * s.getLength());
			} catch (InterruptedException e) {
				// NIL;
			}
			s.stop(sender);
			try {
				Thread.sleep(SECOND_IN_MILLIS * 3);
			} catch (InterruptedException e) {
				// NIL;
			}
		}
		
	}
	
	public static void setupOSCListener() {
		
		// if we're already connected, then stop listening & close socket
		if (portIn != null) {
			portIn.stopListening();
			portIn.close();
		}
		
		try {
			portIn = new OSCPortIn(LISTENING_PORT);
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			System.err.println("Unable to open port " + LISTENING_PORT + "for listening.\n"
					+ "It's possible that there's another copy of this running, or there's another\n"
					+ "program listening on port " + LISTENING_PORT + ".  Use netstat to figure out\n"
					+ "if someone's listening, and use ps or Activity Monitor to see if there's another\n"
					+ "copy of this running. (hint: the process name will be java).  Thanks for playing!");
			e.printStackTrace();
			System.exit(-1);
		} 
		
		portIn.addListener("/remix/echo", setLoadedListener);
		portIn.startListening();
		System.out.println("Now listening on port " + LISTENING_PORT);
		
		
	}

	public static OSCListener setLoadedListener = new OSCListener() {
		
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
			System.out.println("Live tells us that the set loaded: " + message.getAddress());
			try {
				sender.send(new OSCMessage("/live/play"));
			} catch (IOException e) {
				// TODO Auto-generated catch block
				System.err.println("Couldn't send play message.");
				e.printStackTrace();
				System.exit(-1);
			}
		}
	};
}

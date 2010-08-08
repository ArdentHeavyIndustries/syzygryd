package com.syzygryd;

import java.io.IOException;
import java.net.SocketException;
import java.util.Date;

import com.illposed.osc.OSCListener;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortIn;

public class Switcher {

	public static final int OSC_LISTENING_PORT = 9001;
	public static final int WEB_SENDING_PORT = 31337;
	
	public static final int ARG_SETLISTFILENAME = 0;
	private static OSCSender sender = null;
	private static Setlist list = null;
	private static OSCPortIn portIn = null;
	private static ActionRunner ar = null;
	
	
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
		// install setlist
		ActionSetPlay.setList(list);
		
		// setup sender
		try {
			sender = new OSCSender();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		// install sender
		// TODO: after quitting live is implemented, sender will
		// need to be reset
		Set.setSender(sender);

		setupOSCListener();

		// setup switcher queue thread
		ar = new ActionRunner();

		// start it
		ar.run();
		
		// setup webserver
		try {
			@SuppressWarnings("unused")
			Syzyweb web = new Syzyweb(WEB_SENDING_PORT, ar);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		// wait forever.
		try {
			ar.join();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	public static void setupOSCListener() {
		
		// if we're already connected, then stop listening & close socket
		if (portIn != null) {
			portIn.stopListening();
			portIn.close();
		}
		
		try {
			portIn = new OSCPortIn(OSC_LISTENING_PORT);
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			System.err.println("Unable to open port " + OSC_LISTENING_PORT + "for listening.\n"
					+ "It's possible that there's another copy of this running, or there's another\n"
					+ "program listening on port " + OSC_LISTENING_PORT + ".  Use netstat to figure out\n"
					+ "if someone's listening, and use ps or Activity Monitor to see if there's another\n"
					+ "copy of this running. (hint: the process name will be java).  Thanks for playing!");
			e.printStackTrace();
			System.exit(-1);
		} 
		
		portIn.addListener("/remix/echo", setLoadedListener);
		portIn.startListening();
		System.out.println("Now listening on port " + OSC_LISTENING_PORT);
		
		
	}

	public static OSCListener setLoadedListener = new OSCListener() {
		
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
			System.out.println("Live tells us that the set loaded: " + message.getAddress());
			try {
				sender.livePlaybackStart();
				ar.actionLoaded();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				System.err.println("Couldn't send play message.");
				e.printStackTrace();
				System.exit(-1);
			}
		}
	};
}

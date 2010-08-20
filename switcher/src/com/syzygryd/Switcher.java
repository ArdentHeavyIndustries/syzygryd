package com.syzygryd;

import java.io.IOException;
import java.net.SocketException;
import java.util.Date;

import com.illposed.osc.OSCListener;
import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortIn;

/**
 * The main class for the set switching software
 *
 */
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
		
		System.out.println("Loading setlist...");
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
		
		System.out.println("Setting up OSC sender...");
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
		
		System.out.println("Setting up OSC listener...");
		setupOSCListener();

		// setup switcher queue thread
		System.out.println("Starting ActionRunner...");
		ar = new ActionRunner();

		// start it
		ar.start();
		
		System.out.println("Starting webserver...");
		// setup webserver
		try {
			@SuppressWarnings("unused")
			Syzyweb web = new Syzyweb(WEB_SENDING_PORT, ar, list);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		System.out.println("Running.");
		// wait forever.
		try {
			ar.join();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
	
	/**
	 * Opens socket to listen for Live OSC events
	 */
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
		portIn.addListener("/live/play", setStoppedListener);
		portIn.startListening();
		System.out.println("Now listening on port " + OSC_LISTENING_PORT);
		
		
	}

	/**
	 * Listens for set loaded event from Live; when it is loaded, sends
	 * play event to live & tells ActionRunner that loading has finished
	 */
	public static OSCListener setLoadedListener = new OSCListener() {
		
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
			System.out.println("Live tells us that the set loaded: " + message.getAddress());
			try {
				//sender.livePlaybackStart();
				AppleScriptRunner.runLiveSpace();
				ar.actionLoaded();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				System.err.println("Couldn't send play message.");
				e.printStackTrace();
				System.exit(-1);
			}
		}
	};
	
	public static OSCListener setStoppedListener = new OSCListener() {
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
			Integer state = (Integer)(message.getArguments()[0]);
			System.out.println("Live tells us that the set play state is: " + state);
			if (!(ar.isPlaying()) && state == 1) {
				try {
					AppleScriptRunner.runLiveQuit();
					ar.actionEnded();
				} catch (Exception e) {
					System.err.println("Couldn't send quit.");
					e.printStackTrace();
				}
			} else {
				System.out.println("State is not playing: " + state);
			}
		}
	};
}

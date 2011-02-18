package com.syzygryd;

import java.io.IOException;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
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
	public static final int OSC_SENDING_PORT_LIVE = 9000;
	
	/**
	 * ports for the rest of the system
	 */
	public static final int OSC_SENDING_PORT_SEQUENCER = 9999;
	public static final int OSC_SENDING_PORT_LIGHTING = 9002;
	public static final int OSC_SENDING_PORT_BROADCAST = 9002;
   /*public static final int OSC_SENDING_PORT_CONTROLLER = 9000;*/
	public static InetAddress OSC_BROADCAST_ADDRESS = null;

	
	public static final int WEB_SENDING_PORT = 31337;
	
	public static final int ARG_SETLISTFILENAME = 0;
	private static OSCSender senderLive = null;
	
	private static OSCSender senderSequencer = null;
	private static OSCSender senderLighting = null;
	private static OSCSender senderController = null;
	private static OSCSender senderBroadcast = null;
	
	private static Setlist list = null;
	private static OSCPortIn portIn = null;
	private static ActionRunner ar = null;
	
	
	public static void main(String[] args) {
		
		if (args.length != 1) {
			Logger.warn("usage: java Switcher <list-filename>.");
			System.exit(-1);
		}
		
		Logger.info("Loading setlist...");
		// attempt to load setlist
		try {
			list = new Setlist(args[ARG_SETLISTFILENAME]);
		} catch (Exception e) {
			Logger.warn("Unable to load setlist.");
			Logger.warn(e.getMessage());
			System.exit(-1);
		}
		// install setlist
		ActionSetPlay.setList(list);
		
		Logger.info("Setting up OSC sender to live...");
		// setup sender
		try {
			senderLive = new OSCSender(OSC_SENDING_PORT_LIVE);
		} catch (Exception e) {
			Logger.warn(e);
		}
		
		// install sender for live
		// TODO: after quitting live is implemented, sender will
		// need to be reset.  or not!
		Set.setSender(senderLive);
		
		try {
			OSC_BROADCAST_ADDRESS = InetAddress.getByName("255.255.255.255");
		} catch (UnknownHostException e1) {
			// TODO Auto-generated catch block
			Logger.warn(e1);
		}
		// create senders for controller, lighting, and sequencer
		senderSequencer = new OSCSender(OSC_SENDING_PORT_SEQUENCER);
		senderBroadcast = new OSCSender(OSC_BROADCAST_ADDRESS, OSC_SENDING_PORT_BROADCAST);
		
		//senderLighting = new OSCSender(OSC_SENDING_PORT_LIGHTING);
		
		/*senderController = new OSCSender(OSC_SENDING_PORT_CONTROLLER);
		*/
		OSCSender[] statusRecipients = { senderSequencer, senderBroadcast /*, senderLighting, senderController*/ };
		
		Logger.info("Setting up OSC listener...");
		setupOSCListener();

		// setup switcher queue thread
		Logger.info("Starting ActionRunner...");
		ar = new ActionRunner();
		ar.setStatusRecipients(statusRecipients);
		
		// start it
		ar.start();
		
		Logger.info("Starting webserver...");
		// setup webserver
		try {
			@SuppressWarnings("unused")
			Syzyweb web = new Syzyweb(WEB_SENDING_PORT, ar, list);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			Logger.warn(e);
		}
		
		Logger.info("Running.");
		// wait forever.
		try {
			ar.join();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			Logger.warn(e);
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
			Logger.warn("Unable to open port " + OSC_LISTENING_PORT + "for listening.\n"
					+ "It's possible that there's another copy of this running, or there's another\n"
					+ "program listening on port " + OSC_LISTENING_PORT + ".  Use netstat to figure out\n"
					+ "if someone's listening, and use ps or Activity Monitor to see if there's another\n"
					+ "copy of this running. (hint: the process name will be java).  Thanks for playing!");
			Logger.warn(e);
			System.exit(-1);
		} 
		
		portIn.addListener("/remix/echo", setLoadedListener);
		portIn.addListener("/live/play", setStoppedListener);
		portIn.startListening();
		Logger.info("Now listening on port " + OSC_LISTENING_PORT);
		
		
	}

	/**
	 * Listens for set loaded event from Live; when it is loaded, sends
	 * play event to live & tells ActionRunner that loading has finished
	 */
	public static OSCListener setLoadedListener = new OSCListener() {
		
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
			Logger.info("Live tells us that the set loaded: " + message.getAddress());
			try {
				//sender.livePlaybackStart();
				AppleScriptRunner.runLiveEnter();
				AppleScriptRunner.runLiveSpace();
				ar.actionLoaded();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				Logger.warn("Couldn't send play message.");
				Logger.warn(e);
				System.exit(-1);
			}
		}
	};
	
	public static OSCListener setStoppedListener = new OSCListener() {
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
			Integer state = (Integer)(message.getArguments()[0]);
			Logger.info("Live tells us that the set play state is: " + state);
			if (!(ar.isPlaying()) && state == 1) {
				try {
					//AppleScriptRunner.runLiveQuit();
					Logger.info("Switcher has finished playing, and Live says we're stopped.  Set ending complete; continuing.");
					ar.actionEnded();
				} catch (Exception e) {
					Logger.warn("Couldn't send quit.");
					Logger.warn(e);
				}
			} else {
				Logger.info("State is not playing: " + state);
			}
		}
	};
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

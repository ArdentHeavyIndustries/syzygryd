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
	//public static final int OSC_SENDING_PORT_LIVE = 9000;	// XXX not really used?

   // see http://monome.q3f.org/browser/trunk/LiveOSC/OSCAPI.txt
   private static final String MSG_LIVE_SET_LOADED = "/remix/echo";
   // which (play or stop) depends on the state
   private static final String MSG_LIVE_SET_PLAYING_OR_STOPPED = "/live/play";
   private static final int LIVE_STATE_STOPPED = 1;
   private static final int LIVE_STATE_PLAYING = 2;
   private static int currentLiveState = -1;

	/**
	 * ports for the rest of the system
	 */
	//public static final int OSC_SENDING_PORT_SEQUENCER = 9999;
	//public static final int OSC_SENDING_PORT_LIGHTING = 9002;
	public static final int OSC_SENDING_PORT_BROADCAST = 9002;
   /*public static final int OSC_SENDING_PORT_CONTROLLER = 9000;*/

	public static InetAddress OSC_BROADCAST_ADDRESS = null;
	
	public static final int WEB_SENDING_PORT = 31337;
	
	public static final int ARG_SETLISTFILENAME = 0;
	//private static OSCSender senderLive = null;	// XXX not really used
	//private static OSCSender senderSequencer = null;
	//private static OSCSender senderLighting = null;
	//private static OSCSender senderController = null;
	private static OSCSender senderBroadcast = null;
	
	private static Setlist list = null;
	private static OSCPortIn portIn = null;
	private static ActionRunner ar = null;
	
	public static void main(String[] args) {

      Logger.info("****************************************");
      Logger.info("STARTING SWITCHER");

      // System.out.println("test stdout");
      // System.err.println("test stderr");
      // Logger.debug("test debug");
      // Logger.info("test info");
      // Logger.warn("test warn");
		
		if (args.length != 1) {
			Logger.warn("usage: java Switcher <list-filename>.");
			System.exit(-1);
		}

      String setlistFilename = args[ARG_SETLISTFILENAME];
		Logger.info("Loading setlist from " + setlistFilename);
		// attempt to load setlist
		try {
			list = new Setlist(setlistFilename);
		} catch (Exception e) {
			Logger.warn("Unable to load setlist.");
			Logger.warn(e.getMessage());
			System.exit(-1);
		}
		// install setlist
		ActionSetPlay.setList(list);
		
		// setup sender
      String localhost;
      try {
         localhost = InetAddress.getLocalHost().getHostAddress();
      } catch (UnknownHostException uhe) {
         // this really probably is a bad sign, even if it's just for a log msg
         Logger.warn ("Unable to get local host address, things are probably pretty hosed", uhe);
         localhost = "localhost";
      }
      
		// Logger.info("Setting up (unused?) OSC sender to Live on " + localhost + ":" + OSC_SENDING_PORT_LIVE);
		// try {
		// 	senderLive = new OSCSender(OSC_SENDING_PORT_LIVE);
		// } catch (Exception e) {
		// 	Logger.warn(e);
		// }
		
		// // install sender for live
		// // TODO: after quitting live is implemented, sender will
		// // need to be reset.  or not!
		// Set.setSender(senderLive);
		
		try {
			OSC_BROADCAST_ADDRESS = InetAddress.getByName("255.255.255.255");
		} catch (UnknownHostException uhe) {
			// TODO Auto-generated catch block
			Logger.warn(uhe);
		}
		// create senders for controller, lighting, and sequencer
		//Logger.info("Setting up OSC sender to sequencer to " + InetAddress.getLocalHost().getHostAddress() + ":" + OSC_SENDING_PORT_SEQUENCER);
		//senderSequencer = new OSCSender(OSC_SENDING_PORT_SEQUENCER);
		Logger.info("Setting up OSC broadcast sender to " +  OSC_BROADCAST_ADDRESS.getHostAddress() + ":" + OSC_SENDING_PORT_BROADCAST);
		senderBroadcast = new OSCSender(OSC_BROADCAST_ADDRESS, OSC_SENDING_PORT_BROADCAST);
		
		//senderLighting = new OSCSender(OSC_SENDING_PORT_LIGHTING);
		
		/*senderController = new OSCSender(OSC_SENDING_PORT_CONTROLLER);
		*/
      // XXX this is stupid now that there's just one, we should get rid of the array and just use a single OSCSender
		OSCSender[] statusRecipients = { /* senderSequencer, */ senderBroadcast /*, senderLighting, senderController*/ };
		
		Logger.info("Setting up OSC listener on port " + OSC_LISTENING_PORT);
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
		} catch (IOException ioe) {
			// TODO Auto-generated catch block
         // XXX should we exit if this happens?
			Logger.warn("Webserver failed to start: " + ioe);
		}
		
		Logger.info("Running.");
		// wait forever.
		try {
			ar.join();
		} catch (InterruptedException ie) {
			// TODO Auto-generated catch block
			Logger.warn(ie);
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
		} catch (SocketException se) {
			// TODO Auto-generated catch block
			Logger.warn("Unable to open port " + OSC_LISTENING_PORT + " for listening.\n"
					+ "It's possible that there's another copy of this running, or there's another\n"
					+ "program listening on port " + OSC_LISTENING_PORT + ".  Use netstat to figure out\n"
					+ "if someone's listening, and use ps or Activity Monitor to see if there's another\n"
					+ "copy of this running. (hint: the process name will be java).  Thanks for playing!");
			Logger.warn(se);
			System.exit(-1);
		} 
		
		portIn.addListener("/remix/echo", setLoadedListener);
		portIn.addListener("/live/play", setStoppedListener);
		portIn.startListening();
		Logger.info("Now listening on port " + OSC_LISTENING_PORT);
      Logger.info("Listing for OSC messages: \"/remix/echo\" and \"/live/play\"");
	}

	/**
	 * Listens for set loaded event from Live; when it is loaded, sends
	 * play event to live & tells ActionRunner that loading has finished
	 */
	public static OSCListener setLoadedListener = new OSCListener() {
		
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
         Logger.info("Set loaded listener received OSC message from Live: " + message.getAddress());
			//try {
				//sender.livePlaybackStart();
				//AppleScriptRunner.runLiveEnter();
            // XXX yes, we should do this, but elsewhere
				//AppleScriptRunner.runLiveSpace();
				ar.actionLoaded();
			// } catch (Exception e) {
			// 	// TODO Auto-generated catch block
			// 	Logger.warn("Couldn't send play message.");
			// 	Logger.warn(e);
			// 	System.exit(-1);
			// }
		}
	};
	
	public static OSCListener setStoppedListener = new OSCListener() {
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
         Logger.info("Set stopped listener (somewhat poorly named) received OSC message from Live: " + message.getAddress());
			Integer state = (Integer)(message.getArguments()[0]);
         switch (state)
            {
            case LIVE_STATE_STOPPED:
               Logger.info("Live state is STOPPED: " + state);
               ar.actionStopped();
               break;
            case LIVE_STATE_PLAYING:
               Logger.info("Live state is PLAYING: " + state);
               ar.actionStarted();
               break;
            default:
               Logger.warn("Unexpected Live state (neither STOPPED nor PLAYING): " + state);
            }
			Logger.info("Live tells us that the set play state is: " + state);
         // save this for use in ActionRunner.doStart();
         Switcher.currentLiveState = state;
		}
	};

   public static boolean isLivePlaying() {
      return Switcher.currentLiveState == LIVE_STATE_PLAYING;
   }

   public static boolean isLiveStopped() {
      return Switcher.currentLiveState == LIVE_STATE_STOPPED;
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

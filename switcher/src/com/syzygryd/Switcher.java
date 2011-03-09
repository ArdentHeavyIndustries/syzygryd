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

	private static final int OSC_LISTENING_PORT_LIVE = 9001;
	//private static final int OSC_SENDING_PORT_LIVE = 9000;	// XXX not really used?

   // the sequencer normally broadcasts on 9002.  but we can't listen
   // on 9002 for /sync, b/c ShowControl is running on this same host
   // and already listening on that port.  so now the sequencer also
   // sends /sync msgs (and nothing else) on port 9003, just for the
   // switcher.
   private static final int OSC_LISTENING_PORT_SEQUENCER = 9003;

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
	//private static final int OSC_SENDING_PORT_SEQUENCER = 9999;
	//private static final int OSC_SENDING_PORT_LIGHTING = 9002;
	private static final int OSC_SENDING_PORT_BROADCAST = 9002;
   /*private static final int OSC_SENDING_PORT_CONTROLLER = 9000;*/

	private static InetAddress OSC_BROADCAST_ADDRESS = null;
	
	private static final int WEB_PORT = 31337;
	
	private static final int ARG_SETLISTFILENAME = 0;
	//private static OSCSender senderLive = null;	// XXX not really used
	//private static OSCSender senderSequencer = null;
	//private static OSCSender senderLighting = null;
	//private static OSCSender senderController = null;
	private static OSCSender senderBroadcast = null;
	
	private static Setlist list = null;
	private static OSCPortIn portInLive = null;
	private static OSCPortIn portInSequencer = null;
	private static ActionRunner ar = null;

   // -1 means we're not listening for sync,
   // 0 means we're reset and listening for our first sync,
   // otherwise, this is the actual time of the last sync
   // XXX both the way this is defined, and the way it is used in ActionRunner, is not very OO
   protected static long lastSyncMs = -1;
	
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

      Logger.info("Setting up properties");
      Config config = new Config();
      config.setupProps();

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
			OSC_BROADCAST_ADDRESS = InetAddress.getByName(Config.BROADCAST_IP_ADDR);
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
		
		Logger.info("Setting up OSC listeners");
		setupOSCListeners();

		// setup switcher queue thread
		Logger.info("Starting ActionRunner...");
		ar = ActionRunner.getInstance();
		ar.setStatusRecipients(statusRecipients);
		
		// start it
		ar.start();
		
		Logger.info("Starting webserver...");
		// setup webserver
		try {
			@SuppressWarnings("unused")
			Syzyweb web = new Syzyweb(WEB_PORT, ar, list);
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
	 * Set up the various OSC listeners
	 */
	private static void setupOSCListeners() {
      Logger.info("Setting up OSC listener for Live");
      setupOSCListener(Switcher.portInLive,
                       OSC_LISTENING_PORT_LIVE,
                       new OSCListener[] { Switcher.setLoadedListener, Switcher.setStoppedListener },
                       new String[]      { "/remix/echo",              "/live/play" });

      Logger.info("Setting up OSC listener for the sequencer");
      setupOSCListener(Switcher.portInSequencer,
                       OSC_LISTENING_PORT_SEQUENCER,
                       Switcher.syncListener,
                       "/sync");
	}

	/**
	 * Opens socket to listen for OSC events
    * The listeners[] and oscMessages[] arrays are paired;
    * for each listener[i], the corresponding OSC message is oscMessages[i]
	 */
	private static void setupOSCListener(OSCPortIn portIn, int port, OSCListener[] listeners, String[] oscMessages) {

      if (listeners.length != oscMessages.length) {
         Logger.warn("Setting up OSC listeners on port " + port + ", but you have specified " + listeners.length
                     + " OSCListener's and " + oscMessages.length + " messages.  These must be the same!!!");
         System.exit(-1);
      }
      int length = listeners.length;
		
		// if we're already connected, then stop listening & close socket
		if (portIn != null) {
			portIn.stopListening();
			portIn.close();
		}
		
		try {
			portIn = new OSCPortIn(port);
		} catch (SocketException se) {
			Logger.warn("Unable to open port " + port + " for listening.\n"
                     + "It's possible that there's another copy of this running, or there's another\n"
                     + "program listening on port " + port + ".  Use netstat to figure out\n"
                     + "if someone's listening, and use ps or Activity Monitor to see if there's another\n"
                     + "copy of this running. (hint: the process name will be java).  Thanks for playing!");
			Logger.warn(se);
			System.exit(-1);
		} 

      for (int i = 0; i < length; i++) {
         Logger.info("Listening for OSC message: \"" + oscMessages[i] + "\"");
         portIn.addListener(oscMessages[i], listeners[i]);
      }
		portIn.startListening();
		Logger.info("Now listening on port " + port);
	}

   /**
    * Convenience method when there is only one listener
    */
   private static void setupOSCListener(OSCPortIn portIn, int port, OSCListener listener, String oscMessage) {
      setupOSCListener(portIn,
                       port,
                       new OSCListener[] { listener },
                       new String[] { oscMessage });
   }

	/**
	 * Listens for set loaded event from Live; when it is loaded,
	 * tells ActionRunner that loading has finished.
	 */
	private static OSCListener setLoadedListener = new OSCListener() {
		@Override
		public void acceptMessage(Date time, OSCMessage message) {
         Logger.info("Set loaded listener received OSC message from Live: " + message.getAddress());
         ar.actionLoaded();
		}
	};
	
	/**
	 * Listens for playing/stopped events from Live; when received,
	 * tells ActionRunner that playing has started/stopped, and records current state.
	 */
	private static OSCListener setStoppedListener = new OSCListener() {
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

   /**
    * Record when we get a /sync message from the sequencer.
    */
   private static OSCListener syncListener = new OSCListener() {
      @Override
      public void acceptMessage(Date time, OSCMessage message) {
         if (Switcher.lastSyncMs > 0) {
            // when we're waiting for this and expecting it, we don't want to log every msg, that would be WAY too much
            Switcher.lastSyncMs = System.currentTimeMillis();
         } else if (Switcher.lastSyncMs == 0) {
            // first msg when we're waiting
            Logger.info("Received first sync msg from sequencer when we're waiting for it");
            Switcher.lastSyncMs = System.currentTimeMillis();
         } else {
            // -1.  unexpected, so don't update lastSyncMs
            Logger.debug("Received sync msg from sequencer when we're not waiting for it.  While not ideal, this is okay.");
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

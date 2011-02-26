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
	private InetAddress addr;
   private int port;
	// public static final String MSG_LIVE_PLAY_STOP = "/live/stop";
	// public static final String MSG_LIVE_PLAY_START = "/live/play";
	public static final String MSG_SET_TIME_REMAINING = "/timeRemaining";

	OSCSender(InetAddress addr, int port) {
      if (addr == null) {
         try {
            addr = InetAddress.getLocalHost();
         } catch (UnknownHostException uhe) {
            Logger.warn ("Unable to get local host address, things are probably pretty hosed", uhe);
         }
      }

      this.addr = addr;
      this.port = port;

      init();
	}

   // addr defaults to localhost
	OSCSender(int port) {
      this(null, port);
	}
	
	/**
	 * sets up sender
	 */
	public void init() {
	
		try {
         Logger.info ("Configuring OSC port out to " + addr + ":" + port);
			sender = new OSCPortOut(addr, port);
		} catch (Exception e) {
			Logger.warn(e);
		}
	}
	
	/**
	 * tells live to pause output
	 */
   // XXX not used
	// public void livePlaybackStop() {
	// 	Logger.info("Sending OSC message: live stop...");
	// 	send(MSG_LIVE_PLAY_STOP);		
	// }
	
	/**
	 * tells live to play audio
	 */
   // XXX not used
	// public void livePlaybackStart() {
	// 	Logger.info("Sending OSC message: live play...");
	// 	send(MSG_LIVE_PLAY_START);		
	// }
	
	/**
	 * tells other system components that a set is playing & that it has
	 * some time left
	 * @param set id (index of line in setlist.txt)
	 * @param time milliseconds remaining
	 */
	public void sendTimeRemaining(int time, int set, String lightingProgram) {
      Logger.info("OSC: time remaining " + time + " set " + set + " lightingProgram " + lightingProgram);
      // XXX NO, the controller is expecting a message with only one arg, the time !!!
		//Object[] args = { (Object)time, (Object)set, (Object)lightingProgram};
		//send(MSG_SET_TIME_REMAINING, args);
		send(MSG_SET_TIME_REMAINING, time);
	}
	
	/**
	 * actually sends message.
    * if live went away, reconnects (XXX NO, we're not not currently doing that)
	 * @param msg
	 */
	public void send(String msg) {
		send(msg, null);
	}

   public void send(String msg, Object arg) {
      Object[] args = { arg };
      send(msg, args);
   }

	public void send(String msg, Object[] args) {
      Logger.info("Sending OSC messaage \"" + msg + "\" with " + (args == null ? "0" : args.length) + " args to " + addr.getHostAddress() + ":" + port);
		OSCMessage oscmsg;
		if (args != null) {
			oscmsg = new OSCMessage(msg, args);
		} else {
			oscmsg = new OSCMessage(msg);
		}
		
		try {
			sender.send(oscmsg);
		} catch (IOException ioe) {
         Logger.warn("Exception sending OSC message", ioe);
			// TODO: reconnect
			// init();
		}
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

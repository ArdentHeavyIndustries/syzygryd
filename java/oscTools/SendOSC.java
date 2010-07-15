/* -*- mode: java; c-basic-offset: 3; indent-tabs-mode: nil -*- */

import oscP5.*;
import netP5.*;

// /cygdrive/c/Program\ Files/Java/jdk1.6.0_20/bin/javac.exe -cp ../../processing/libraries/oscP5/library/oscP5.jar SendOSC.java
// java -cp `cygpath -wp .:processing/core:../../processing/libraries/oscP5/library/oscP5.jar` SendOSC localhost 8001 /2_modulator/modulation6 0.5

public class SendOSC
{
   NetAddress oscSender_;
   OscP5 oscP5_;

   public SendOSC(String host, int port) {
      System.out.println("Creating new OSC sender to " + host + ":" + port);
      oscSender_ = new NetAddress(host, port);
      // XXX really we're just sending, not listening
      // but it makes us specify a listening port
      // if we give the same port, it complains as follows:
      //    ### [2010/7/14 23:37:10] ERROR @ UdpServer.start()  IOException, couldnt create new DatagramSocket @ port 9001 java.net.BindException: Address already in use: Cannot bind
      // which really isn't a big deal, but avoid it by just going one higher
      oscP5_ = new OscP5(this, port + 1);
   }

   // XXX for now assume only floats
   public void send(String address, float value) {
      System.out.println("Sending OSC: " + address + " " + value);
      OscMessage message = new OscMessage(address);
      message.add(value);
      oscP5_.send(message, oscSender_);
   }

   // XXX not literal, given java classpath crap
   private static void usage() {
      System.err.println("usage: SendOSC <host> <port> <address> <value>");
      System.exit(1);
   }

   public static void main(String[] args) {
      if (args.length == 4) {
         try {
            String host = args[0];
            int port = Integer.parseInt(args[1]);
            String address = args[2];
            // XXX for now assume only floats
            float value = Float.parseFloat(args[3]);

            SendOSC sendOSC = new SendOSC(host, port);
            sendOSC.send(address, value);
         } catch (NumberFormatException nfe) {
            usage();
         }
      } else {
         usage();
      }

      System.exit(0);
   }
}
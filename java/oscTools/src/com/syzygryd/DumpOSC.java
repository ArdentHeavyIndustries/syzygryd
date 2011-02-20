package com.syzygryd;

import oscP5.*;

/* For inspiration (but a complete clone is not necessarily a goal), see:
 *   http://archive.cnmat.berkeley.edu/OpenSoundControl/dumpOSC.html
 */
public class DumpOSC
   implements OscEventListener
{
   // constructor
   public DumpOSC(int port) {
      OscP5 oscP5 = new OscP5(/* parent */ this, port);
   }
   
   /* OscEventListener */
   public void oscEvent(OscMessage message) {
      //System.out.println("oscEvent(): " + message.addrPattern() + " " + message.typetag() + " " + message.toString());
      // XXX this really ought to be generalized by type for each value, then iterate through the msg
      if ("f".equals(message.typetag())) {
         String address = message.addrPattern();
         float value = message.get(0).floatValue();
         System.out.println("Received OSC: " + address + " " + value);
      } else if ("ff".equals(message.typetag())) {
         String address = message.addrPattern();
         float value1 = message.get(0).floatValue();
         float value2 = message.get(1).floatValue();
         System.out.println("Received OSC: " + address + " " + value1 + " " + value2);
      } else if ("fff".equals(message.typetag())) {
         String address = message.addrPattern();
         float value1 = message.get(0).floatValue();
         float value2 = message.get(1).floatValue();
         float value3 = message.get(2).floatValue();
         System.out.println("Received OSC: " + address + " " + value1 + " " + value2 + " " + value3);
      } else if ("i".equals(message.typetag())) {
         String address = message.addrPattern();
         int value = message.get(0).intValue();
         System.out.println("Received OSC: " + address + " " + value);
      } else if ("ii".equals(message.typetag())) {
         String address = message.addrPattern();
         int value1 = message.get(0).intValue();
         int value2 = message.get(1).intValue();
         System.out.println("Received OSC: " + address + " " + value1 + " " + value2);
      } else if ("iii".equals(message.typetag())) {
         String address = message.addrPattern();
         int value1 = message.get(0).intValue();
         int value2 = message.get(1).intValue();
         int value3 = message.get(2).intValue();
         System.out.println("Received OSC: " + address + " " + value1 + " " + value2 + " " + value3);
      } else {
         System.err.println("WARNING: for now, only one, two, or three all float(s) or all int(s) supported, not " + message.typetag() + ": " + message.addrPattern());
      }
   }
   
   /* OscEventListener */
   public void oscStatus(OscStatus status) {
      System.out.println("oscStatus(): " + status.id());
   }

   // XXX not literal, given java classpath crap
   private static void usage() {
      System.err.println("usage: DumpOsc <port>");
      System.exit(1);
   }

   public static void main(String[] args) {
      if (args.length == 1) {
         try {
            int port = Integer.parseInt(args[0]);
            System.out.println("Listening for OSC messages on port " + port);
            //MyOscEventListener oscEventListener = new MyOscEventListener(port);
            DumpOSC dumpOSC = new DumpOSC(port);
         } catch (NumberFormatException nfe) {
            usage();
         }
      } else {
         usage();
      }

      // loop endlessly
      while (true) {
         try {
            Thread.sleep(60000);
         } catch (InterruptedException ie) {
         }
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

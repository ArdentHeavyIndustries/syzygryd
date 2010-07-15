/* -*- mode: java; c-basic-offset: 3; indent-tabs-mode: nil -*- */

// mkdir build
// /cygdrive/c/Program\ Files/Java/jdk1.6.0_20/bin/javac.exe -cp ../../processing/libraries/oscP5/library/oscP5.jar -d build DumpOSC.java 
//
// /cygdrive/c/Program\ Files/Java/jdk1.6.0_20/bin/javac.exe -cp ../../processing/libraries/oscP5/library/oscP5.jar DumpOSC.java 
// /cygdrive/c/Program\ Files/Java/jdk1.6.0_20/bin/java.exe -cp .:../../processing/libraries/oscP5/library/oscP5.jar syzygyrd.DumpOSC
// /cygdrive/c/Program\ Files/Java/jdk1.6.0_20/bin/java.exe -cp .:../../processing/libraries/oscP5/library/oscP5.jar DumpOSC

// XXX this is insane:
// processing is needed solely b/c the OscP5 is looking for (parent instanceof PApplet)

// $ java -cp `cygpath -wp .:../../processing/libraries/oscP5/library/oscP5.jar` DumpOSC 9001
// http://www.experts-exchange.com/Software/CYGWIN/Q_24100654.html
// http://www.inonit.com/cygwin/faq/
// http://www.cygwin.com/ml/cygwin/2001-08/msg01300.html
// http://narencoolgeek.blogspot.com/2005/07/java-classpaths-on-cygwin.html
// http://www.experts-exchange.com/Software/CYGWIN/Q_24100654.html

// this ultimately worked
// /cygdrive/c/Program\ Files/Java/jdk1.6.0_20/bin/javac.exe -cp ../../processing/libraries/oscP5/library/oscP5.jar DumpOSC.java
// java -cp `cygpath -wp .:processing/core:../../processing/libraries/oscP5/library/oscP5.jar` DumpOSC 9001

//package syzygryd;

import oscP5.*;
//import processing.core.PApplet;

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
      // XXX for now just support a single float
      if ("f".equals(message.typetag())) {
         String address = message.addrPattern();
         float value = message.get(0).floatValue();
         System.out.println("Received OSC: " + address + " " + value);
      } else {
         System.err.println("WARNING: for now, only a single float supported, not " + message.typetag() + ": " + message.addrPattern());
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


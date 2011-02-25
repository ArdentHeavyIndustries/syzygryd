package com.syzygryd;

import oscP5.*;

import java.util.Calendar;

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
      StringBuilder sb = new StringBuilder();
      sb.append("Received OSC: ");
      sb.append(message.addrPattern());
      sb.append(" [");
      sb.append(message.typetag());
      sb.append("]");

      for (int i = 0; i < message.typetag().length(); i++) {
         sb.append(" ");
         String type = message.typetag().substring(i, i+1);
         // type tag specifiers are listed here mostly based on what oscP5 supports
         //    (see add() in trunk/processing/libraries/oscP5/src/oscP5/OscMessage.java)
         // the full spec is here:
         //    http://opensoundcontrol.org/spec-1_0
         // there are minimal standard tags, but many non-standard ones
         // we're not necessarily supporting all of them here
         if ("i".equals(type)) {
            // "i" (0x69) int
            int value = message.get(i).intValue();
            sb.append(value);
         } else if ("f".equals(type)) {
            // "f" (0x66) float
            float value = message.get(i).floatValue();
            sb.append(value);
         } else if ("h".equals(type)) {
            // "h" (0x68) not supported?
            long value = message.get(i).longValue();
            sb.append(value);
         } else if ("d".equals(type)) {
            // "d" (0x64) double
            double value = message.get(i).doubleValue();
            sb.append(value);
         } else if ("s".equals(type)) {
            // "s" (0x73) String
            String value = message.get(i).stringValue();
            sb.append(value);
         } else if ("T".equals(type)) {
            // "T" (0x54) boolean true
            boolean value = message.get(i).booleanValue();
         } else if ("F".equals(type)) {
            // "F" (0x46) boolean false
            boolean value = message.get(i).booleanValue();
         } else if ("c".equals(type)) {
            // "c" (0x63) char
            char value = message.get(i).charValue();
            sb.append(value);
         } else if ("m".equals(type)) {
            // "m" (0x6d) 4 byte MIDI message
            sb.append("?midiUnsupported?");
         } else if ("b".equals(type)) {
            // "b" (0x62) blob
            sb.append("?blobUnsupported?");
         } else if ("N".equals(type)) {
            // "N" (0x4e) null ?
            sb.append("null?");
         } else {
            sb.append("?unexpected?");
         }
      }
      log(sb.toString());
   }
   
   /* OscEventListener */
   public void oscStatus(OscStatus status) {
      log("oscStatus(): " + status.id());
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
            log("Listening for OSC messages on port " + port);
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

   // logging utility methods.
   // XXX i need to stop copying these everywhere and put them in a library...

   // pad a string to at least a minimum size by prepending the given char
   // the StringBuffer is modified in place
   private static void prefixPad(StringBuffer sb, int minsize, char c) {
      int toAdd = minsize - sb.length();
      if (toAdd > 0) {
         for (int i = 0; i < toAdd; i++) {
            sb.insert(0, c);
         }
      }
   }

   private static String getTime() {
      Calendar cal = Calendar.getInstance();

      StringBuffer year = new StringBuffer();
      year.append(cal.get(Calendar.YEAR));
      prefixPad(year, 4, '0');
      StringBuffer month = new StringBuffer();
      month.append(cal.get(Calendar.MONTH) + 1);
      prefixPad(month, 2, '0');
      StringBuffer day = new StringBuffer();
      day.append(cal.get(Calendar.DAY_OF_MONTH));
      prefixPad(day, 2, '0');
      StringBuffer hour = new StringBuffer();
      hour.append(cal.get(Calendar.HOUR_OF_DAY));
      prefixPad(hour, 2, '0');
      StringBuffer min = new StringBuffer();
      min.append(cal.get(Calendar.MINUTE));
      prefixPad(min, 2, '0');
      StringBuffer sec = new StringBuffer();
      sec.append(cal.get(Calendar.SECOND));
      prefixPad(sec, 2, '0');
      StringBuffer millis = new StringBuffer();
      millis.append(cal.get(Calendar.MILLISECOND));
      prefixPad(millis, 3, '0');

      StringBuffer date = new StringBuffer();
      date.append('[');
      date.append(year);
      date.append('/');
      date.append(month);
      date.append('/');
      date.append(day);
      date.append(' ');
      date.append(hour);
      date.append(':');
      date.append(min);
      date.append(':');
      date.append(sec);
      date.append('.');
      date.append(millis);
      date.append(']');

      return date.toString();
   }

   private static void log(String msg) {
      System.out.println(getTime() + " " + msg);
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

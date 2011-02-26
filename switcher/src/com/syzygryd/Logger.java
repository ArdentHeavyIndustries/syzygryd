package com.syzygryd;

import java.util.Calendar;

/**
 * Brain dead simple logging for now
 *
 */
public class Logger {

   // XXX for now just hardcode this, and edit locally (but do not check in) to change
   // if this actually gets much use, i should add properties to the switcher as well
   // XXX FOR NOW CHECK THIS IN, BUT I PROBABLY DON'T WANT TO LEAVE IT THIS WAY
   //private static final boolean debug = false;
   private static final boolean debug = true;

   // XXX logging is almost completely copied from processing/controller_display/controller_display.pde and processing/ShowControl/ShowControl.pde
   // in the long term we should share code

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
      Logger.prefixPad(year, 4, '0');
      StringBuffer month = new StringBuffer();
      month.append(cal.get(Calendar.MONTH) + 1);
      Logger.prefixPad(month, 2, '0');
      StringBuffer day = new StringBuffer();
      day.append(cal.get(Calendar.DAY_OF_MONTH));
      Logger.prefixPad(day, 2, '0');
      StringBuffer hour = new StringBuffer();
      hour.append(cal.get(Calendar.HOUR_OF_DAY));
      Logger.prefixPad(hour, 2, '0');
      StringBuffer min = new StringBuffer();
      min.append(cal.get(Calendar.MINUTE));
      Logger.prefixPad(min, 2, '0');
      StringBuffer sec = new StringBuffer();
      sec.append(cal.get(Calendar.SECOND));
      Logger.prefixPad(sec, 2, '0');
      StringBuffer millis = new StringBuffer();
      millis.append(cal.get(Calendar.MILLISECOND));
      Logger.prefixPad(millis, 3, '0');

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

   public static void debug(String msg) {
      if (debug) {
         System.out.println(getTime() + " " + msg);
      }
   }
   
   public static void info(String msg) {
      System.out.println(getTime() + " " + msg);
   }
   
   public static void warn(String msg) {
      System.err.println(getTime() + " WARNING: " + msg);
   }

   public static void warn(Exception e) {
      System.err.println(getTime() + " WARNING: " + e);
      e.printStackTrace();
   }

   public static void warn(String msg, Exception e) {
      System.err.println(getTime() + " WARNING: " + msg);
      e.printStackTrace();
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

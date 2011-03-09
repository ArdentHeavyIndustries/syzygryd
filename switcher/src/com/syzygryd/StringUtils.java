package com.syzygryd;

public class StringUtils {
   public static String stringArrayToString(String[] array) {
      StringBuffer sb = new StringBuffer();
      for (int i = 0; i < array.length; i++) {
         if (i > 0) {
            sb.append(" ");
         }
         sb.append(array[i]);
      }
      return sb.toString();
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

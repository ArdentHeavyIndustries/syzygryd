import java.lang.Thread;
import java.lang.InterruptedException;

class TestMode extends Thread {
   TestMode() {
      info("Test mode selected.  Will periodically randomly simulate mouse presses.");
   }
   
   public void run() {
      info("Test mode looping endlessly...");
      while (true) {
         try {
            // XXX this should be random
            Thread.sleep(1000);
         } catch (InterruptedException ie) {
         }
         //debug("simulating mouse pressed");
         mousePressed();
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

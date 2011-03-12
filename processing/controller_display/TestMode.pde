import java.lang.Thread;
import java.lang.InterruptedException;

class TestMode extends Thread {
   int randomMaxShortDelayMs;
   int randomMaxLongDelayMs;
   float fracLongDelay;

   TestMode() {
      info("Test mode selected.  Will periodically randomly simulate mouse presses.");

      randomMaxShortDelayMs = getIntProperty("randomMaxShortDelaySec") * 1000;
      randomMaxLongDelayMs = getIntProperty("randomMaxLongDelaySec") * 1000;
      if (randomMaxShortDelayMs >= randomMaxLongDelayMs) {
         warn("random max long delay (" + randomMaxLongDelayMs + " ms) should be longer than random max short delay (" + randomMaxShortDelayMs + " ms)");
      }
      fracLongDelay = getFloatProperty("fracLongDelay");
      info("Short delays are from 0 to " + randomMaxShortDelayMs + " ms");
      info("Long delays are from " + randomMaxShortDelayMs + " ms to " + randomMaxLongDelayMs + " ms");
      info(fracLongDelay + " of the delays are long");
   }
   
   public void run() {
      info("Test mode looping endlessly...");
      while (true) {
         try {
            // the gist is that most of the time we want to emulate frequent button presses
            // so something between 0 and randomMaxShortDelayMs
            // and every once in a while we want to simulate a longer gap
            // so something between randomMaxShortDelayMs and randomMaxLongDelayMs
            // and what fraction of the time (between 0 (never) and 1 (always) is a longer gap is given by fracLongDelay
            int sleepMs;
            if (random.nextFloat() >= fracLongDelay) {
               sleepMs = random.nextInt(randomMaxShortDelayMs);
            } else {
               sleepMs = randomMaxShortDelayMs + random.nextInt(randomMaxLongDelayMs - randomMaxShortDelayMs);
            }
            //debug("waiting " + sleepMs + " ms for next simulated mouse press");
            Thread.sleep(sleepMs);
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

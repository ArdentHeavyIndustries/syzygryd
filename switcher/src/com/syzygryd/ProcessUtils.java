package com.syzygryd;

import java.io.InputStream;
import java.io.IOException;

public class ProcessUtils {
   private static final int LIVE_QUIT_ITERATION_MS = 1000;
   private static final int LIVE_QUIT_MAX_ITER = 5;

   public static void doLiveQuit() {
      Logger.debug("doLiveQuit()");

      try {
         if (!isLiveProcessRunning()) {
            Logger.info("Request to quit live, but live is not running");
            return;
         }
      } catch (SwitcherException se) {
         Logger.warn("Can't tell if live is still running.  This is a bad sign, but will proceed anyway: " + se.getMessage());
      }

      if (Switcher.isLivePlaying()) {
         Logger.info("Before quitting live, stop playing");
         try {
            Set.stop();
         } catch (SwitcherException se) {
            Logger.warn("Error stopping live before quitting, will proceed anyway: " + se.getMessage());
         }
         // XXX dammit, in this instance we need to wait for the stop, like in ActionRunner.doStop()
         try {
            Logger.debug("XXX arbitrary wait (for now) for stop to take effect");
            Thread.sleep(10000);
         } catch (InterruptedException ie) {
         }
      }

      boolean liveQuit = false;

      Logger.info("Quitting live via AppleScript");
      try {
         AppleScriptRunner.runLiveQuit();
      } catch (SwitcherException se) {
         Logger.warn("Error quitting live via AppleScript, will proceed anyway: " + se.getMessage());
      }

      liveQuit = waitLiveQuit(LIVE_QUIT_ITERATION_MS, LIVE_QUIT_MAX_ITER);
      if (liveQuit) {
         Logger.info("Live has quit");
         return;
      }

      // this may be a sign that we did not successfully stop live
      // XXX sadly, this doesn't seem to work, so comment it all out for now
      // Logger.info("Accounting for possible \"This action will stop audio. Proceed?\" popup");
      // try {
      //    AppleScriptRunner.runLiveEnter();
      // } catch (SwitcherException se) {
      //    Logger.warn("Error sending enter to live, will proceed anyway: " + se.getMessage());
      // }
      //
      // liveQuit = waitLiveQuit(LIVE_QUIT_ITERATION_MS, LIVE_QUIT_MAX_ITER);
      // if (liveQuit) {
      //    Logger.info("Live has quit");
      //    return;
      // }

      Integer pid = null;
      try {
         pid = getLivePid();
      } catch (SwitcherException se) {
         Logger.warn("Unable to get live pid, so we can not try killing the process");
         Logger.warn("Will proceed anyway, but THIS COULD BE VERY SERIOUS AND DESERVES IMMEDIATE INVESTIGATION BY HAND");
         return;
      }
      if (pid == null) {
         Logger.info("There is no live pid, perhaps it really has quit by now");
         return;
      }

      // It seems marginally cleaner to do this *after* sending the
      // kill, but live seems to restart automatically sometimes
      // (I'm not sure why), and we don't want to have the race
      // condition that it does so before the files are removed.
      cleanupLive();
      
      Logger.info("Killing live process " + pid);
      try {
         doExec("kill " + pid);
      } catch (SwitcherException se) {
         Logger.warn("Error killing live process, will proceed anyway: " + se.getMessage());
      }
         
      liveQuit = waitLiveQuit(LIVE_QUIT_ITERATION_MS, LIVE_QUIT_MAX_ITER);
      if (liveQuit) {
         Logger.info("Live has quit");
         return;
      }

      Logger.info("Very uncleanly killing live process " + pid);
      try {
         doExec("kill -9 " + pid);
      } catch (SwitcherException se) {
         Logger.warn("Error very uncleanly killing live process, will proceed anyway: " + se.getMessage());
      }
      
      liveQuit = waitLiveQuit(LIVE_QUIT_ITERATION_MS, LIVE_QUIT_MAX_ITER);
      if (liveQuit) {
         Logger.info("Live has quit");
      } else {
         Logger.warn("We have tried everything possible to quit, but live is still running.");
         Logger.warn("Will proceed anyway, but THIS COULD BE VERY SERIOUS AND DESERVES IMMEDIATE INVESTIGATION BY HAND");
      }
   }

   /**
    * Wait up to maxIter iterations of iterationMs each for live to quit.
    * Return true (as soon as we detect this) if live has quit.
    * Return false if at the end of waiting, live is still running.
    */
   private static boolean waitLiveQuit(int iterationMs, int maxIter) {
      Logger.info("Waiting (up to " + maxIter + " iterations) of " + iterationMs + " ms each for live to quit");
      try {
         int iter = 0;
         boolean running = isLiveProcessRunning();
         while (running && iter < maxIter) {
            Logger.debug("Waiting...");
            try {
               Thread.sleep(iterationMs);
            } catch (InterruptedException ie) {
            }
            running = isLiveProcessRunning();
            if (running) {
               iter++;
            }
         }
         if (running) {
            Logger.debug("Live has not yet quit");
         }
         return !running;
      } catch (SwitcherException se) {
         Logger.warn("Error waiting for live to quit, we will assume that it has not yet quit: " + se.getMessage());
         return false;
      }
   }

   private static void cleanupLive() {
      Logger.info("Cleaning up from possible unclean live shutdown, to avoid future badness");

      String filename;

      // This is to avoid the following popup on the next start of Live
      //   Live unexpectedly quit while you were working on the Live Set '<set>.als'. Would you like to recover your work?
      filename = "~/Library/Preferences/Ableton/Live*/Undo.cfg";
      try {
         doShellExec("rm -f " + filename);
      } catch (SwitcherException se) {
         Logger.warn("Error removing " + filename + ": " + se.getMessage());
         Logger.warn("Will proceed anyway, but THIS COULD RESULT IN A POPUP NEXT ROUND WHICH WILL HANG LIVE UNTIL RESOLVED.  THIS DESERVES IMMEDIATE INVESTIGATION BY HAND");
      }

      // This is to avoid the "Report a Bug" sidebar on the next start of Live
      filename = "~/Library/Preferences/Ableton/Live*/CrashDetection.cfg";
      try {
         doShellExec("rm -f " + filename);
      } catch (SwitcherException se) {
         Logger.warn("Error removing " + filename + ": " + se.getMessage());
         Logger.warn("Will proceed anyway, this is probably not that important and will just case a bug report sidebar");
      }
   }

   private static boolean isLiveProcessRunning()
      throws SwitcherException
   {
      Process process = doShellExec("ps auxww | grep /Applications/Live | grep -v grep");
      return (process.exitValue() == 0);
   }

   private static Integer getLivePid()
      throws SwitcherException
   {
      Process process = doShellExec("ps auxww | grep /Applications/Live | grep -v grep | awk '{print $2}'");
      // this gives us stdout
      InputStream is = process.getInputStream();
      Integer i_pid = null;
      try {
         int len = is.available();
         if (len == 0) {
            Logger.debug("No live pid");
         } else {
            byte[] bytes = new byte[len];
            int nRead = is.read(bytes, 0, len);
            if (nRead != len) {
               SwitcherException.doThrow("Expected to read " + len + " bytes from process stdout, but only read " + nRead);
            } else {
               String s_pid = (new String(bytes)).trim();
               Logger.debug("Live pid = " + s_pid);
               try {
                  i_pid = Integer.valueOf(s_pid);
               } catch (NumberFormatException nfe) {
                  SwitcherException.doThrow("Unable to parse live pid: " + s_pid);
               }
            }
         }
      } catch (IOException ioe) {
         SwitcherException.doThrow("Unable to get live pid", ioe);
      }
      return i_pid;
   }

   private static Process doShellExec(String cmd)
      throws SwitcherException
   {
      Logger.debug("Executing (via bash): " + cmd);
      // We can't directly execute a pipe, we have to pass that to a shell
      // And we need to use the String[] form of exec for that, not String.
      // We also need to use the shell if we want to use shell expansion (e.g. wildcards).
      String[] cmds = {"/bin/bash", "-c", cmd};
      Process process = null;
      try {
         process = Runtime.getRuntime().exec(cmds);
      } catch (IOException ioe) {
         SwitcherException.doThrow("Exception executing command \"" + cmd, ioe);
      }
      try {
         // XXX i suppose in theory this is dangerous if the process were to somehow hang, this would block indefinitely
         process.waitFor();
      } catch (InterruptedException ie) {
      }
      return process;
   }

   private static Process doExec(String cmd)
      throws SwitcherException
   {
      Logger.debug("Executing: " + cmd);
      Process process = null;
      try {
         process = Runtime.getRuntime().exec(cmd);
      } catch (IOException ioe) {
         SwitcherException.doThrow("Exception executing command \"" + cmd, ioe);
      }
      try {
         // XXX i suppose in theory this is dangerous if the process were to somehow hang, this would block indefinitely
         process.waitFor();
      } catch (InterruptedException ie) {
      }
      return process;
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

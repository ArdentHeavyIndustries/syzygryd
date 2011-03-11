package com.syzygryd;

import java.io.InputStream;
import java.io.IOException;

public class ProcessUtils {
   private static boolean quittingLive = false;
   private static boolean killingOpenSetProcesses = false;

   public static void doLiveQuit() {
      Logger.debug("doLiveQuit()");

      synchronized(ActionRunner.getInstance()) {
         if (ProcessUtils.quittingLive) {
            Logger.info("We are already quitting live, ignoring this call to doLiveQuit()");
            return;
         } else {
            Logger.info("We are now quitting live");
            ProcessUtils.quittingLive = true;
         }
      }

      try {
         Logger.debug("Clearing live running");
         ActionRunner.getInstance().liveRunning = false;

         // just in case we're in the process of opening live, but it hasn't yet opened
         killOpenSetProcesses();

         try {
            if (!isLiveProcessRunning()) {
               Logger.info("Request to quit live, but live is not running");
               cleanupLive();	// see comments below
               return;
            }
         } catch (SwitcherException se) {
            Logger.warn("Can't tell if live is still running.  This is a bad sign, but will proceed anyway: " + se.getMessage());
         }

         if (Switcher.isLivePlaying()) {
            Logger.info("Before quitting live, stop playing");
            // Do to the overly OO nature of some of this, we need to create a bogus action.
            Action action = ActionFactory.createAction(Action.ActionType.playnext, null);
            ActionRunner ar = ActionRunner.getInstance();
            Logger.debug("Created bogus action for stopping: " + ar.actionToShortString(action));
            // And then we're somewhat violating the OO structure by calling this here,
            // but this is the simplest way to share code.
            try {
               // This includes waiting for the stop to have completed.
               ar.doStop(action);
            } catch (SwitcherException se) {
               Logger.warn("Error stopping live before quitting, will proceed anyway: " + se.getMessage());
            }
         }

         boolean liveQuit = false;

         Logger.info("Quitting live via AppleScript");
         try {
            AppleScriptRunner.runLiveQuit();
         } catch (SwitcherException se) {
            Logger.warn("Error quitting live via AppleScript, will proceed anyway: " + se.getMessage());
         }

         liveQuit = waitLiveQuit(Config.LIVE_QUIT_ITERATION_MS, Config.LIVE_QUIT_MAX_ITER);
         if (liveQuit) {
            Logger.info("Live has quit");
            cleanupLive();	// see comments below
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
         // liveQuit = waitLiveQuit(Config.LIVE_QUIT_ITERATION_MS, Config.LIVE_QUIT_MAX_ITER);
         // if (liveQuit) {
         //    Logger.info("Live has quit");
         //    cleanupLive();	// see comments below
         //    return;
         // }

         Integer pid = null;
         try {
            pid = getLivePid();
         } catch (SwitcherException se) {
            Logger.warn("Unable to get live pid, so we can not try killing the process");
            Logger.warn("Will proceed anyway, but THIS COULD BE VERY SERIOUS AND DESERVES IMMEDIATE INVESTIGATION BY HAND");
            cleanupLive();	// see comments below
            return;
         }
         if (pid == null) {
            Logger.info("There is no live pid, perhaps it really has quit by now");
            cleanupLive();	// see comments below
            return;
         }

         // It seems marginally cleaner to do this *after* sending the
         // kill, but live seems to restart automatically sometimes
         // (I'm not sure why), and we don't want to have the race
         // condition that it does so before the files are removed.
         //
         // With just this call to cleanup, we're seeing cases where an
         // even allegedly clean shutdown following a crash causes an
         // unclean situation on the next start, requiring two killings
         // following a crash (and one full loading wait leading to a
         // skipped set), so we are now calling this unconditionally
         // before *all* return paths above.
         cleanupLive();
      
         Logger.info("Killing live process " + pid);
         try {
            doExec("kill " + pid);
         } catch (SwitcherException se) {
            Logger.warn("Error killing live process, will proceed anyway: " + se.getMessage());
         }
         
         liveQuit = waitLiveQuit(Config.LIVE_QUIT_ITERATION_MS, Config.LIVE_QUIT_MAX_ITER);
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
      
         liveQuit = waitLiveQuit(Config.LIVE_QUIT_ITERATION_MS, Config.LIVE_QUIT_MAX_ITER);
         if (liveQuit) {
            Logger.info("Live has quit");
         } else {
            Logger.warn("We have tried everything possible to quit, but live is still running.");
            Logger.warn("Will proceed anyway, but THIS COULD BE VERY SERIOUS AND DESERVES IMMEDIATE INVESTIGATION BY HAND");
         }

      } finally {
         ProcessUtils.quittingLive = false;
         Logger.info("We are done quitting live");
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

   protected static boolean isLiveProcessRunning()
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

   // kill any processes that are opening up sets
   // this code borrows from doLiveQuit()
   public static void killOpenSetProcesses() {
      Logger.debug("killOpenSetProcesses()");

      // at first i was thinking it was lame to share the same sync var as doLiveQuit(),
      // but maybe it's actually desirable
      synchronized(ActionRunner.getInstance()) {
         if (ProcessUtils.killingOpenSetProcesses) {
            Logger.info("We are already killing open set processes, ignoring this call to killOpenSetProcesses()");
            return;
         } else {
            Logger.info("We are now killing open set proceses");
            ProcessUtils.killingOpenSetProcesses = true;
         }
      }

      try {
         try {
            if (!isOpenSetProcessRunning()) {
               Logger.info("Request to kill open set processes, but there are none");
               return;
            }
         } catch (SwitcherException se) {
            Logger.warn("Can't tell if there are open set processes.  This is a bad sign, but will proceed anyway: " + se.getMessage());
         }

         boolean noOpenSetProcesses = false;

         Logger.info("Killing open set processes");
         try {
            doShellExec("ps auxww | grep \"open.*\\.als\" | grep -v grep | awk '{print $2}' | xargs kill");
         } catch (SwitcherException se) {
            Logger.warn("Error killing open set processes, will proceed anyway: " + se.getMessage());
         }
         
         noOpenSetProcesses = waitNoOpenSetProcesses(Config.KILL_OPEN_SET_PROCESSES_ITERATION_MS, Config.KILL_OPEN_SET_PROCESSES_MAX_ITER);
         if (noOpenSetProcesses) {
            Logger.info("There are no more open set processes");
            return;
         }

         Logger.info("Very uncleanly killing open set processes");
         try {
            doShellExec("ps auxww | grep \"open.*\\.als\" | grep -v grep | awk '{print $2}' | xargs kill -9");
         } catch (SwitcherException se) {
            Logger.warn("Error very uncleanly killing open set processes, will proceed anyway: " + se.getMessage());
         }
      
         noOpenSetProcesses = waitNoOpenSetProcesses(Config.KILL_OPEN_SET_PROCESSES_ITERATION_MS, Config.KILL_OPEN_SET_PROCESSES_MAX_ITER);
         if (noOpenSetProcesses) {
            Logger.info("There are no more open set processes");
         } else {
            Logger.warn("We have tried everything possible to kill open set processes, but there is still at least one");
            Logger.warn("Will proceed anyway, but THIS COULD BE VERY SERIOUS AND DESERVES IMMEDIATE INVESTIGATION BY HAND");
         }

      } finally {
         ProcessUtils.killingOpenSetProcesses = false;
         Logger.info("We are done killing open set processes");
      }
      
   }


   // there could be multiple such processes, we just care if there is at least one
   protected static boolean isOpenSetProcessRunning()
      throws SwitcherException
   {
      Process process = doShellExec("ps auxww | grep \"open.*\\.als\" | grep -v grep");
      return (process.exitValue() == 0);
   }

   /**
    * Wait up to maxIter iterations of iterationMs each for there to be no open set processes running.
    * Return true (as soon as we detect this) if there are no open set processes running.
    * Return false if at the end of waiting, there are still open set processes running.
    * 
    * XXX Copied from waitLiveQuit().  Sharing code would be better.  No function pointers, but I suppose I could define an interface.
    */
   private static boolean waitNoOpenSetProcesses(int iterationMs, int maxIter) {
      Logger.info("Waiting (up to " + maxIter + " iterations) of " + iterationMs + " ms each for there to be no open set processes");
      try {
         int iter = 0;
         boolean running = isOpenSetProcessRunning();
         while (running && iter < maxIter) {
            Logger.debug("Waiting...");
            try {
               Thread.sleep(iterationMs);
            } catch (InterruptedException ie) {
            }
            running = isOpenSetProcessRunning();
            if (running) {
               iter++;
            }
         }
         if (running) {
            Logger.debug("There are still open set processes");
         }
         return !running;
      } catch (SwitcherException se) {
         Logger.warn("Error waiting for there to be no open set processes, we will assume that it there are still open set processes: " + se.getMessage());
         return false;
      }
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

   protected static Process doExec(String cmd)
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

   protected static Process doExec(String[] cmd)
      throws SwitcherException
   {
      Logger.debug("Executing: " + StringUtils.stringArrayToString(cmd));
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

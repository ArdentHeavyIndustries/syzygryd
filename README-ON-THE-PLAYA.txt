Please use this file for anything that you want to communicate with the team
that will already be out on the playa when the syzyputer arrives.

-------------------------------------------------------------------------------
We have had numerous issues of people checking in local testing related
changes that shouldn't be checked in for production use.  A few things to
check for:

- is the controller pointing at the right IP address for the sequencer in
  controller_display.pde (10.10.10.10)

- i think this ought to be the only hardcoded IP address, and in general we
  use the broadcast address (255.255.255.255), but i'm not 100% positive

- is the single line within the contents of log() in controller_display.pde
  commented out (please don't comment out the entire method itself)

- does ShowControl.pde have the proper config.  i (rich) *think* it ought to
  be the following, but J should confirm:

     SEND_DMX = true;
     SYZYVYZ = false;
     ASCII_SEQUENCER_DISPLAY = false;

- are all of the ports set properly.  there's:
    http://wiki.interpretivearson.com/index.php?title=Syzygryd:Teams:Software:OSCRouting
  although the copy of the wiki on the syzyputer may be out of date.  i'll try
  to put a local copy of this somewhere accessible.

- are calls in processing to print() or println() kept to a minimum.
  occasional and error condition use is fine.  within inner loops are not.
  please comment out any that you feel are spewing too much.

-------------------------------------------------------------------------------
updateStarFieldSkip (see /opt/syzygryd/etc/sequencer.properties) defaults to
150.  during the limited testing over the weekend, twice processing hung on a
controller.  matts' theory was that it had to do with the rate of the
starfield.  i tried doubling to 300, it eventually hung again, i tried
doubling it to 600, i never heard the results of running this for a while and
i had to go.  i'm skeptical that this is the issue.

if it hangs again, you might want to uncomment out the line in log() in
controller_display.pde, and run as a processing sketch (not a standalone app),
and see if there's some useful info, like maybe a stack trace.

600 is a bit too slow to really perceive the effect as a starfield.  if this
turns out to be unrelated, it would i think be nice to drop it down again
(like perhaps to the default 150, which would mean just leaving the originally
commented out line)

if we really can't find this and solve it, we may need a watchdog.  i could
probably do this fairly easily in linux, but i have no clue how to do it in
windows.

if processing does hang, because we're running full screen and there is no
stop button, you can't get out by pressing ESC, b/c processing is hung.  the
only option is to Ctrl-Alt-Del to bring up the Task Manager, and kill the
process (I think it's javaw.exe).  Please test *in advance* that we can
properly send Ctrl-Alt-Del through rdesktop (and that it's not just trapped by
the host computer).

-------------------------------------------------------------------------------
We put a reasonable amount of effort into getting the mac set up for the
playa, but I worry that the windows boxes didn't get the attention they
deserved.  I know we didn't get cygwin on them, various networking stuff
didn't get straightened out (although nicole has said it's easy to deal with
on the playa).  Did some non-GUI svn get installed?  Someone should at least
download an installer for this and put it somewhere.

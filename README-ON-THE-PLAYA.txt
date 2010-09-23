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
  be the following, but J should confirm: [Jonathan has confirmed]

     SEND_DMX = true;
     SYZYVYZ = false;
     ASCII_SEQUENCER_DISPLAY = false;

- are all of the ports set properly.  there's:
    http://wiki.interpretivearson.com/index.php?title=Syzygryd:Teams:Software:OSCRouting
  although the copy of the wiki on the syzyputer may be out of date.  i put a
  copy as of 2010-08-24 13:44 in the home dir.  it's not pretty, but it's
  readable.

- are calls in processing to print() or println() kept to a minimum.
  occasional and error condition use is fine.  within inner loops are not.
  please comment out any that you feel are spewing too much.

My understanding is that the final values for the call(s) to
DMXManager.addController() in ShowControl.setup() will have to wait until the
playa.  (J ?)  But perhaps the ones to foo and bar should be deleted ?

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
on the playa).  Did some non-GUI svn get installed?  I copied local installers
for TortoiseSVN (32b and 64b) to ~/windows

-------------------------------------------------------------------------------
In general I've been saving bookmarks in firefox, not safari.  There's a lot
of reference material I downloaded locally.

-------------------------------------------------------------------------------
There's a local copy of the wiki, that you shouldn't try making edits to (they
won't ever get propogated back.)  Ed put a file with instructions for enabling
it (it requires starting apache) on the desktop, and I put a firefox
bookmark to it.

-------------------------------------------------------------------------------
We probably want to stop apache for production use.

-------------------------------------------------------------------------------
We probably want to disable dropbox for production use.

-------------------------------------------------------------------------------
Following this checkin, I am going to tag the repository at
tags/BM_2010_PRE_PLAYA

I will then do a quick effort at a local mirror of the svn repo.  Any notes
regarding this will not be in the repository itself, but in
~/README-LOCAL-SVN-REPO.txt

See you on the playa!

-------------------------------------------------------------------------------
A few post tagging notes...

----------------------------------------
I'm *really* close to getting the full rw svn repo working.  Hopefully
someone can finish it.  See the svn notes.  If you can figure out how
to commit the changes currently at:

  ~/svn-mirror-test2/syzygryd/trunk/tmp

(either as yourself, or the syzygryd svn user), then things are
probably working.

----------------------------------------
On Windows, we've never been able to figure out any kind of console,
or where stdout/stderr goes.  If you need to debug the controller,
you'll probably have to run as a processing sketch and watch the
output in processing.  Keep in mind that multiple processing sketches
running together produce a single mangled output.  Don't forget to
uncomment the contents of the log() method as described above.  (And
put comment it out again when done.)

If you need to rebuild the controller, our strategy has been to do
this on the mac, in processing export a windows app, then copy that
*.exe to the windows boxes.

----------------------------------------
The mac build of the sequencer has some issues that affect debugging.
The windows build makes a single build result (a *.dll file) as part
of the build, and those are in separate places for Debug and Release.
Pointing Live at one or the other is as simple as changing the
preferences for the plugin folder.

The ultimate build result for the mac is a zip file, but that's not
actually built by the build.  It's always been done by hand for
dropbox, see the example below:

{{{
# build Debug|Plugin|i386 with Xcode
cd ~/Library/Audio/Plug-Ins/VST/MyJucePlugins && zip -r ~/Dropbox/IA\ Media/Syzygryd/software/sequencer/mac/syzygryd_sequencer-r586-Debug.vst.zip syzygryd_sequencer.vst
# build Release|Plugin|i386 with Xcode
cd ~/Library/Audio/Plug-Ins/VST/MyJucePlugins && zip -r ~/Dropbox/IA\ Media/Syzygryd/software/sequencer/mac/syzygryd_sequencer-r586-Release.vst.zip syzygryd_sequencer.vst
}}}

While the precursor to this zip file is actually an expansion in the
proper location for Live, the problem is that creating this is
destructive wrt the Debug and Release builds.  Specifically, right now
(and it should be this way for production), what's in the
MyJucePlugins dir is the Release build.  If you want to switch back to
the corresponding Debug build without rebuilding, you can't easily do
this, b/c the Debug results are lost.  The best you can do is hope
that the last time someone built, they built both Debug and Release
versions, and saved the Debug zip file somewhere.  (As of this
writing, our most recent build, r667, meets these criteria.)

So if you don't have changes and just want to run Debug, you need to
move the Release .vst dir out of the way and unzip the Debug version.
While you can do this where it is now, if you end up with two versions
of the plugin seen by Live, that can be confusing.  Perhaps move it
totally out of the plug-ins area.

If you do need to make a new build, please first build Debug, then by
hand zip up the results and put them somewhere, then do the same for
Release.  Be sure to build Release last, since whatever is built last
is what production will see.

Yes, I know this sucks.  Sorry, but I didn't discover how the mac
build worked until the last minute, at which point there was no time
to change it.

-------------------------------------------------
Do not try to build the visualizer.  The current checked in version
will build, but immediately crash upon running.  There has never been
a version checked into the svn repo that is able to successfully build
and run.  Somehow we have some working binary that was built at some
unknown time under some unknown conditions.  Don't lose it.

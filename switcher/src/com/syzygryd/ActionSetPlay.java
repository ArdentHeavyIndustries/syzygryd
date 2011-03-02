package com.syzygryd;

import java.util.Properties;

 /**
 * handles all actions involving playing some track 
 * in the set list.  must have setlist passed to it via
 * setList().
 *
 */
public class ActionSetPlay extends Action {
	private Set s = null;
	private static int SECOND_IN_MILLIS = 1000;
	
	private static Setlist list;
	
	public static void setList(Setlist list) {
		ActionSetPlay.list = list;
	}
	
	public ActionSetPlay(ActionType t, Properties p) {
		super(t, p);
		asyncLoading = true;
	}

	public void init()
      throws SwitcherException
   {
      this.s = null;
		switch (type)
         {
         case playnext:
            this.s = ActionSetPlay.list.getNext();
            break;
         case playprev:
            this.s = ActionSetPlay.list.getPrev();
            break;
         case playthis:
            int setId;
            try {
               setId = Integer.valueOf(params.getProperty("setid"));
               this.s = list.getSet(setId);
            } catch (Exception e) {
               SwitcherException.doThrow("Can not get set id");
            }
            break;
         default:
            break;
         }
		
		if (this.s != null) {
         Logger.debug("Got set, will open");
			this.duration = this.s.getLength() * SECOND_IN_MILLIS;
         Logger.debug("Set duration to " + this.duration + " ms");
			this.s.open();
      } else {
         SwitcherException.doThrow("Unable to get set");
      }
	}
	
	public void start() 
      throws SwitcherException
   {
      // this is a static method, remove the (this.s != null) qualifier
		//if (this.s != null) {
			Set.play();
      //}
	}
	
   public boolean isStarted() {
      // XXX this is kinda hacky and somewhat breaking good OO abstractions
      // see notes in ActionRunner.doStart() for more details
      return Switcher.isLivePlaying();
   }

	public void stop()
      throws SwitcherException
   {
      // this is a static method, remove the (this.s != null) qualifier
		//if (this.s != null) {
         Set.stop();
      //}
	}
	
   public boolean isStopped() {
      // XXX similarly hacky like isStarted(), see ActionRunner.doStop()
      return Switcher.isLiveStopped();
   }

	public int getId() {
		return list.getCurrentId();
	}
	
	public String getLightingProgram() {
		return s.getLightingProgram();
	}

   // XXX this is causing a NPE.  for now just comment out and let super.toString() be used.
	// public String toString() {
	// 	switch (type) {
	// 	case playnext:
	// 	case playprev:
	// 		return list.getCurrentSet().toString();
	// 	case playthis:
	// 		int setId;
	// 		try {
	// 			setId = Integer.valueOf(params.getProperty("setid"));
	// 		} catch (Exception e) {
	// 			return "Play invalid setId";
	// 		}
	// 		return list.peekSet(setId).toString();
	// 	}
	// 	return s.toString();
	// }
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

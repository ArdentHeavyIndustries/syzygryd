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
	
	static Setlist list;
	
	static void setList(Setlist s) {
		list = s;
	}
	
	public ActionSetPlay(ActionType t, Properties p) {
		super(t, p);
		asyncLoading = true;
	}

	public boolean start() {
		
		switch (type) {
		case playnext:
			s = list.getNext();
			break;
		case playprev:
			s = list.getPrev();
			break;
		case playthis:
			int setId;
			try {
				setId = Integer.valueOf(params.getProperty("setid"));
			} catch (Exception e) {
				return false;
			}
			s = list.getSet(setId);
			break;
		default:
			break;
		}
		
		if (s != null) {
			duration = s.getLength() * SECOND_IN_MILLIS;
			s.play();
			return true;
		}
		
		return false;
	}
	
	public void stop() {
		if (s != null) {
			s.stop();
		}
	}
	
	public int getId() {
		return list.getCurrentId();
	}
	
	public String getLightingProgram() {
		return s.getLightingProgram();
	}
	
	public String toString() {
		switch (type) {
		case playnext:
		case playprev:
			return list.getCurrentSet().toString();
		case playthis:
			int setId;
			try {
				setId = Integer.valueOf(params.getProperty("setid"));
			} catch (Exception e) {
				return "Play invalid setId";
			}
			return list.peekSet(setId).toString();
		}
		return s.toString();
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

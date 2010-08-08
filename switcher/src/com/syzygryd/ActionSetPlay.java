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
}

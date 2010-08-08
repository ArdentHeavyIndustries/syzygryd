package com.syzygryd;

import java.util.Properties;

public class ActionFactory {
	private ActionFactory() {
		// factory class so this does nothing
	}
	
	public static Action createAction(Action.ActionType a, Properties params) {
		switch (a) {
		case playnext:
		case playprev:
		case playthis:
			return new ActionSetPlay(a, params);
		default:
			return null;
		}
	}
}

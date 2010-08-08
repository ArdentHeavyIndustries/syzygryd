package com.syzygryd;

import java.util.Properties;

/**
 * Instantiates appropriate subclasses of Action
 *
 */
public class ActionFactory {
	private ActionFactory() {
		// factory class so this does nothing
	}
	
	/**
	 * Instantiates an Action subclass of the correct type given a particular ActionType
	 * @param a ActionType of Action
	 * @param params parameters passed to Action
	 * @return subclass of Action
	 */
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

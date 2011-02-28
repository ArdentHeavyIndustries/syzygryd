package com.syzygryd;

public class SwitcherException extends Exception {

    public SwitcherException(String msg) {
	super(msg);
    }

    public SwitcherException(String msg, Throwable cause) {
    	super(msg, cause);
    }

    // convenience methods for throwing an exception and logging it

    public static void doThrow(String msg)
    	throws SwitcherException
    {
	Logger.warn(msg);
	SwitcherException se = new SwitcherException(msg);
	throw (se);
    }
    
    public static void doThrow(String msg, Throwable cause)
    	throws SwitcherException
    {
	Logger.warn(msg + ": " + cause.getMessage());
	SwitcherException se = new SwitcherException(msg, cause);
	throw (se);
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

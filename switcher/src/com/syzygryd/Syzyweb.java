package com.syzygryd;

import java.io.File;
import java.io.IOException;
import java.util.Properties;

/**
 * Provides web interface that serves up pages (including setlist) and responds to
 * actions
 *
 */
public class Syzyweb extends NanoHTTPD {

	public static final String ACTION_URI_PREFIX = "/sz/";
	public static final int SECOND_IN_MILLIS = 1000;
	public static final int SCREENSHOT_DELAY = 1 * SECOND_IN_MILLIS;
	private ActionRunner runner = null;
	private Setlist list = null;
	public Syzyweb(int port, ActionRunner ar, Setlist sl) throws IOException {
		super(port);
		runner = ar;
		list = sl;
	}
	
	/**
	 * 
	 * Called each time an HTTP request arrives
	 * 
	 * @param uri URI = URL minus domain & protocol identifier
	 * @param method GET/HEAD/POST
	 * @param header all the headers 
	 * @param params parsed GET/POST parameters
	 * @return Response to send to web client
	 */
	public Response serve( String uri, String method, Properties header, Properties params ) {
		if (uri != null && uri.length() > ACTION_URI_PREFIX.length() + 1) {
			if (uri.startsWith(ACTION_URI_PREFIX)) {
				Response r = act(uri,method,header,params);
				if (r == null) {
					r = super.serve(uri,method,header,params);
				}
				return r;
			} 
		}
		
		return super.serve(uri, method, header, params);
	}
	
	/**
	 * finds a command we support and executes it, passing CGI parameters to it to it; otherwise returns null
	 * @param uri URI = URL minus domain & protocol identifier
	 * @param method GET/HEAD/POST
	 * @param header all the headers 
	 * @param params parsed CGI GET/POST parameters
	 * @return Response to send to web client
	 */
	protected Response act( String uri, String method, Properties header, Properties params ) {
		int endOfAction = uri.indexOf('?');
		
		endOfAction = (endOfAction > 0 ? endOfAction : uri.length());
		
		String actionStr = uri.substring(ACTION_URI_PREFIX.length(), endOfAction);
		Action.ActionType a = null;
		try {
			a = Action.ActionType.valueOf(actionStr.toLowerCase());
		} catch (IllegalArgumentException iae) {
			Logger.warn("No such action " + actionStr);
			return errorResponse(NanoHTTPD.HTTP_INTERNALERROR, "Invalid action: " + actionStr + ". nice try, k1dd135.");
		}
		
		boolean shouldQueue = false;
		if (params != null) {
			shouldQueue = params.getProperty("q", "0").equals("1");
		}
		
		switch (a) {
		case playthis:
		case playnext:
		case playprev:
			runner.injectAction(shouldQueue, ActionFactory.createAction(a, params));
			return successResponse();
		case liveesc:
			AppleScriptRunner.runLiveEsc();
			return successResponse();
		case livespace:
			AppleScriptRunner.runLiveSpace();
			return successResponse();
		case livequit:
			AppleScriptRunner.runLiveQuit();
			return successResponse();
		case loadtimeout:
			runner.actionLoaded();
			return successResponse();
		case quit:
			quit();
			return errorResponse(NanoHTTPD.HTTP_INTERNALERROR, "Goodbye.");
		case restart:
			restart();
			return errorResponse(NanoHTTPD.HTTP_INTERNALERROR, "Back soon.");
		case livescreenshot:
			AppleScriptRunner.runLiveActivate();
			// FALLS THROUGH 
		case screenshot:
			return screenshotWrapperResponse();
		case setlist:
			return setListResponse();
		case queue:
			return queueResponse();
		default:
			return errorResponse(NanoHTTPD.HTTP_INTERNALERROR, "Unimplemented action " + actionStr + ".  Move that ass, boy!");
		}
	}
	
	/**
	 * Generate generic error response
	 * @param code HTTP response code
	 * @param msg HTML to inject into body
	 * @return response
	 */
	protected Response errorResponse(String code, String msg) {
		String out = "<html><head><title>O NOES!</title></head><body>" 
			+ msg + "</body></html>";
		return new Response(code, "text/html", out);
	}
	
	/**
	 * Generates generic, empty success response
	 * @return response
	 */
	protected Response successResponse() {
		return new Response(NanoHTTPD.HTTP_OK, "text/html", "");
	}
	
	/**
	 * Generates response including screenshot
	 * @return response
	 */
	protected Response screenshotWrapperResponse() {
		try {
			Runtime.getRuntime().exec("/usr/sbin/screencapture -x " + new File("").getAbsolutePath() + "/screenshot.png");
			Thread.sleep(SCREENSHOT_DELAY);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			Logger.warn(e);
			return errorResponse(NanoHTTPD.HTTP_INTERNALERROR, "can't generate screenshot");
		}
		
		String out = "<html><head><title>SEE!</title></head><body><img src='/screenshot.png'></body></html>";
		return new Response(NanoHTTPD.HTTP_OK, "text/html", out);
	}
	
	protected Response setListResponse() {
		String listString = list.toString();
		String out = "{" + listString + "}";
		return new Response(NanoHTTPD.HTTP_OK, "text/html", out);
	}
	
	protected Response queueResponse() {
		String queueString = runner.queueToString();
		String out = "{" + queueString + "}";
		return new Response(NanoHTTPD.HTTP_OK, "application/json", out);
	}
	
	/**
	 * Quit switcher; waits 2 seconds (hack!) to make sure the response is delivered
	 */
	void quit() {
		Logger.warn("Quitting.");
		new Thread(new Runnable() {
			
			@Override
			public void run() {
				try {
					Thread.sleep(2000);
				} catch (InterruptedException ie) {
					// TODO Auto-generated catch block
				}
				System.exit(0);			
			}
		}).start();
	}
	
	/**
	 * Restarts switcher
	 */
	void restart() {
		Logger.warn("Restarting -- not yet implemented");
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

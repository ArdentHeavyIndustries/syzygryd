package com.syzygryd;

import java.io.IOException;
import java.util.Properties;

/**
 * Provides web interface that serves up pages (including setlist) and responds to
 * actions
 *
 */
public class Syzyweb extends NanoHTTPD {

	public static String kActionUriPrefix = "/sz/";
	private ActionRunner runner = null;
	public Syzyweb(int port, ActionRunner ar) throws IOException {
		super(port);
		runner = ar;
	}
	
	// passes on to our handlers if it starts with /sz/; otherwise falls through to theirs
	public Response serve( String uri, String method, Properties header, Properties params ) {
		if (uri != null && uri.length() > kActionUriPrefix.length() + 1) {
			if (uri.startsWith(kActionUriPrefix)) {
				Response r = act(uri,method,header,params);
				if (r == null) {
					r = super.serve(uri,method,header,params);
				}
				return r;
			} 
		}
		
		return super.serve(uri, method, header, params);
	}
	
	// finds a command we support and passes on to it; otherwise returns null
	protected Response act( String uri, String method, Properties header, Properties params ) {
		int endOfAction = uri.indexOf('?');
		
		endOfAction = (endOfAction > 0 ? endOfAction : uri.length());
		
		String actionStr = uri.substring(kActionUriPrefix.length(), endOfAction);
		Action.ActionType a = null;
		try {
			a = Action.ActionType.valueOf(actionStr.toLowerCase());
		} catch (IllegalArgumentException e) {
			System.err.println("No such action " + actionStr);
			return errorResponse("500", "Invalid action: " + actionStr + ". nice try, k1dd135.");
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
		default:
			return errorResponse("500", "Unimplemented action " + actionStr + ".  Move that ass, boy!");
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
		return new Response("200", "text/html", "");
	}

}

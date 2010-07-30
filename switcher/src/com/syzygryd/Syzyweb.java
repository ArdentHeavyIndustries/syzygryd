package com.syzygryd;

import java.io.IOException;
import java.util.Properties;

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
		
		String actionStr = uri.substring(kActionUriPrefix.length()-1, endOfAction);
		Action.ActionType a = null;
		try {
			a = Action.ActionType.valueOf(actionStr);
		} catch (IllegalArgumentException e) {
			System.err.println("No such action " + actionStr);
			return errorResponse("500", "Invalid action: " + actionStr + ". nice try, k1dd135.");
		}
		
		boolean queue = false;
		if (params != null) {
			queue = params.getProperty("queue", "0").equals("1");
		}
		
		switch (a) {
		case set:
		case next:
		case prev:
			runner.doAction(queue, new Action(a, params));
			return successResponse();
		default:
			return errorResponse("500", "Unimplemented action " + actionStr + ".  Move that ass, boy!");
		}
	}
	
	protected Response errorResponse(String code, String msg) {
		String out = "<html><head><title>O NOES!</title></head><body>" 
			+ msg + "</body></html>";
		return new Response(code, "text/html", out);
	}
	
	protected Response successResponse() {
		return new Response("200", "text/html", "");
	}

}

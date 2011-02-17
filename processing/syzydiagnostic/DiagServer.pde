// Diagnostic server handles requests made to fixtures
// Code adapted from switcher

import java.io.File;
import java.util.Properties;
import java.io.IOException;

public class DiagServer extends NanoHTTPD {
  
  public static final String ACTION_URI_PREFIX = "/diag/";
  // Setup diagnostic server
  public DiagServer() throws IOException
  {
    super(51230);
  }
 
 public Response serve(String uri, String method, Properties header, Properties params, Properties files) {
  if (uri != null && uri.length() > ACTION_URI_PREFIX.length() + 1) {
    if (uri.startsWith(ACTION_URI_PREFIX)) {
      Response r = act(uri,method,header,params,files);
      if (r == null) {
        r = super.serve(uri,method,header,params,files);
      }
      return r;
    }
  }
  
  return super.serve(uri,method,header,params,files);
 }
 
 protected Response act(String uri, String method, Properties header, Properties params, Properties files) {
   println("uri: "+uri);
   
   return new Response(NanoHTTPD.HTTP_OK, "text/html", "");
}

}

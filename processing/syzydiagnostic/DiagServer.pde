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
//   Capture the action we are doing
   int rv,gv,bv;

   int endOfAction = uri.indexOf('?');
   endOfAction = (endOfAction > 0 ? endOfAction : uri.length());
   String actionStr = uri.substring(ACTION_URI_PREFIX.length(), endOfAction);
   
   println(actionStr);
   
        // Now let's map our dmx channel values
     rv = int(map(int(params.getProperty("r","0")),0,100,0,255));
     gv = int(map(int(params.getProperty("g","0")),0,100,0,255));
     bv = int(map(int(params.getProperty("b","0")),0,100,0,255));
   
     //Let's grab our params and run!
     if (params.getProperty("cube")!=null && params.getProperty("arm")!=null) {
     int cube = int(params.getProperty("cube"));
     String arm = params.getProperty("arm");
     // Let's convert the cube number to dmx channels
     int rc = ((cube+1)*3)-3;
     int gc = ((cube+1)*3)-2;
     int bc = ((cube+1)*3)-1;
     println("Cube "+str(cube)+" DMX Channels (RGB): "+str(rc)+","+str(gc)+","+str(bc));
     // Now let's map our dmx channel values
     // Yo dawg, I heard you like DMX
     dmxs.sendDMX(0,rc,rv);
     dmxs.sendDMX(0,gc,gv);
     dmxs.sendDMX(0,bc,bv);
     } else if (params.getProperty("arm")!=null && params.getProperty("cube")==null) {
       //Send everything to an arm
       println("Sending to an entire arm");
       
       //Let's grab our params
      //Let's pass through the rest of the parameters to an entire arm
     for (int ch=1; ch < MAX_LIGHTING_CHANNEL; ch++) {
         dmxs.sendDMX(0,ch,rv);
         dmxs.sendDMX(0,ch,gv);
         dmxs.sendDMX(0,ch,bv);
     }
     } else if (params.getProperty("arm")==null && params.getProperty("cube")==null && params.getProperty("dmx")==null && params.getProperty("firedance")==null) {
   for (int i = dmxs.getSize()-1; i >=0; i--) {
    for (int ch=1; ch < MAX_LIGHTING_CHANNEL; ch++) {
     dmxs.sendDMX(i,ch,rv);
     dmxs.sendDMX(i,ch,gv);
     dmxs.sendDMX(i,ch,bv);
     delay(15);
    }
   }
 }
 
     
     
 return new Response(NanoHTTPD.HTTP_OK, "text/html", "ACK "+actionStr);
 }
 
 protected int convertArmtoInt(String arm) {
  int r;
  r = 0;
  char c = arm.charAt(0);
 switch(c) {
  case 'A':
  case 'a':
   r = 0;
  case 'B':
  case 'b':
   r = 1;
  case 'C':
  case 'c':
   r = 2;
 }
 return r;
 }

}

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 2
**   tab-width: 2
**   indent-tabs-mode: nil
** End:
**
** vim: softtabstop=2 tabstop=2 expandtab cindent shiftwidth=2
**
*/

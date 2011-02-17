import nanohttpd.*;

void setup() {
 try {
  NanoHTTPD nh = new NanoHTTPD(51230); 
 }
 catch( IOException ioe) {
   println("IOException: " + ioe);
 }
 println("Server running on port 51230");
}

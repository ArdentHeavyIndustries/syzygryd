import processing.serial.*;

//Quick DMX System
QuickDMXSystem dmxs;
int MAX_LIGHTING_CHANNEL = 117;

void setup() {
// Let's create a DMX system
dmxs = new QuickDMXSystem();
dmxs.initialize(this);
println(Serial.list());
// Uncomment the lines below for entec devices connected to the computer
//dmxs.addentec(this, ""); // Arm A
dmxs.addentec("/dev/cu.usbserial-EN077490"); // Arm B
//dmxs.addentec(this, ""); // Arm C

// Let's turn on the web service
  try {
  
  // Due to the fact NanoHTTPD would need to be rewritten to respect sketchbook directory vs Application directory
  // Keep in mind that any requests made to the web server will use /Applications as it's Home directory unless
  // syzydiagnostic is compiled.  
  new DiagServer();
 }
 catch( IOException ioe) {
   println("IOException: " + ioe);
 }
 println("Diagnostic server running on port 51230");
}

void draw() {
  
}

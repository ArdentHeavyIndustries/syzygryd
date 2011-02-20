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
  try {
    //  dmxs.addentec("/dev/cu.usbserial-EN077331"); // Arm A
    dmxs.addentec("/dev/cu.usbserial-EN077490"); // Arm B
    //  dmxs.addentec("/dev/cu.usbserial-EN075581"); // Arm C
  } catch (Exception e) {
    println("Entecs Missing!");
    e.printStackTrace();
    exit();
  }

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

void mouseClicked() {
  dmxs.strikeAllFixtures(); 
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

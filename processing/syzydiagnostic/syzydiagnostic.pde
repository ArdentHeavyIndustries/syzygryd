import processing.serial.*;

import java.io.FileReader;
import java.io.IOException;
import java.util.Properties;

Properties props;

// Read configuration from a properties file
// linux or mac
final String PROPS_FILE = "/opt/syzygryd/etc/syzydiagnostic.properties";
// windows
//final String PROPS_FILE = "C:\syzygryd\etc\syzydiagnostic.properties";

//Quick DMX System
QuickDMXSystem dmxs;
int MAX_LIGHTING_CHANNEL = 117;

void addEnttec(String key) {
  String enttec = props.getProperty(key);
  if (enttec != null && !("".equals(enttec)) && !("/dev/cu.usbserial-XXXXXXXX".equals(enttec))) {
    System.out.println("Adding enttec " + enttec);
    dmxs.addenttec(enttec);
  } else {
    System.err.println("Not adding enttec " + key + ".  Edit " + PROPS_FILE + " to set");
  }
}

void setup() {
  // Let's create a DMX system
  dmxs = new QuickDMXSystem();
  dmxs.initialize(this);
  System.out.println("All available serial devices follow.");
  System.out.println("Enttecs should appear as \"/dev/cu.usbserial-XXXXXXXX\", where XXXXXXXX is some unique identifier.");
  String[] list = Serial.list();
  for (int i = 0; i < list.length; i++) {
    System.out.println(list[i]);
  }

  props = new Properties();
  System.out.println("Loading properties from " + PROPS_FILE);
  try {
    props.load(new FileReader(PROPS_FILE));
  } catch (IOException ioe) {
    System.err.println("Can't load properties file, please add Enttec serial numbers: " + PROPS_FILE);
  }

  try {
    // Edit the properties file to configure these
    addEnttec("enttec0");	// Arm A
    addEnttec("enttec1");	// Arm B
    addEnttec("enttec2");	// Arm C
  } catch (Exception e) {
    System.err.println("Enttecs Missing!");
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
    System.err.println("Exception starting web service: " + ioe);
  }
  System.out.println("Diagnostic server running on port 51230");
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

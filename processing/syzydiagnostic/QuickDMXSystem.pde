import codeanticode.prodmx.*;

public class QuickDMXSystem {
  
  ArrayList enttecs;
  PApplet _processingObject;
  
  // Initalize the DMX system
  void initialize(PApplet passthrough) {
   _processingObject = passthrough;
   enttecs = new ArrayList(); 
  }
  
  // Add an enttec device
  void addenttec(String serialDeviceName) {
    enttecs.add( new DMX(_processingObject, serialDeviceName, 115200, MAX_LIGHTING_CHANNEL) );
  }
  
  // SendDMX
  void sendDMX(int arm, int channel, int value) {
    DMX dmx = (DMX) enttecs.get(arm);
    println("Send DMX: Arm "+str(arm)+", Channel "+str(channel)+", Value "+str(value));
    dmx.setDMXChannel(channel, value);
  }
 
  
  // Strike all the fixtures
  void strikeAllFixtures() {
   // Go through each device and strike all the channels.
   for (int i = enttecs.size()-1; i >=0; i--) {
    DMX dmx = (DMX) enttecs.get(i);
    for (int ch=1; ch < MAX_LIGHTING_CHANNEL; ch++) {
     dmx.setDMXChannel(ch,0);
     println("Striking channel "+str(ch));
    }
   }
   
  }
  
  void quickTestAllFixtures() {
   for (int i = enttecs.size()-1; i >=0; i--) {
    DMX dmx = (DMX) enttecs.get(i);
    for (int ch=1; ch < MAX_LIGHTING_CHANNEL; ch++) {
     dmx.setDMXChannel(ch,255);
     println("Striking channel "+str(ch));
    }
   } 
  }
  
  public int getSize() {
    return enttecs.size();
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

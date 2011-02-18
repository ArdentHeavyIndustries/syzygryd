import codeanticode.prodmx.*;

public class QuickDMXSystem {
  
  ArrayList entecs;
  PApplet _processingObject;
  
  // Initalize the DMX system
  void initialize(PApplet passthrough) {
   _processingObject = passthrough;
   entecs = new ArrayList(); 
  }
  
  // Add an entec device
  void addentec(String serialDeviceName) {
    entecs.add( new DMX(_processingObject, serialDeviceName, 115200, MAX_LIGHTING_CHANNEL) );
  }
  
  // SendDMX
  void sendDMX(int arm, int channel, int value) {
    DMX dmx = (DMX) entecs.get(arm);
    println("Send DMX: Arm "+str(arm)+", Channel "+str(channel)+", Value "+str(value));
    dmx.setDMXChannel(channel, value);
  }
 
  
  // Strike all the fixtures
  void strikeAllFixtures() {
   // Go through each device and strike all the channels.
   for (int i = entecs.size()-1; i >=0; i--) {
    DMX dmx = (DMX) entecs.get(i);
    for (int ch=0; ch < MAX_LIGHTING_CHANNEL; ch++) {
     dmx.setDMXChannel(ch,0);
     println("Striking channel "+str(ch));
    }
   }
   
  }
  
  public int getSize() {
    return entecs.size();
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

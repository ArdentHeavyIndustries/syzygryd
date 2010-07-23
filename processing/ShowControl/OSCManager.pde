/*
 * The OSCManager object encapsulates the functions necessary to create an OSC listener object with a network 
 * connection to the sequencer, listen for incoming OSC events, and act upon them.
 */

class OSCManager {
  OscP5 oscP5;

  /*
   * Creates network connection to sequencer to listen for OSC messages
   */
  OSCManager(String _remoteHost){
    NetAddress myRemoteLocation;

    // start oscP5, listening for incoming messages on port 9000
    oscP5 = new OscP5(this, 9000);

    // myRemoteLocation is set to the address and port the sequencer
    // listens on
    myRemoteLocation = new NetAddress(_remoteHost, 8000);

    // Connect to the server
    OscMessage connect = new OscMessage("/server/connect");
    oscP5.send(connect, myRemoteLocation);
  }

  
  /*
   * Listens for incoming OSC messages and acts upon them
   */
  void oscEvent(OscMessage m) {
    
    // Enable the following line for OSC message debugging purposes
    // println("controller_display.oscEvent: addrPattern(): " + m.addrPattern());
    

    if(m.addrPattern().endsWith("/tempo")) {
       events.fire("tick",true); // This should probably be called something other than 'tick' with the new sequencer
       sequencerState.timeOfLastStep = millis();
      // TODO: Calculate tick interval/BPS, store to SequencerState object
      
    }

    if (m.addrPattern().endsWith("/sync")) {
      int panelIndex = m.get(0).intValue();
      int numTabs = m.get(1).intValue();
      int numRows = m.get(2).intValue();
      int numCols = m.get(3).intValue();
      String valueString = m.get(4).stringValue();

      int nextIndex = 0;
      for (int i = 0; i < numTabs; i++) {
        for (int j = 0; j < numRows; j++) {
          for (int k = 0; k < numCols; k++) {
            sequencerState.notes[panelIndex][i][k][j] = (boolean)(valueString.charAt(nextIndex++) == '1');
          }
        }
      }
      return;
    }

    if (m.isPlugged()) {
      return;
    }
  }

}




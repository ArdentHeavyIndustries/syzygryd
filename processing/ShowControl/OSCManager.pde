/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
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
    //println("controller_display.oscEvent: addrPattern(): " + m.addrPattern());
    
    if(m.addrPattern().endsWith("/tempo")) {
       events.fire("tick",true); // This should probably be called something other than 'tick' with the new sequencer
       sequencerState.timeOfLastStep = millis();
       // TODO: Calculate tick interval/BPS, store to SequencerState object
      
    }

    if (m.addrPattern().endsWith("/sync")) {
      double ppqPosition = m.get(0).doubleValue();
      double timeInSeconds = m.get(1).doubleValue();
      double bpm = m.get(2).doubleValue();
      int panelIndex = m.get(3).intValue();
      int curTab = m.get(4).intValue();
      int numTabs = m.get(5).intValue();
      int numRows = m.get(6).intValue();
      int numCols = m.get(7).intValue();
      byte[] blob = m.get(8).blobValue();
        if (blob == null) {
          System.err.println("WARNING: null blob");
          return;
        }

      int index = 0;
      for (int i = 0; i < numTabs; i++) {
        for (int j = 0; j < numRows; j++) {
          for (int k = 0; k < numCols; k++) {
            int byteSel = index / 8;
            int bitSel = index % 8;
            index++;
            sequencerState.notes[panelIndex][i][k][j] = ((blob[byteSel] & (1 << (7 - bitSel))) != 0);
          }
        }
      }
      return;
    }

    // any other osc messages, ignore
  }

}

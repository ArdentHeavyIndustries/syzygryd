/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/*
 * The OSCManager object encapsulates the functions necessary to create an OSC listener object with a network 
 * connection to the sequencer, listen for incoming OSC events, and act upon them.
 */

class OSCManager {
  OscP5 oscP5;
  NetAddress myRemoteLocation;

  /*
   * Creates network connection to remote server to send messages; opens local port to listen for messages.
   */
  OSCManager(String _remoteHost, int _incomingPort, int _outgoingPort){
    println("Creating OSCManager, sending to " + _remoteHost + ":" + _outgoingPort + ", listening on " + _incomingPort);

    // start oscP5, listening for incoming messages
    oscP5 = new OscP5(this, _incomingPort);
    if (oscP5 == null) {
      System.err.println("WARNING: (incoming) OscP5 object is null");
    }

    // myRemoteLocation is set to the address and port the remote host
    // listens on
    myRemoteLocation = new NetAddress(_remoteHost, _outgoingPort);
    if (myRemoteLocation == null) {
      System.err.println("WARNING: (outgoing) NetAddress object is null");
    }
  }
  
  /*
   * Sends OSC /color message to update panel UI color
   */
  void sendUIColor(){
    //println ("OSCManager.sendUIColor()");
    if (myRemoteLocation != null){
      OscMessage uiColors = new OscMessage("/color");
      for (int i = 0; i < panelColor.length; i++){
        uiColors.add(panelColor[i]);
        //println("Adding color: " + hex(panelColor[i]));
      }
      oscP5.send(uiColors, myRemoteLocation);
    } else {
      System.err.println("WARNING: no remote host to send color to");
    }
  }

/*
 * Listens for incoming OSC messages and acts upon them
 */
void oscEvent(OscMessage m) {

  // Enable the following line for OSC message debugging purposes
//  println("oscEvent: addrPattern(): " + m.addrPattern());

  if (m.addrPattern().endsWith("/sync")) {
    
    lastSyncTimeInMs = millis();
       
    sequencerState.stepPosition = m.get(0).floatValue();      
    
    //print("\nTime: " +lastSyncTimeInMs+"\nGot sync @ step position: " + sequencerState.stepPosition + ", BPM = " + sequencerState.bpm + "\n\n");

    sequencerState.ppqPosition = m.get(1).doubleValue();
    // double timeInSeconds = m.get(2).doubleValue(); // unlikely we'll need sequencer-relative time for anything
    sequencerState.bpm = m.get(3).doubleValue();
    int panelIndex = m.get(4).intValue();
    sequencerState.curTab[panelIndex] = m.get(5).intValue();
    int numTabs = m.get(6).intValue();
    int numRows = m.get(7).intValue();
    int numCols = m.get(8).intValue();
    byte[] blob = m.get(9).blobValue();
    if (blob == null) {
      System.err.println("WARNING: null blob");
      return;
    }
    
    // Decompact state blob to get note values
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
    
  } 
  else if (m.addrPattern().startsWith("/lightControl/") || m.addrPattern().startsWith("/lightColor/") || 
           m.addrPattern().startsWith("/lightSettings/") || m.addrPattern().startsWith("/lightPatterns/") || m.addrPattern().startsWith("/manualFire/") || 
           m.addrPattern().startsWith("/arm0/") || m.addrPattern().startsWith("/arm1/") || m.addrPattern().startsWith("/arm2/") ) {
    processOSCLightEvent(m);

  } else if (m.addrPattern().startsWith("/fireControl/")) {
    processOSCFireEvent(m);

  } else { 
//    println("Unrecognized OSC event: " + m.addrPattern());
  }
}

}

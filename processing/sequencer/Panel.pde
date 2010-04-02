/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
import oscP5.*;
import netP5.*;
import themidibus.*;

class Panel implements OscCommunicationsProvider {
  int id;
  Sequencer parentSequencer;
  NetAddressList myClients = new NetAddressList();
  int myBroadcastPort = 9000;

  Panel(int anId, Sequencer theSequencer) {
    id = anId;
    parentSequencer = theSequencer;
  }


  OscP5 osc() {
    return parentSequencer.osc();
  }


  void connectClient(String clientAddress) {
    if (!myClients.contains(clientAddress, myBroadcastPort)) {
      myClients.add(new NetAddress(clientAddress, myBroadcastPort));
      // No need to transmit pattern copies here.  That should happen in
      // Sequencer.connectClient
    }
  }

  NetAddressList clients() {
    return myClients;
  }

  void gotBeat(int beatNumber) {
    // does nothing in the base class
  }


  void oscEvent(OscMessage theOscMessage) {
    println("Got an unhandled osc message: "+theOscMessage);
  }
}

class ButtonPanel extends Panel {
  int currentPattern = 0;
  int numPatterns = 4;
  Pattern[] patterns = new Pattern[numPatterns];

  ButtonPanel(int anId, Sequencer theSequencer) {
    super(anId, theSequencer);
    for (int i = 0; i < numPatterns; i++) {
      patterns[i] = new Pattern(id, i + 1, parentSequencer.columns, parentSequencer.rows, this);
    }
  }

  void gotBeat(int beatNumber) {
    OscBundle bundle = new OscBundle();
    // 0.03125 = ((1 / 16) / 2).  This puts the temposweep in the middle
    // of the step on TouchOSC.
    float pos = ((float)beatNumber) / 16.0 + 0.03125;
    for (int i = 0; i < numPatterns; i++) {
      String pattern = "/"+id+"_tab"+(i+1)+"/tempo";
      OscMessage m = new OscMessage(pattern);
      m.add(pos);
      bundle.add(m);
    }

    osc().send(bundle, myClients);
  }


  boolean[] columnDataForBeat(int beat) {
    return patterns[currentPattern].getColumn(beat);
  }

  void oscEvent(OscMessage theOscMessage) {
    String[] patternParts = theOscMessage.addrPattern().split("/",-1);
    if (patternParts.length > 2) {
      //println("patternParts = "+patternParts);
      String tabPart = patternParts[2];
      String[] tabParts = tabPart.split("b",-1);
      //println("tabParts[0] = "+tabParts[0]);
      if (tabParts.length > 1) {
        int tabNumber = new Integer(tabParts[1]).intValue();
        //println("Switching to tab #"+tabNumber);
        currentPattern = tabNumber - 1;
        println("panel "+id+", currentPattern = "+currentPattern);
      }
    }
  }
}










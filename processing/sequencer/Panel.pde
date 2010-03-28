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
      // ... and we should probably transmit a copy of all the patterns we have so far, since 
      // this is apparently a newly connected client. TODO.
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
    float pos = ((float)beatNumber) / 16.0 + 0.03125;
    for (int i = 0; i < numPatterns; i++) {
      String pattern = "/"+id+"/tab"+(i+1)+"/tempo";
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










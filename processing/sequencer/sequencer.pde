/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Syzygryd sequencer
 */


import oscP5.*;
import netP5.*;
import themidibus.*;

interface OscCommunicationsProvider {
  OscP5 osc(); // returns an OSC object
  NetAddressList clients(); // returns a list of clients
}

interface MidiBusProvider {
  MidiBus midiBus(); // returns a MidiBus object
}

class Sequencer implements OscCommunicationsProvider, MidiBusProvider {
  // needed by OSC and MidiBus objects
  sequencer parentApp;
  
  // The OSC object which will handle our OSC messages
  OscP5 osc;
  
  // A list of connected clients
  NetAddressList clientAddresses = new NetAddressList();
  
  // The MIDI bus object
  MidiBus midiBus;
  
  // The thingamabobber what will make the sounds play via the MIDI bus and handle incoming MIDI beats
  MusicMaker musicMaker;
  
  // Your basic configurable parameters which will never ever actually change (3 panels, 16 columns, 10 rows each)
  int numPanels = 3, columns = 16, rows = 10;
  
  // An array in which to store our Panel objects
  Panel[] panels;
  
  // A map of notes to play
  int[] scale = {
    60,62,64,67,69,72,74,76,79,81 };

  /* listeningPort is the port the server is listening for incoming messages */
  int myListeningPort = 8000;
  
  /* the broadcast port is the port the clients should listen for incoming messages from the server*/
  int myBroadcastPort = 9000;

  //sets the main tempo
  float minBpm = 40.0;
  float maxBpm = 300.0;
  float bpm = 140.0;

  Sequencer(sequencer aParentApp) {
    parentApp = aParentApp;
    osc = new OscP5(parentApp, myListeningPort);
    MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
    // So this assumes you've set up the IAC Driver (on OS X, under /Apps/Utilities/Audio Midi Setup.app, 
    // click the "MIDI Devices" tab, double-click the "IAC Driver", add a port, and name it "GridSequencer")
    // Then in Live, on each of the three instruments, MIDI From should be "GridSequencer", and channel should
    // be 1, 2, and 3 respectively
    midiBus = new MidiBus(parentApp, "GridSequencer", "GridSequencer");
    musicMaker = new MusicMaker(this, midiBus);
    midiBus.addMidiListener(musicMaker);

    panels = new Panel[numPanels];
    // Create Panel objects. These will intercept OSC messages and serve as our primary abstraction when dealing with the controllers.
    for (int panelNumber = 0; panelNumber < numPanels; panelNumber++) {
      panels[panelNumber] = new ButtonPanel(panelNumber + 1, this);
    }
  }

  void sendOSC(OscMessage aMessage) {
    osc.send(aMessage, clients());
  }


  OscP5 osc() {
    return osc;
  }

  NetAddressList clients() {
    return clientAddresses;
  }

  MidiBus midiBus() {
    return midiBus;
  }

  void gotBeat(int beatNumber) {
    for (int i = 0; i < numPanels; i++) {
      // Update displays (for now, this means move the tempo slider)
      panels[i].gotBeat(beatNumber);
      // Query the panel to find out which buttons are lit for this beat
      boolean[] column = ((ButtonPanel)panels[i]).columnDataForBeat(beatNumber);
      // Now use that information to fill in a vector (like an array) of tones to play
      Vector n = new Vector();
      for (int j = 0; j < rows; j++) {
        if (column[j]) {
          n.add(new Integer(scale[j]));
        }
      }
      // Now play that set of notes on the appropriate MIDI channel
      musicMaker.playNotes(i, n);
    }
  }


  String songPosition() {
    return musicMaker.songPosition();
  }

  void connectClient(String clientAddress) {
    if (!clients().contains(clientAddress, myBroadcastPort)) {
      clients().add(new NetAddress(clientAddress, myBroadcastPort));
      // TODO: ... and we should probably transmit a copy of all the
      // patterns we have so far, since this is apparently a newly
      // connected client.
    }
  }

  /* incoming osc message are forwarded to the oscEvent method. */
  void oscEvent(OscMessage theOscMessage) {
    println("sequencer.oscEvent: addrPattern: " + theOscMessage.addrPattern());
    /*
    println("#### received osc message");
    println("#### addrPattern: " + theOscMessage.addrPattern());
    println("#### typetag: " + theOscMessage.typetag());
    Object[] args = theOscMessage.arguments();
    for (int i = 0; i < args.length; i++) {
      println("#### arg " + i + ": " + args[i]);
    }
    */

    connectClient(theOscMessage.netAddress().address());

    /**
     * FYI this parsing is probably not as robust as we might desire
     * I leave it to the maintainers of the sequencer code to make it
     * suck less. -cubes
     */
    String[] patternParts = theOscMessage.addrPattern().split("/",-1);
    String[] panelTab = patternParts[1].split("_", -1);
    int panelNumber = new Integer(panelTab[0]).intValue();
    int panelIndex = panelNumber - 1;

    if (panelIndex < numPanels) {
      panels[panelIndex].connectClient(theOscMessage.netAddress().address());
    }

    if (!theOscMessage.isPlugged()) {
      panels[panelIndex].oscEvent(theOscMessage);
    }
  }
}

Sequencer s;

void setup() {
  s = new Sequencer(this);
  frameRate(60);
  size(170,80);
  textFont(createFont("Helvetica", 32));
  fill(0, 102, 153);
}

void draw() {
  background(0);
  if (s != null) {
    text(s.songPosition(), 15, 50);
  }
}

void keyPressed() {
}

void oscEvent(OscMessage theOscMessage) {
  s.oscEvent(theOscMessage);
}


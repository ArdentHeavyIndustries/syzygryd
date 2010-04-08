/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Syzygryd sequencer
 */

import syzygryd.*;

import oscP5.*;
import netP5.*;
import themidibus.*;

import com.apple.dnssd.*;

class Sequencer implements com.apple.dnssd.RegisterListener {
  MidiBus midiBus;
  MusicMaker musicMaker;
  int broadcastPort;
  int gridWidth;
  int gridHeight;
  Vector myFullNames = new Vector();
  SequencerPanel[] panels;

  int[] scale = { 81, 79, 76, 74, 72, 69, 67, 64, 62, 60 };

  // sets the main tempo
  float minBpm = 40.0;
  float maxBpm = 300.0;
  float bpm = 140.0;
  
  void operationFailed(DNSSDService svc, int err) {
    println("Bonjour Operation Failed! " + svc + " err = " + err);
  }
  
  void serviceRegistered(DNSSDRegistration reg, int flags, String serviceName, String regType, String domain) {
    try {
      // We should keep track of the DNS names of this sequencer so later when we autodiscover clients we don't rediscover ourselves
      // (I mean, metaphorically it's fine I guess, but we don't wanna set up a discovery loop)
      myFullNames.add(DNSSD.constructFullName(serviceName, regType, domain));
    } catch (DNSSDException e) {
      println("Oh noes, DNSSDException in serviceRegistered: " + e);
    }
  }

  Sequencer(PApplet parent, int _numPanels, int _numTabs, int _gridWidth, int _gridHeight, int _broadcastPort) {
    // Look at availableInputs and availableOutputs
    // "IAC Driver - GridSequencer"
    midiBus = new MidiBus(parent, "GridSequencer", "GridSequencer");

    musicMaker = new MusicMaker(this, midiBus);
    midiBus.addMidiListener(musicMaker);

    broadcastPort = _broadcastPort;
    gridWidth = _gridWidth;
    gridHeight = _gridHeight;
    panels = new SequencerPanel[_numPanels];
    for (int i = 0; i < panels.length; i++) {
      panels[i] = new SequencerPanel(i, panels, _numTabs, _gridWidth, _gridHeight, _broadcastPort);
    }
    
    // Magical service discovery goodness, w00t
    try {
      String myName = "SyzySequencer on " + java.net.InetAddress.getLocalHost().getHostName();
      DNSSDRegistration receiver = DNSSD.register(myName, "_osc._udp", 8000, this);
      DNSSDRegistration sender = DNSSD.register(myName, "_sequencer._udp", 9000, this);
    } catch(DNSSDException e) {
      println("Oh noes, DNSSDException: "+e);
    } catch (java.net.UnknownHostException uhe) {
      println("Oh noes, UnknownHostException: "+uhe);
    }
  }

  void gotBeat(int beatNumber) {
    for (int i = 0; i < panels.length; i++) {
      // Update displays (for now, this means move the tempo slider)
      panels[i].gotBeat(beatNumber);

      // Grab a column of buttons from the panel's selected tab
      Button[] col = (Button[]) ((SequencerPatternTab) panels[i].selectedTab).buttons[beatNumber];

      // Now use that information to fill in a vector of tones to play
      Vector n = new Vector();
      for (int j = 0; j < gridHeight; j++) {
        if (((SequencerButton) col[j]).isOn) {
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
    if (!globalClients.contains(clientAddress, broadcastPort)) {
      globalClients.add(new NetAddress(clientAddress, broadcastPort));
      // TODO: ... and we should probably transmit a copy of all the
      // patterns we have so far, since this is apparently a newly
      // connected client.
    }
  }

  /* incoming osc message are forwarded to the oscEvent method. */
  void oscEvent(OscMessage m) {
    println("sequencer.oscEvent: addrPattern: " + m.addrPattern());
    /*
    println("#### received osc message");
    println("#### addrPattern: " + m.addrPattern());
    println("#### typetag: " + m.typetag());
    Object[] args = m.arguments();
    for (int i = 0; i < args.length; i++) {
      println("#### arg " + i + ": " + args[i]);
    }
    */

    connectClient(m.netAddress().address());

    /**
     * FYI this parsing is probably not as robust as we might desire
     * I leave it to the maintainers of the sequencer code to make it
     * suck less. -cubes
     */
    String[] patternParts = m.addrPattern().split("/",-1);
    String[] panelAndTab = patternParts[1].split("_", -1);
    int panelOscIndex = new Integer(panelAndTab[0]).intValue();
    int panelIndex = panelOscIndex - 1;

    if (panelIndex < panels.length) {
      panels[panelIndex].connectClient(m.netAddress().address());
    }

    if (!m.isPlugged()) {
      panels[panelIndex].oscEvent(m);
    }
  }  
}

Sequencer s;
OscP5 oscP5;
NetAddressList globalClients = new NetAddressList();

void setup() {
  frameRate(60);
  size(170,80);
  textFont(createFont("Helvetica", 32));
  fill(0, 102, 153);

  /* listeningPort is the port the server is listening for incoming messages */
  int myListeningPort = 8000;

  /* the broadcast port is the port the clients should listen for
   * incoming messages from the server */
  int myBroadcastPort = 9000;

  oscP5 = new OscP5(this, myListeningPort);

  int numPanels = 3;
  int numTabs = 4;
  int gridWidth = 16;
  int gridHeight = 10;

  s = new Sequencer(this, numPanels, numTabs, gridWidth, gridHeight, myBroadcastPort);
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


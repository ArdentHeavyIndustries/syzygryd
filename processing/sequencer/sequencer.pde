

/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Syzygryd sequencer
 */

import syzygryd.*;

import guicomponents.*;
import oscP5.*;
import netP5.*;
import themidibus.*;

import com.apple.dnssd.*;

class Sequencer implements com.apple.dnssd.RegisterListener {
  MidiBus midiBus;
  String midiInput;
  String midiOutput;
  MusicMaker musicMaker;
  int broadcastPort;
  int gridWidth;
  int gridHeight;
  Vector myFullNames = new Vector();
  DNSSDRegistration receiver;
  DNSSDRegistration sender;
  SequencerPanel[] panels;
  Life life;  
  boolean lifeRunning = false;
  int lifeStepBeats;

  int[] scale = { 
    81, 79, 76, 74, 72, 69, 67, 64, 62, 60   };

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
    } 
    catch (DNSSDException e) {
      println("Oh noes, DNSSDException in serviceRegistered: " + e);
    }
  }

  Sequencer(PApplet parent, int _numPanels, int _numTabs, int _gridWidth, int _gridHeight, String _midiInput, String _midiOutput, int _broadcastPort) {
    midiInput = _midiInput;
    midiOutput = _midiOutput;
    midiBus = new MidiBus(parent, midiInput, midiOutput);

    broadcastPort = _broadcastPort;
    gridWidth = _gridWidth;
    gridHeight = _gridHeight;
    panels = new SequencerPanel[_numPanels];
    for (int i = 0; i < panels.length; i++) {
      panels[i] = new SequencerPanel(i, panels, _numTabs, _gridWidth, _gridHeight, _broadcastPort);
    }

    musicMaker = new MusicMaker(this, midiBus);
    midiBus.addMidiListener(musicMaker);

    // Magical service discovery goodness, w00t
    try {
      String myName = "SyzySequencer on " + java.net.InetAddress.getLocalHost().getHostName();
      receiver = DNSSD.register(myName, "_osc._udp", 8000, this);
      sender = DNSSD.register(myName, "_sequencer._udp", 9000, this);
    } 
    catch(DNSSDException e) {
      println("Oh noes, DNSSDException: "+e);
    } 
    catch (java.net.UnknownHostException uhe) {
      println("Oh noes, UnknownHostException: "+uhe);
    }
  }

  void setInput(String newMidiInput) {
    midiBus.removeInput(midiInput);
    midiInput = newMidiInput;
    midiBus.addInput(newMidiInput);
  }

  void setOutput(String newMidiOutput) {
    midiBus.removeOutput(midiOutput);
    midiOutput = newMidiOutput;
    midiBus.addOutput(newMidiOutput);
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
    if (lifeRunning && (beatNumber % lifeStepBeats == 0)) {
      oneLifeStep();
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
     println("#### isPlugged: " + m.isPlugged());
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
    System.out.println("   patternParts: " + patternParts + " panel osc ind: " + panelOscIndex + " panelInd: " + panelIndex + " panels.length:" + panels.length);

    if (panelIndex < panels.length) {
      panels[panelIndex].connectClient(m.netAddress().address());
    }

    if (!m.isPlugged()) {
      panels[panelIndex].oscEvent(m);
    }
  }  

  void toggleLife() {
    maybeSetupLife();
    lifeRunning = !lifeRunning;
  }

  void oneLifeStep() {
    maybeSetupLife();
    life.oneStep();
  }

  void maybeSetupLife() {
    if (life == null) {
      //System.out.println("Making a life. panels: " + panels.length + " gw: " + gridWidth + " gh: " + gridHeight);
      life = new Life(panels.length, panels, 
      gridWidth, gridHeight,
      CONWAY_S23B3);
      lifeStepBeats = gridWidth;
    }
  }

  void speedLifeUp() {
    lifeStepBeats --;
    if (lifeStepBeats < 1) {
      lifeStepBeats = 1;
    }
  }

  void slowLifeDown() {
    lifeStepBeats++;
    if (lifeStepBeats >= gridWidth) {
      lifeStepBeats = gridWidth - 1;
    }
  }

  void clearAll() {
    for (int i = 0; i < panels.length; i++) {
      ((SequencerPatternTab) panels[i].selectedTab).clear();
    }
  }
}

Sequencer s;
OscP5 oscP5;
GCombo cboMidiInput, cboMidiOutput;
GLabel labelMidiInput, labelMidiOutput;
NetAddressList globalClients = new NetAddressList();

void setup() {
  frameRate(60);
  size(400,70);
  textFont(createFont("Helvetica", 32));

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

  String[] availableIns = MidiBus.availableInputs();
  String[] availableOuts = MidiBus.availableOutputs();

  labelMidiInput = new GLabel(this, "Midi Input:", 0, 0, 65);
  cboMidiInput = new GCombo(this, availableIns, 4, 65, 0, 130);
  labelMidiOutput = new GLabel(this, "Midi Output:", 195, 0, 75);
  cboMidiOutput = new GCombo(this, availableOuts, 4, 270, 0, 130);

  for (int i = 0; i < availableIns.length; i++) {
    if (availableIns[i].matches(".*GridSequencer.*") ||
      availableIns[i].matches("In From MIDI Yoke:  2")) {
      cboMidiInput.setSelected(availableIns[i]);
      break;
    }
  }

  for (int i = 0; i < availableOuts.length; i++) {
    if (availableOuts[i].matches("GridSequencer") ||
      availableOuts[i].matches("Out To MIDI Yoke:  1")) {
      cboMidiOutput.setSelected(availableOuts[i]);
      break;
    }
  }

  textFont(createFont("Helvetica", 32));

  s = new Sequencer(
  this,
  numPanels,
  numTabs,
  gridWidth,
  gridHeight,
  cboMidiInput.selectedText(),
  cboMidiOutput.selectedText(),
  myBroadcastPort);
}

void stop() {
  s.receiver.stop();
  s.sender.stop();
  super.stop();
}

void draw() {
  background(0);
  if (s != null) {
    fill(0, 102, 153);
    text(s.songPosition(), 150, 50);
  }

  fill(255, 255, 255);
  rect(0, 0, 360, 15);
}

void keyPressed() {
  if (key == 'l') {
    s.toggleLife();
  } 
  else if (key == 'L') {
    System.out.println("Pressed L");
    s.oneLifeStep();
  } 
  else if (key == '+') {
    s.speedLifeUp();
  } 
  else if (key == '-') {
    s.slowLifeDown();
  } 
  else if (key == 'C') {
    s.clearAll();
  }
}

void handleComboEvents(GCombo combo) {
  if (combo == cboMidiInput) {
    s.setInput(combo.selectedText());
  } 
  else if (combo == cboMidiOutput) {
    s.setOutput(combo.selectedText());
  }
}

void oscEvent(OscMessage theOscMessage) {
  s.oscEvent(theOscMessage);
}



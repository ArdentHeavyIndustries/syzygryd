/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

/**
 * The SequencerPanel class maintains a list of network clients which it
 * broadcasts status updates to.
 */
class SequencerPanel extends Panel {
  NetAddressList clients;
  int broadcastPort;

  SequencerPanel(int _id, SequencerPanel[] _allPanels, int _ntabs, int _gridWidth, int _gridHeight, int _broadcastPort) {
    super(_id, _allPanels, _ntabs);

    clients = new NetAddressList();
    broadcastPort = _broadcastPort;
    for (int i = 0; i < tabs.length; i++) {
      tabs[i] = new SequencerPatternTab(i, this, _gridWidth, _gridHeight);
    }
    selectTab(0);
  }

  void connectClient(String clientAddress) {
    if (!clients.contains(clientAddress, broadcastPort)) {
      clients.add(new NetAddress(clientAddress, broadcastPort));
      // No need to transmit pattern copies here.  That should happen in
      // Sequencer.connectClient
    }
  }

  void gotBeat(int beatNumber) {
    OscBundle bundle = new OscBundle();
    float pos = ((float) beatNumber) / 16.0 + 0.03125;
    for (int i = 0; i < tabs.length; i++) {
      String pattern = "/" + getOscId() + "_" + tabs[i].getOscId() + "/tempo";
      OscMessage m = new OscMessage(pattern);
      m.add(pos);
      bundle.add(m);
    }

    oscP5.send(bundle, clients);
  }

  // TODO: Fix this up to, you know actually switch tabs. :)
  void oscEvent(OscMessage m) {
    /*
    String[] patternParts = m.addrPattern().split("/",-1);
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
    */
  }
}

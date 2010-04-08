/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

/**
 * The SequencerPanel class maintains a list of network clients which it
 * broadcasts status updates to.
 */
class SequencerPanel extends Panel {
  NetAddressList clients;
  int broadcastPort;
  int currentPattern = 0;

  SequencerPanel(int _id, SequencerPanel[] _allPanels, int _ntabs, int _gridWidth, int _gridHeight, int _broadcastPort) {
    super(_id, _allPanels, _ntabs);

    clients = new NetAddressList();
    broadcastPort = _broadcastPort;
    for (int i = 0; i < tabs.length; i++) {
      tabs[i] = new SequencerPatternTab(i, this, _gridWidth, _gridHeight);
    }
    selectTab(currentPattern);
  }

  void connectClient(String clientAddress) {
    if (!clients.contains(clientAddress, broadcastPort)) {
      clients.add(new NetAddress(clientAddress, broadcastPort));
      // No need to transmit pattern copies here.  That should happen in
      // Sequencer.connectClient
    }
  }

  void gotBeat(int beatNumber) {
    float pos = ((float) beatNumber) / 16.0 + 0.03125;
    String pattern = "/" + getOscId() + "_" + tabs[currentPattern].getOscId() + "/tempo";
    OscMessage m = new OscMessage(pattern);
    m.add(pos);
    oscP5.send(m, clients);
  }

  // TODO: Fix this up to, you know actually switch tabs. :)
  void oscEvent(OscMessage m) {
    // Oh this is so janky. I gotta figure out how to do more sophisticated string parsing in Java.
    // But the regexp module ... urgh. This'll work for now.
    String[] patternParts = m.addrPattern().split("/",-1);
    if (patternParts.length > 1) {
      String tabPart = patternParts[1];
      // Waitaminnit, (jank++)++
      // yes, we're splitting the string on the "b" character in [panel#]_tab[tab#]
      String[] tabParts = tabPart.split("b",-1);
      if (tabParts.length > 1) {
        int tabNumber = new Integer(tabParts[1]).intValue();
        currentPattern = tabNumber - 1;
        selectTab(currentPattern);
        println("panel "+id+", currentPattern = "+currentPattern);
      }
    }
    // mirror the message out to my clients
    oscP5.send(m, clients);
  }
}

/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawablePanel
 */

/**
 * The DrawablePanel class is a Panel that knows how to draw itself.
 */
class DrawablePanel extends syzygryd.Panel implements Drawable {
 int buttonSpacing;
 
  DrawablePanel(int _id, DrawablePanel[] _allPanels, int _ntabs, int _gridWidth, int _gridHeight, int _buttonSize, int _buttonSpacing) {
    super(_id, _allPanels, _ntabs);
    
    for (int i = 0; i < tabs.length; i++) {
      tabs[i] = new DrawableTab(i, this, _gridWidth, _gridHeight, _buttonSize, _buttonSpacing);
    }
    selectTab(0);
    buttonSpacing = _buttonSpacing;
  }

  /**
   * selectTab selects the active tab.
   *
   * @param id is the zero indexed id of the tab to select
   */
  void selectTab(int id) {
    selectTab(id, false);
  }

  /**
   * selectTab selects the active tab, and optionally sends a message
   * indicating the state change.
   *
   * @param id is the zero indexed id of the tab to select
   * @param sendMessage if true, selectTab will send out a message to
   * announce the state change.
   */
  void selectTab(int id, boolean sendMessage) {
    super.selectTab(id);
    if (sendMessage) {
      OscMessage m = new OscMessage(selectedTab.getOscAddress());
      //log("Sending OSC message " + m.addrPattern() + " to " + myRemoteLocation);
      oscP5.send(m, myRemoteLocation);
    }
  }

  void draw() {
    for (int i = 0; i < tabs.length; i++) {
     if ((DrawableTab) tabs[i] != selectedTab){
      ((DrawableTab) tabs[i]).draw();
     }
    }
    ((DrawableTab) selectedTab).draw();
  }
}

/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Panel
 */

class Panel {
  int id;
  Panel[] allPanels;
  int width, height;
  int buttonSize, buttonSpacing;

  Tab[] tabs;
  Tab selectedTab;
  Tab nextPanelSelectedTab;
  Tab prevPanelSelectedTab;

  Panel(int _id, Panel[] _allPanels, int _width, int _height, int _ntabs, int _buttonSize, int _buttonSpacing) {
    id = _id;
    width = _width;
    height = _height;
    allPanels = _allPanels;

    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;

    tabs = new Tab[_ntabs];
    for (int i = 0; i < tabs.length; i++) {
      tabs[i] = new Tab(i, this, _buttonSize, _buttonSpacing);
    }
    selectTab(0);
  }

  void selectTab(int id) {
    selectedTab = tabs[id];
  }

  Panel getNextPanel() {
    return allPanels[(id + 1) % allPanels.length];
  }

  Panel getPrevPanel() {
    int prevId = (id - 1) % allPanels.length;
    if (prevId < 0) {
      // Fuck you java.  This is why we can't have nice things!
      prevId = prevId + allPanels.length;
    }

    return allPanels[prevId];
  }

  int getOscId() {
    return id + 1;
  }

  void draw() {
    nextPanelSelectedTab = getNextPanel().selectedTab;
    prevPanelSelectedTab = getPrevPanel().selectedTab;
    selectedTab.draw();
  }
}


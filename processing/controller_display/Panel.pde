/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawablePanel
 */

class DrawablePanel extends Panel {
  DrawablePanel(int _id, DrawablePanel[] _allPanels, int _ntabs, int gridWidth, int gridHeight, int _buttonSize, int _buttonSpacing) {
    super(_id, _allPanels, _ntabs);

    for (int i = 0; i < tabs.length; i++) {
      tabs[i] = new DrawableTab(i, this, gridWidth, gridHeight, _buttonSize, _buttonSpacing);
    }
    selectTab(0);
  }

  void draw() {
    ((DrawableTab) selectedTab).draw();
  }
}


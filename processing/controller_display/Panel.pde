/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawablePanel
 */

/**
 * The DrawablePanel class is a Panel that knows how to draw itself.
 */
class DrawablePanel extends syzygryd.Panel {
  DrawablePanel(int _id, DrawablePanel[] _allPanels, int _ntabs, int _gridWidth, int _gridHeight, int _buttonSize, int _buttonSpacing) {
    super(_id, _allPanels, _ntabs);

    for (int i = 0; i < tabs.length; i++) {
      tabs[i] = new DrawableTab(i, this, _gridWidth, _gridHeight, _buttonSize, _buttonSpacing);
    }
    selectTab(0);
  }

  void draw() {
    ((DrawableTab) selectedTab).draw();
  }
}


/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawableMiniTab
 */

/**
 * DrawableMiniTab class is a miniature representation of a Tab.
 */
class MiniDrawableTab implements Drawable, Pressable {
  DrawableTab tab;
  int x, y;
  int myWidth, myHeight;
  int originX, originY;
  int buttonSize, buttonSpacing;

  MiniDrawableTab(DrawableTab _tab, int _x, int _y, int _width, int _height, int _buttonSize, int _buttonSpacing) {
    tab = _tab;
    x = _x;
    y = _y;

    myWidth = _width;
    myHeight = _height;

    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;

    originX = ((myWidth - (buttonSpacing * tab.gridWidth)) / 2) + x;
    originY = ((myHeight - (buttonSpacing * tab.gridHeight)) / 2) + y;
  }

  void draw() {
    if (tab.isSelected()) {
      stroke(0, 0, 100);
    } else {
      stroke(0, 100, 100);
    }

    noFill();
    rect(x, y, myWidth, myHeight);

    for (Iterator i = tab.onButtons.values().iterator(); i.hasNext(); ) {
      ((DrawableButton) i.next()).drawMiniTabButton();
    }
  }

  void press() {
    if (tab.isSelected()) {
      return;
    }

    tab.panel.selectTab(tab.id);
  }
}

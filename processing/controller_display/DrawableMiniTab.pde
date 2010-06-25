/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawableMiniTab
 */

/**
 * DrawableMiniTab class is a miniature representation of a Tab.
 */
class DrawableMiniTab implements Drawable, Pressable {
  DrawableTab tab;
  int x, y;
  int myWidth, myHeight;
  int originX, originY;
  int buttonSize, buttonSpacing;
  int frameCount;
  color lastFill, lastStroke;
  color BLACK = color(0);
  color RED = color(0, 100, 100);
  color ARMED = color(359, 74, 93);
  color GREY = color(50);
  color WHITE = color(0, 0, 100);
  float opacity = 0.0;
  int direction = 1;

  DrawableMiniTab(DrawableTab _tab, int _x, int _y, int _width, int _height, int _buttonSize, int _buttonSpacing) {
    tab = _tab;
    x = _x;
    y = _y;

    myWidth = _width;
    myHeight = _height;

    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;

    originX = ((myWidth - (buttonSpacing * tab.gridWidth)) / 2) + x;
    originY = ((myHeight - (buttonSpacing * tab.gridHeight)) / 2) + y;

    frameCount = 0;

    lastFill = BLACK;
    lastStroke = RED;
  }

  void draw() {
//    boolean toggleFill = frameCount % 15 == 0;
//    frameCount++;
    if (tab.isSelected()) {
      lastStroke = WHITE;
    } else {
      lastStroke = RED;
    }

    fill(lastFill, opacity);
    stroke(lastStroke);

    rect(x, y, myWidth, myHeight);

    for (Iterator i = tab.onButtons.values().iterator(); i.hasNext(); ) {
      try {
        ((DrawableButton) i.next()).drawMiniTabButton();
      } catch (ConcurrentModificationException e) {
        // Do nothing, we'll redraw on the next cycle
      }
    }

  }

  String getClearOscAddress() {
    return "/" + tab.panel.getOscId() + "_control/clear/" + tab.getOscId();
  }

  void press() {

      ((DrawablePanel) tab.panel).selectTab(tab.id, true);

  }
}

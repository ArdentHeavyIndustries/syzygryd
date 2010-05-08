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
  color GREY = color(50);
  color WHITE = color(0, 0, 100);

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
    boolean toggleFill = frameCount % 15 == 0;
    frameCount++;

    if (tab.isSelected()) {
      lastStroke = WHITE;
    } else {
      lastStroke = RED;
    }

    if (armClear && toggleFill) {
      if (lastFill == RED) {
        if (tab.isSelected()) {
          lastFill = GREY;
        } else {
          lastFill = BLACK;
        }
      } else {
        lastFill = RED;
      }
    } else {
      if (tab.isSelected()) {
        lastFill = GREY;
      } else {
        lastFill = BLACK;
      }
    }

    fill(lastFill);
    stroke(lastStroke);

    rect(x, y, myWidth, myHeight);

    for (Iterator i = tab.onButtons.values().iterator(); i.hasNext(); ) {
      ((DrawableButton) i.next()).drawMiniTabButton();
    }
  }

  String getClearOscAddress() {
    return "/" + tab.panel.getOscId() + "_control/clear/" + tab.getOscId();
  }

  void press() {
    if (armClear) {
      tab.clear();
      OscMessage m = new OscMessage(getClearOscAddress());
      oscP5.send(m, myRemoteLocation);
    } else {
      if (tab.isSelected()) {
        return;
      }

      ((DrawablePanel) tab.panel).selectTab(tab.id, true);
    }

    armClear = false;
  }
}

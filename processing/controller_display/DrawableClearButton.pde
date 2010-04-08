/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawableClearButton
 */

/**
 * The DrawableClearButton class is a Button the sends the osc clear
 * message when pressed.
 */
class DrawableClearButton extends syzygryd.Button implements Drawable, Pressable {
  int x, y;
  int myWidth, myHeight;

  DrawableClearButton(DrawableTab _tab, int _x, int _y, int _width, int _height) {
    super(_tab);
    x = _x;
    y = _y;
    myWidth = _width;
    myHeight = _height;
  }

  String getOscAddress() {
    return "/" + tab.panel.getOscId() + "_control/clear/" + tab.getOscId();
  }

  OscMessage serializeToOsc() {
    return null;
  }

  void draw() {
    fill(0, 100, 100);
    stroke(0, 100, 100);
    rect(x, y, myWidth, myHeight);
  }

  void press() {
    ((DrawableTab) tab).clear();
    OscMessage m = new OscMessage(getOscAddress());
    oscP5.send(m, myRemoteLocation);
  }
}
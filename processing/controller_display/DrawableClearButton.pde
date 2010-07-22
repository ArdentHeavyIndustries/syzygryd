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
  PShape s;
  
  DrawableClearButton(DrawableTab _tab, int _x, int _y, int _width, int _height) {
    super(_tab);
    x = _x;
    y = _y;
    myWidth = _width;
    myHeight = _height;
    s = loadShape("clear.svg"); //use button3.svg until I can get a good svg for the clear button
   
 }

  String getOscAddress() {
    return "/" + tab.panel.getOscId() + "_control/clear/" + tab.getOscId();
  }

  OscMessage serializeToOsc() {
    return null;
  }

  void draw() {
    stroke(0, 100, 100);
    shape(s, x, y, myWidth, myHeight);
  }

  void press() {
    ((DrawableTab) tab).clear();
    System.out.println("Clear button pressed");
    OscMessage m = new OscMessage(getOscAddress());
    //println("Sending OSC message " + m + " to " + myRemoteLocation);
    oscP5.send(m, myRemoteLocation);
  }
}

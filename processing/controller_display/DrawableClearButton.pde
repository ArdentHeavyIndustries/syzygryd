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
  String clrMsg = "Press a tab above to clear";
  float opacity = 0;

  DrawableClearButton(DrawableTab _tab, int _x, int _y, int _width, int _height) {
    super(_tab);
    x = _x;
    y = _y;
    myWidth = _width;
    myHeight = _height;
    //clrFont = ("Arial-BoldMT-16.vlw");
    clrFont = createFont("Andale Mono",25);

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
    if (!armClear){
      opacity = 0;
    }
    if (armClear) {
      textFont(clrFont);
      textAlign(CENTER);
      fill(0, 0, 99, opacity);
      text(clrMsg, x + .25*myWidth, y + .25*myHeight, .5*myWidth, .75*myHeight);
      opacity += .2;
      if (opacity == 256) {
        opacity = 255;
      }
    }
  }

  void press() {
    armClear = true;

  }
}

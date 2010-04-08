/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawableButton
 */

// NB: The following static methods ideally would be part of the
// Button class, but processing turns classes into inner classes so
// that's not possible.
// See: http://processing.org/reference/environment/index.html#Tabs
// for details.

/**
 * getRow returns the row a button is in
 * @param y the y coordinate of the button's top left pixel
 * @param buttonSpacing the size of the button plus a fudge factor
 * for space between buttons
 * @return the row a button is in
 */
static int getRow(int y, int buttonSpacing) {
  return y / buttonSpacing;
}

/**
 * getCol returns the column a button is in
 * @param x the x coordinate of the button's top left pixel
 * @param buttonSpacing the size of the button plus a fudge factor
 * for space between buttons
 * @return the column a button is in
 */
static int getCol(int x, int buttonSpacing) {
  return x / buttonSpacing;
}

/**
 * The DrawableButton class is a Button that knows how to draw itself.
 */
class DrawableButton extends syzygryd.ToggleButton implements Drawable, Pressable {
  int x, y, sqLength;
  int miniX, miniY, miniLength;
  int sqHue = 100;
  int sqBright = 100;
  int sqAlphaDefault = 30;
  int sqAlpha = sqAlphaDefault;

  boolean setActive;
  
  /* SVG getter business */
  PShape left;
  PShape right;
  PShape middle;
  PShape middleOn;
  PShape fullButton;
  PShape fullButtonActive, middleOnActive, middleActive, rightActive, leftActive;

  DrawableButton(int _col, int _row, DrawableTab _tab, int _x, int _y, int _sqLength, int _miniX, int _miniY, int _miniLength){
    super(_col, _row, _tab);

    x=_x;
    y=_y;
    sqLength=_sqLength;

    miniX = _miniX;
    miniY = _miniY;
    miniLength = _miniLength;

    float scaleFactor, scaleFactorActive;

    /*set up svg layers as objects*/
    fullButton = loadShape("button3.svg");
    scaleFactor = (sqLength/fullButton.width);
    middleOn = fullButton.getChild("middleOn");
    middleOn.scale(scaleFactor);
    left = fullButton.getChild("left");
    left.scale(scaleFactor);
    right = fullButton.getChild("right");
    right.scale(scaleFactor);
    middle = fullButton.getChild("middle");
    middle.scale(scaleFactor);

    fullButtonActive = loadShape("button3.svg");
    scaleFactorActive = ((sqLength/fullButtonActive.width)+.2);
    middleOnActive = fullButtonActive.getChild("middleOn");
    middleOnActive.scale(scaleFactorActive);
    leftActive = fullButtonActive.getChild("left");
    leftActive.scale(scaleFactorActive);
    rightActive = fullButtonActive.getChild("right");
    rightActive.scale(scaleFactorActive);
    middleActive = fullButtonActive.getChild("middle");
    middleActive.scale(scaleFactorActive);

    smooth();
  }

  void setBaseHue(int _newHue){
    sqHue = _newHue;
  }

  int getHue() {
    int hue = sqHue + 33 * panel.id;
    // TODO: Instead of this if statement can we just take this mod 100?
    if (hue > 100) {
      hue -= 100;
    }

    return hue;
  }

  /**
   * draw draws this button
   */
  void draw() {
    /*
    if(onlyIfOn && !isOn) {
      return;
    }
    */
    
    // Draw this panel's buttons
    middle.disableStyle();
    noStroke();
    fill(getHue(), 50, sqBright, sqAlpha);
    shape(middle,x,y);

    // Draw the outlines of the left panel's buttons
    DrawableButton leftSibling = (DrawableButton) getLeftSibling();
    if (leftSibling.isOn) {
      left.disableStyle();
      noStroke();
      fill(leftSibling.getHue(), 100, sqBright, leftSibling.sqAlpha);
      shape(left,x,y);
    }

    // Draw the outlines of the right panel's buttons
    DrawableButton rightSibling = (DrawableButton) getRightSibling();
    if(rightSibling.isOn){
      right.disableStyle();
      noStroke();
      fill(rightSibling.getHue(), 100, sqBright, rightSibling.sqAlpha);
      shape(right,x,y);
    }


    /*
    switch(panel.id) {
    case 0:
      // Test code
      middle.disableStyle();
      noStroke();
      fill(thisHue,50,sqBright,sqAlpha);
      shape(middle,x,y);
      // End test code
      if(setPressed==true){
        left.disableStyle();
        noStroke();
        fill(thisHue,100,sqBright,sqAlpha);
        shape(left,x,y);
      }
      break;
    case 1:
      middle.disableStyle();
      noStroke();
      fill(thisHue,50,sqBright,sqAlpha);
      shape(middle,x,y);
      if(setPressed==true){
        if(setActive) {
          middleOnActive.disableStyle();
          noStroke();
          fill(thisHue+5,100,sqBright,sqAlpha-30);
          shape(middleOnActive,x-10,y-10);
        } else {
          middleOn.disableStyle();
          noStroke();
          fill(thisHue,100,sqBright,sqAlpha);
          shape(middleOn,x,y);
        }

      }
      break;
    case 2:
      if(setPressed==true){
        right.disableStyle();
        noStroke();
        fill(thisHue,100,sqBright,sqAlpha);
        shape(right,x,y);
      }
      break;
    }
    */
  }

  /**
   * drawMiniTabButton draws a miniature representation of this button
   * at it's mini-tab coordinates.
   */
  void drawMiniTabButton() {
    noStroke();
    fill(getHue(), 50, sqBright, sqAlpha);
    rect(miniX, miniY, miniLength, miniLength);
  }

  void press() {
    toggle();
  }

  /**
   * toggle toggles button state from on to off or off to on.
   */
  void toggle() {
    // TODO: remove this debug code
    println("Panel: " + panel.id + ", Tab: " + tab.id + ", Button: " + col + ", " + row + " toggle called.");
    super.toggle();
    setValue(isOn ? ON : OFF, true);
  }

  /**
   * setValue turns the button on or off without sending a message
   * indicating the state change.  This is basically just a wrapper
   * that calls the two argument version of setValue with the
   * sendMessage argument set to false.  This method is intended to be
   * hooked up via osc.plug.
   *
   * However, we are not using plug at present because it performs
   * poorly.
   *
   * @param value one of the constants Button.ON or Button.OFF
   */
  void setValue(float value) {
    setValue(value, false);
  }

  /**
   * setValue turns this button on or off, and optionally sends a
   * message indicating the state change.
   *
   * @param value one of the constants Button.ON or Button.OFF
   * @param sendMessage if true, setValue will send out a message to
   * announce the state change
   */
  void setValue(float value, boolean sendMessage) {
    // TODO: remove this debug code
    println("Panel: " + panel.id + ", Tab: " + tab.id + ", Button: " + col + ", " + row + " set to " + value);
    println("setValue: getOscAddress returns: " + getOscAddress());
    OscMessage m = new OscMessage(getOscAddress());
    sqAlpha = (100 - sqAlphaDefault) * (int) value + sqAlphaDefault;

    if (value != OFF) {
      isOn = true;
      ((DrawableTab) tab).onButtons.put(getOscAddress(), this);
      // println(getOscAddress() + " on");
      m.add(ON);
    } else {
      isOn = false;
      ((DrawableTab) tab).onButtons.remove(getOscAddress());
      // println(getOscAddress() + " off");
      m.add(OFF);
    }

    if (sendMessage) {
      oscP5.send(m, myRemoteLocation);
    }
  }

  void activeButton() {
    //sqHue = sqHue+10;
    setActive = true;

  }

  void inactiveButton() {
    //sqHue = sqHue-10;
    setActive = false;
  }
}

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
  int sweepX, sweepY;
  int miniX, miniY, miniLength;
  int sqHue = 100;
  int sqBright = 100;
  int sqAlphaDefault = 20;
  int sqAlpha = sqAlphaDefault;

  boolean isSweep;
  int activeAlpha;

  boolean isDirty = false;
  
  DrawableButton(int _col, int _row, DrawableTab _tab, int _x, int _y, int _sqLength, int _miniX, int _miniY, int _miniLength) {
    super(_col, _row, _tab);
    // not needed with sync msg
    //oscP5.plug(this, "setValue", getOscAddress());

    x = _x;
    y = _y;
    sqLength = _sqLength;
    sweepX = x + (int)(sqLength * 0.05);
    sweepY = y + (int)(sqLength * 0.05);
    
    isSweep = false;
    activeAlpha = 0;

    miniX = _miniX;
    miniY = _miniY;
    miniLength = _miniLength;
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
    // Draw this button
    middle.disableStyle();
    noStroke();
    fill(getHue(), 50, sqBright, sqAlpha);
    shape(middle, x, y);

    if (isOn && isSweep) {
      //enabled button
      middleOnSweep.disableStyle();
      noStroke();
      fill(100, 50);
      shape(middleOnSweep, sweepX, sweepY);
    } else if (activeAlpha > 0) {
      //crosshairs
      middleOnSweep.disableStyle();
      noStroke();
      fill(100, activeAlpha);
      shape(middleOnSweep, sweepX, sweepY);
    }

    // Draw the outlines of the left sibling button
    DrawableButton leftSibling = (DrawableButton) getLeftSibling();
    if (leftSibling.isOn) {
      left.disableStyle();
      noStroke();
      fill(leftSibling.getHue(), 100, sqBright, leftSibling.sqAlpha);
      shape(left,x,y);
    }

    // Draw the outlines of the right sibling button
    DrawableButton rightSibling = (DrawableButton) getRightSibling();
    if(rightSibling.isOn){
      right.disableStyle();
      noStroke();
      fill(rightSibling.getHue(), 100, sqBright, rightSibling.sqAlpha);
      shape(right,x,y);
    }
  }

  /**
   * drawMiniTabButton draws a miniature representation of this button
   * at it's mini-tab coordinates.
   */
  void drawMiniTabButton() {
    noStroke();
//    fill(getHue(), 50, sqBright, sqAlpha);   //This was the original line that kept the minitabs on the wrong color
    fill(masterHue, 50, sqBright, sqAlpha);
    rect(miniX, miniY, miniLength, miniLength);
  }

  void press() {
    setValue(isOn ? OFF : ON, true);
    if (isOn) {
      new ButtonPressAnimation((DrawableTab) tab, this);
    }
  }

  /**
   * setValue turns the button on or off without sending a message indicating
   * the state change.  This is basically just a wrapper that calls the two
   * argument version of setValue with the sendMessage argument set to false.
   * This method was previously hooked up via osc.plug(), but now it is called
   * as a result of the /sync msg.
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
    /*
    println("Panel: " + panel.id + ", Tab: " + tab.id + ", Button: " + col + ", " + row + " set to " + value);
    println("setValue: getOscAddress returns: " + getOscAddress());
    */
    sqAlpha = (100 - sqAlphaDefault) * (int) value + sqAlphaDefault;

    if (value != OFF) {
      isOn = true;
      ((DrawableTab) tab).onButtons.put(getOscAddress(), this);
      // println(getOscAddress() + " on");
    } else {
      isOn = false;
      ((DrawableTab) tab).onButtons.remove(getOscAddress());
      // println(getOscAddress() + " off");
    }

    if (sendMessage) {
      OscMessage m = new OscMessage(getOscAddress());
      m.add(value);
      System.out.println("Sending OSC message " + m.addrPattern() + " to turn button " + isOn + " to " + myRemoteLocation);
      // mark as dirty until we get a sync message confirming receipt
      isDirty = true;
      oscP5.send(m, myRemoteLocation);
    }
  }

  /*
  void activeButton() {
    //sqHue = sqHue+10;
    setActive = true;

  }

  void inactiveButton() {
    //sqHue = sqHue-10;
    setActive = false;
  }
  */
}

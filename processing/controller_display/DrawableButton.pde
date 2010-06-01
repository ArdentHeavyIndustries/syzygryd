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
  
  /* SVG getter business */
  PShape left;
  PShape right;
  PShape middle;
  PShape fullButton;
  PShape fullButtonSweep, middleOnSweep;

  //DrawableButton(int _col, int _row, DrawableTab _tab, int _x, int _y, int _sqLength, int _miniX, int _miniY, int _miniLength, PShape _fullButton){
  DrawableButton(int _col, int _row, DrawableTab _tab, int _x, int _y, int _sqLength, int _miniX, int _miniY, int _miniLength, PShape _left, PShape _right, PShape _middle, PShape _middleOn) { 
    super(_col, _row, _tab);
    oscP5.plug(this, "setValue", getOscAddress());

    x = _x;
    y = _y;
    sqLength = _sqLength;
    //sweepX = (int) (x + ((sqLength * 0.1) / 2) + 2);
    //sweepY = (int) (y + ((sqLength * 0.1) / 2) + 2);
    sweepX = x + (int)(sqLength * 0.05);
    sweepY = y + (int)(sqLength * 0.05);
    
    isSweep = false;
    activeAlpha = 0;

    miniX = _miniX;
    miniY = _miniY;
    miniLength = _miniLength;

    left = _left;
    right = _right;
    middle = _middle;
    middleOnSweep = _middleOn;

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
    fill(getHue(), 50, sqBright, sqAlpha);
    rect(miniX, miniY, miniLength, miniLength);
  }

  //void press() {
  //  setValue(isOn ? OFF : ON, true);
  //  if (isOn) {
  //    new ButtonPressAnimation((DrawableTab) tab, this);
  //  }

  //  armClear = false;
  //}
  
void press() {
    setValue(isOn ? OFF : ON, true);
    if (isOn) {
        final DrawableTab t = (DrawableTab)tab;
        DrawableButton x;
        x = t.getButtonFromTabCoords(row - 1, col);
        if (x != null) x.animate0();
        x = t.getButtonFromTabCoords(row + 1, col);
        if (x != null) x.animate0();
        x = t.getButtonFromTabCoords(row, col - 1);        
        if (x != null) x.animate0();
        x = t.getButtonFromTabCoords(row, col + 1);        
        if (x != null) x.animate0();
    }
    armClear = false;
}
   
void animate() {
    if (activeAlpha > 0) {
        activeAlpha -= 3;
        if (activeAlpha == 0) ((DrawableTab)tab).activeCount--;
    }
}

void animate0() {
    if (activeAlpha == 0) ((DrawableTab)tab).activeCount++;
    activeAlpha = 36;    
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
    /*
    println("Panel: " + panel.id + ", Tab: " + tab.id + ", Button: " + col + ", " + row + " set to " + value);
    println("setValue: getOscAddress returns: " + getOscAddress());
    */
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

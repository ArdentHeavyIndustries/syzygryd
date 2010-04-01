/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Button
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
  return (x - buttonSpacing) / buttonSpacing;
}

class DrawableButton extends ToggleButton {
  int x,y, sqLength;
  int sqHue = 100;
  int sqBright = 100;
  int sqAlphaDefault = 30;
  int sqAlpha = sqAlphaDefault;

  boolean setActive;
  
  // for referring to the particle systems
//  ArrayList particleSystemsSimple;

  /* SVG getter business */
  PShape left;
  PShape right;
  PShape middle;
  PShape middleOn;
  PShape fullButton;
  PShape fullButtonActive, middleOnActive, middleActive, rightActive, leftActive;

  DrawableButton(int _row, int _col, DrawableTab _tab, /*ArrayList _particleSystems,*/ int _x, int _y, int _sqLength){
 //   particleSystemsSimple = _particleSystems;
    super(_row, _col, _tab);

    x=_x;
    y=_y;
    sqLength=_sqLength;

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

  void setHue(int _newHue){
    sqHue = _newHue;
  }

  void draw(boolean pressedOnly) {
    if(pressedOnly && !isOn) {
      return;
    }
    
    noStroke();
    int thisHue = sqHue + 33 * panel.id;
    // TODO: Instead of this if statement can we just take this mod 100?
    if (thisHue > 100) {
      thisHue -= 100;
    }

    int leftHue = sqHue + 33 * panel.getPrevPanel().id;
    // TODO: Instead of this if statement can we just take this mod 100?
    if (leftHue > 100) {
      leftHue -= 100;
    }

    int rightHue = sqHue + 33 * panel.getNextPanel().id;
    // TODO: Instead of this if statement can we just take this mod 100?
    if (rightHue > 100) {
      rightHue -= 100;
    }

    // Draw this panel's buttons
    middle.disableStyle();
    noStroke();
    fill(thisHue,50,sqBright,sqAlpha);
    shape(middle,x,y);

    // Draw the outlines of the left panel's buttons
    if (((DrawableButton) getLeftSibling()).isOn) {
      left.disableStyle();
      // Do we need these noStroke and fill calls?
      // Yes, we probably need the fill call, not sure about noStroke
      // as it is called above.
      noStroke();
      fill(leftHue,100,sqBright,sqAlpha);
      shape(left,x,y);
    }

    // Draw the outlines of the right panel's buttons
    if(((DrawableButton) getRightSibling()).isOn==true){
      right.disableStyle();
      // Do we need the noStroke and fill calls?
      // Yes, we probably need the fill call, not sure about noStroke
      // as it is called above.
      noStroke();
      fill(rightHue,100,sqBright,sqAlpha);
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
   * toggle toggles button state from on to off or off to on.
   */
  void toggle() {
    // TODO: remove this debug code
    // println("Panel: " + panel.id + ", Tab: " + tab.id + ", Button: " + row + ", " + col + " toggle called.");
    super.toggle();
    setValue(isOn ? ON : OFF, true);
  }

  void setValue(float _value, boolean sendMessage) {
    // TODO: remove this debug code
    // println("Panel: " + panel.id + ", Tab: " + tab.id + ", Button: " + row + ", " + col + " set to " + _value);
    OscMessage m = new OscMessage(getOscAddress());
    sqAlpha = (100 - sqAlphaDefault) * (int) _value + sqAlphaDefault;

    if (_value != OFF) {
      isOn = true;
      //particleSystemsSimple.add(new ParticleSystemSimple(100,new PVector(x+30,y+30)));
      // println(getOscAddress() + " on");
      m.add(ON);
    } else {
      isOn = false;
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

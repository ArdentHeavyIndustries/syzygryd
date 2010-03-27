/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

// NB: The following static methods ideally would be part of the
// Button class, but processing turns classes into inner classes so
// that's not possible.
// See: http://processing.org/reference/environment/index.html#Tabs
// for details.

/**
 * getRow returns the row a button is in
 * @param y   the y coordinate of the button's top left pixel
 * @param buttonSpacing   the size of the button plus a fudge factor
 *    for space between buttons
 * @return the row a button is in
 */
static int getRow(int y, int buttonSpacing) {
  return y / buttonSpacing;
}

/**
 * getCol returns the column a button is in
 * @param x   the x coordinate of the button's top left pixel
 * @param buttonSpacing   the size of the button plus a fudge factor
 *    for space between buttons
 * @return the column a button is in
 */
static int getCol(int x, int buttonSpacing) {
  return (x - buttonSpacing) / buttonSpacing;
}

class Button
{
  int x,y, sqLength;
  int buttonSpacing;
  int row, col;
  int sqHue = 100;
  int sqBright = 100;
  int sqAlphaDefault = 30;
  int sqAlpha = sqAlphaDefault;
  Panel parent; // Will eventually become a tab
  boolean setPressed;
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

  Button(/*ArrayList _particleSystems,*/ int _x, int _y, float _sqLength, int _buttonSpacing, Panel _parent){
 //   particleSystemsSimple = _particleSystems;
    x=_x;
    y=_y;
    sqLength=_sqLength;

    buttonSpacing = _buttonSpacing;
    row = getRow(y, buttonSpacing);
    col = getCol(x, buttonSpacing);

    parent = _parent;
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

  void draw(boolean pressedOnly){
    
    if(pressedOnly && !setPressed) {
      return;
    }
    
    noStroke();
    int thisHue = sqHue + 33 * parent.id;
    if(thisHue > 100) {
      thisHue -= 100;
    }

    switch(parent.id){
    case 0:
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
        }
        else {
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
  }

  void setValue( int _value) {
    OscMessage m = new OscMessage(getOscAddress());
    sqAlpha = (100 - sqAlphaDefault) * _value + sqAlphaDefault;

    if (_value==1) {
      setPressed = true;
      //particleSystemsSimple.add(new ParticleSystemSimple(100,new PVector(x+30,y+30)));
      // println(getOscAddress() + " on");
      m.add(1.0);
    } else {
      setPressed = false;
      // println(getOscAddress() + " off");
      m.add(0.0);
    }

    oscP5.send(m, myRemoteLocation);
  }

  boolean getValue() {
     return setPressed;
  }

  /**
   * getOscRow returns this button's row for use in an OSC address.
   * This handles the fact that OSC is indexed from 1 not 0, and has
   * an inverted y-axis vs. processing.
   */
  int getOscRow() {
    return (row * -1) + parent.height;
  }

  /**
   * getOscCol returns this button's column for use in an OSC
   * address.  This handles the fact that OSC is indexed from 1 not 0.
   */
  int getOscCol() {
    return col + 1;
  }

  String getOscAddress() {
    // Tab tab = xxxx;
    // Panel = tab.parent;
    Panel panel = parent;
    return "/" + panel.id + "/tab1/panel/" + getOscRow() + "/" + getOscCol();
  }

  /**
   * NB, we can probably delete the getX and getY functions.
   */
  int getX() {
     return x;
  }
  
  int getY() {
    return y;
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

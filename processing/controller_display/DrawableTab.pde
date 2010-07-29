/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawableTab
 */

/**
 * The DrawableTab class is a Tab that knows how to draw itself.
 */
class DrawableTab extends syzygryd.GridPatternTab implements Drawable {
  int buttonSize, buttonSpacing;
  DrawableMiniTab miniTab;
  DrawableClearButton clearButton;
  HashMap onButtons;

  int miniTabX, miniTabY;
  int miniTabWidth, miniTabHeight;
  
  float scaleFactor;
  
  int frameWeight = 2; // thickness of the frame 
  int arcOffset = 20; // how many pixels we need to allow for the arc when drawing the frame
  int buttonGap; // will use this in the frame calcs. Done this way in case buttonSpacing calc is changed later.
 
  // Frame Coords
  int topX1, topY1, topX2, topY2 ; //x1, y1 and x2 y2 for the top line
  int botX1, botY1, botX2, botY2; //x1, y1 and x2 y2 for the bottom line
  int leftX1, leftY1, leftX2, leftY2; //x1, y1 and x2 y2 for the left line  
  int rightX1, rightY1, rightX2, rightY2; //x1, y1 and x2 y2 for the right line  
  
  int miniTabOffset; //this is used to push the minitabs down from the top of the screen
  
  PShape left, right, middle, middleOnSweep;
  
  int activeCount = 0;

  DrawableTab(int _id, Panel _panel, int _gridWidth, int _gridHeight, int _buttonSize, int _buttonSpacing) {
    super(_id, _panel, _gridWidth, _gridHeight);
    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;
    buttonGap = buttonSpacing - buttonSize; // will use this in the frame calcs. Done this way in case buttonSpacing calc is changed later.
 
    // Coords for frame drawing
    // top line coords
    topX1 = int((0.5 * buttonGap) + arcOffset);
    topY1 = 0;
    topX2 = int(0.5 * buttonGap + (gridWidth * buttonSpacing) - arcOffset);
    topY2 = 0;
    // left line coords
    leftX1 = 0;
    leftY1 = int(0.5 * buttonGap + arcOffset);
    leftX2 = 0;
    leftY2 = int(0.5 * buttonGap + (gridHeight * buttonSpacing) - arcOffset);
    // bottom line coords
    botX1 = topX1;
    botY1 = frameWeight + buttonGap + (gridHeight * buttonSpacing); 
    botX2 = topX2;
    botY2 = botY1;
    // right line coords
    rightX1 = frameWeight + buttonGap + (gridWidth * buttonSpacing);
    rightY1 = leftY1;
    rightX2 = rightX1;
    rightY2 = leftY2;

    miniTabOffset = 40;

// The original Code

    miniTabX = (buttonSpacing * gridWidth) + (2 * (buttonSpacing - buttonSize));
    miniTabWidth = width - (miniTabX + (buttonSpacing - buttonSize));
    miniTabHeight = (int) ((miniTabWidth * height) / (float) width);
    miniTabY = (miniTabHeight * id) + ((buttonSpacing - buttonSize) * (id + 1)) + miniTabOffset; 
    int miniTabButtonSpacing = min(miniTabWidth / gridWidth, miniTabHeight / gridHeight) -1;  //try a -1 to fit better
    int miniTabButtonSize = miniTabButtonSpacing - 2;

    miniTab = new DrawableMiniTab(this, miniTabX, miniTabY, miniTabWidth, miniTabHeight, miniTabButtonSize, miniTabButtonSpacing);
//    clearButton = new DrawableClearButton(this, miniTabX, height - (miniTabHeight + (buttonSpacing - buttonSize)), miniTabWidth, miniTabHeight);  //original line
    clearButton = new DrawableClearButton(this, miniTabX, 10 * buttonSpacing - miniTabHeight- (buttonSpacing - buttonSize), miniTabWidth, miniTabHeight);  // modified line
   
    onButtons = new HashMap();

    for (int i = 0; i < gridWidth; i++) {
      for (int j = 0; j < gridHeight; j++) {
        DrawableButton b = new DrawableButton(
          i,
          j,
          this,
          buttonSpacing * (i + 1) - buttonSize + frameWeight, // button X   ----included frameWeight here to push offset to fit frame in
          (buttonSpacing * (j + 1)) - buttonSize + frameWeight, //button Y  ----included frameWeight here to push offset to fit frame in
          buttonSize, // button length
          (miniTab.buttonSpacing * (i + 1)) - miniTab.buttonSize + miniTab.originX,
          (miniTab.buttonSpacing * (j + 1)) - miniTab.buttonSize + miniTab.originY,
          miniTabButtonSize
        );

        buttons[i][j] = b;
      }
    }
// drawFrame();
  }

  /**
   * getButtonFromMouseCoords
   *
   * @return The button located at the specified mouse coordinates,
   * null if no button exists at the specified coordinates.
   */
  Pressable getButtonFromMouseCoords(int x, int y) {
    int row = getRow(y, buttonSpacing);
    int col = getCol(x, buttonSpacing);

    Pressable button = getButtonFromTabCoords(row, col);
    if (button != null) {
      return button;
    }

    if (x > miniTabX && x < miniTabX + miniTabWidth) {
      if (y < miniTabOffset) return null; // this is the area above the first tab

       // following equation derived from solving miniTabY eqn above for ID and including 2* buttonGap
      int tabIndex = (y - miniTabOffset + 2*(buttonGap)) / (miniTabHeight + 2*(buttonGap)); 
      
      if (tabIndex < panel.tabs.length) {
        return ((DrawableTab) panel.tabs[tabIndex]).miniTab;
      } else if (y > clearButton.y && y < (clearButton.y + clearButton.myHeight)) {
        return clearButton;
      }
    }

    return null;
  }

  /**
   * getButtonFromTabCoords
   *
   * @return The button at the specified row and column in this tab,
   * null if row or col are out of range.
   */
  DrawableButton getButtonFromTabCoords(int row, int col) {
    if (row < 0 || col < 0 || row >= gridHeight || col >= gridWidth) {
      return null;
    }

    return (DrawableButton) buttons[col][row];
  }

  /**
   * isSelected
   *
   * @return true if this tab is the currently selected tab on
   * its panel.
   */
  boolean isSelected() {
    return panel.selectedTab == this;
  }

  /**
   * clear clears the current pattern on this tab
   */
  void clear() {
    for (int i = 0; i < gridWidth; i++) {
      for (int j = 0; j < gridHeight; j++) {
        ((DrawableButton) buttons[i][j]).setValue(ToggleButton.OFF, false);
      }
    }
  }

  void draw() {
    // XXX are we just trying to see if 5 seconds have elapsed?  if so, couldn't we just check (second() - curSecond >= 5) ?
    if(second() % 5 == 0 && second() != curSecond) { //does changing the modulo here make color cycle faster or slower?
      masterHue++;
      if(masterHue > 100){
        masterHue -=100; 
      }
      curSecond = second();
    }

    drawFrame();
    miniTab.draw();
    
    for (int i = 0; i < gridWidth; i++) {
      for (int j = 0; j < gridHeight; j++) {
        ((DrawableButton) buttons[i][j]).setBaseHue(masterHue);
        if (isSelected()) {
          ((DrawableButton) buttons[i][j]).draw();
        }
      }
    }

    if (isSelected()) {
      clearButton.draw();
    }
  }

  void drawFrame() {
    stroke(0, 0, 99);  //white
    strokeWeight(frameWeight);
    strokeCap(ROUND);
    strokeJoin(ROUND);
    smooth();
    noFill();
//    rect(2, 2, buttonSpacing * 16 , buttonSpacing * 10); // this is old sq frame. replace with lines and arcs.
    
    line(topX1, topY1, topX2, topY2); // top line
    line(leftX1, leftY1, leftX2, leftY2); //left line
    line(botX1, botY1, botX2, botY2); // bottom line
    line(rightX1, rightY1, rightX2, rightY2); // right line
    
    //Now draw the arcs at the corners
    ellipseMode(RADIUS);
    arc(topX1, leftY1, topX1, leftY1, PI, TWO_PI-PI/2); // Upper Left Corner
    arc(topX1, leftY2 + frameWeight, topX1, leftY1, PI/2, PI); // lower left corner
    arc(topX2 + frameWeight, leftY1, topX1, leftY1, TWO_PI-PI/2, TWO_PI); // Upper Right Corner
    arc(topX2 + frameWeight, leftY2 + frameWeight, topX1, leftY1, 0, PI/2); // lower right corner
   
  }
}

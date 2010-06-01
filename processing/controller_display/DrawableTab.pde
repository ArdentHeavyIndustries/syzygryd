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
  
  PShape left, right, middle, middleOnSweep;

  DrawableTab(int _id, Panel _panel, int _gridWidth, int _gridHeight, int _buttonSize, int _buttonSpacing, PShape _left, PShape _right, PShape _middle, PShape _middleOn) {
    super(_id, _panel, _gridWidth, _gridHeight);
    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;

    miniTabX = (buttonSpacing * gridWidth) + (2 * (buttonSpacing - buttonSize));
    miniTabWidth = width - (miniTabX + (buttonSpacing - buttonSize));
    miniTabHeight = (int) ((miniTabWidth * height) / (float) width);
    miniTabY = (miniTabHeight * id) + ((buttonSpacing - buttonSize) * (id + 1));
    int miniTabButtonSpacing = min(miniTabWidth / gridWidth, miniTabHeight / gridHeight);
    int miniTabButtonSize = miniTabButtonSpacing - 2;

    miniTab = new DrawableMiniTab(this, miniTabX, miniTabY, miniTabWidth, miniTabHeight, miniTabButtonSize, miniTabButtonSpacing);
//    clearButton = new DrawableClearButton(this, miniTabX, height - (miniTabHeight + (buttonSpacing - buttonSize)), miniTabWidth, miniTabHeight);  //original line
    clearButton = new DrawableClearButton(this, miniTabX, 10 * buttonSpacing - miniTabHeight- (buttonSpacing - buttonSize), miniTabWidth, miniTabHeight);  // modified line
   
    onButtons = new HashMap();

    left = _left;
    right = _right;
    middle = _middle;
    middleOnSweep = _middleOn;

    for (int i = 0; i < gridWidth; i++) {
      for (int j = 0; j < gridHeight; j++) {
        DrawableButton b = new DrawableButton(
          i,
          j,
          this,
          buttonSpacing * (i + 1) - buttonSize, // button X
          (buttonSpacing * (j + 1)) - buttonSize, //button Y
          buttonSize, // button length
          (miniTab.buttonSpacing * (i + 1)) - miniTab.buttonSize + miniTab.originX,
          (miniTab.buttonSpacing * (j + 1)) - miniTab.buttonSize + miniTab.originY,
          miniTabButtonSize,
          left,
          right,
          middle,
          middleOnSweep
        );

        // Put button into hashmaps
        objectMapOSC.put (b.getOscAddress(), b);
        typeMapOSC.put (b.getOscAddress(), "button");

        buttons[i][j] = b;
      }
    }
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
      int tabIndex = y / miniTabHeight;
      if (tabIndex < panel.tabs.length) {
        // println("returning tabIndex: " + tabIndex);
        return ((DrawableTab) panel.tabs[tabIndex]).miniTab;
      } else if (y > clearButton.y) {
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
  Pressable getButtonFromTabCoords(int row, int col) {
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
    if(second() % 5 == 0 && second() != curSecond){ //does changing the modulo here make color cycle faster or slower?
      masterHue++;
      if(masterHue > 100){
        masterHue -=100; 
      }
      curSecond = second();
    }

    miniTab.draw();

    if (isSelected()) {
      for (int i = 0; i < gridWidth; i++) {
        for (int j = 0; j < gridHeight; j++) {
          ((DrawableButton) buttons[i][j]).setBaseHue(masterHue);
          ((DrawableButton) buttons[i][j]).draw();
        }
      }

      clearButton.draw();
    }
  }
}

/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawableTab
 */

/**
 * The DrawableTab class is a Tab that knows how to draw itself.
 */
class DrawableTab extends syzygryd.GridPatternTab implements Drawable {
  int buttonSize, buttonSpacing;
  MiniDrawableTab miniTab;
  HashMap onButtons;

  DrawableTab(int _id, Panel _panel, int _gridWidth, int _gridHeight, int _buttonSize, int _buttonSpacing) {
    super(_id, _panel, _gridWidth, _gridHeight);
    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;

    int miniTabX = buttonSpacing * gridWidth;
    int miniTabWidth = width - (miniTabX + (buttonSpacing - buttonSize));
    int miniTabHeight = (int) ((miniTabWidth * height) / (float) width);
    int miniTabY = (miniTabHeight * id) + ((buttonSpacing - buttonSize) * (id + 1));
    int miniTabButtonSpacing = min(miniTabWidth / gridWidth, miniTabHeight / gridHeight);
    int miniTabButtonSize = miniTabButtonSpacing - 2;

    miniTab = new MiniDrawableTab(this, miniTabX, miniTabY, miniTabWidth, miniTabHeight, miniTabButtonSize, miniTabButtonSpacing);

    onButtons = new HashMap();

    for (int i = 0; i < gridWidth; i++) {
      for (int j = 0; j < gridHeight; j++) {
        DrawableButton b = new DrawableButton(
 //         particleSystemsSimple,
          i,
          j,
          this,
          buttonSpacing * (i + 1) - buttonSize, // button X
          (buttonSpacing * (j + 1)) - buttonSize, //button Y
          buttonSize, // button length
          (miniTab.buttonSpacing * (i + 1)) - miniTab.buttonSize + miniTab.x,
          (miniTab.buttonSpacing * (j + 1)) - miniTab.buttonSize + miniTab.y,
          miniTabButtonSize
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
  Button getButtonFromMouseCoords(int x, int y) {
    int row = getRow(y, buttonSpacing);
    int col = getCol(x, buttonSpacing);

      println("mouseX: " + x + ", mouseY: " + y);
      println("row: " + row + ", col: " + col);

    return getButtonFromTabCoords(row, col);
  }

  /**
   * getButtonFromTabCoords
   *
   * @return The button at the specified row and column in this tab,
   * null if row or col are out of range.
   */
  Button getButtonFromTabCoords(int row, int col) {
    if (row < 0 || col < 0 || row >= gridHeight || col >= gridWidth) {
      return null;
    }

    return buttons[col][row];
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
    }
  }
}

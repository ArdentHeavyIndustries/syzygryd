/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Panel
 */

class Panel {
  int id;
  int width, height;
  int buttonSize, buttonSpacing;
  int buttonCount;
  Button[] buttons;
  Tab[] tabs;

  Panel(int _id, int _width, int _height, int _ntabs, int _buttonSize, int _buttonSpacing) {
    id = _id;
    width = _width;
    height = _height;
    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;
    buttonCount = 0;
    buttons = new Button[width * height];

    tabs = new Tab[_ntabs];
    for (int i = 0; i < tabs.length; i++) {
      tabs[i] = new Tab(i, this, _buttonSize, _buttonSpacing);
    }
  }

  /**
   * addButton adds a button to this panel
   */
  void addButton(Button b) {
    buttons[buttonCount] = b;
    buttonCount++;
  }

  /**
   * getButtonFromMouseCoords returns the button located at the
   * specified mouse coordinates.
   *
   * @return null if no button exists at the specified coordinates.
   */
  Button getButtonFromMouseCoords(int x, int y) {
    int row = getRow(y, buttonSpacing);
    int col = getCol(x, buttonSpacing);
    /*
    println("mouseX: " + x + ", mouseY: " + y);
    println("row: " + row + ", col: " + col);
    */

    return getButtonFromPanelCoords(row, col);
  }

  /**
   * getButtonFromPanelCoords returns the button at the specified
   * row and column in this panel.
   *
   * @return null if row or col are out of range.
   */
  Button getButtonFromPanelCoords(int row, int col) {
    if (row < 0 || col < 0 || row >= height || col >= width) {
      return null;
    }

    // println("Returning index: " + ((row * width) + col));
    // This is what we want if we create buttons one row at a time:
    // return buttons[(row * width) + col];
    // This is what we want if we create buttons one col at a time:
    // (this is the way things are currently implemented)
    return buttons[(col * height) + row];
  }
}


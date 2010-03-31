/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Tab
 */

class Tab {
  int id;
  Panel panel;
  int buttonSize, buttonSpacing;
  int buttonCount;
  Button[] buttons;

  Tab(int _id, Panel _panel, int _buttonSize, int _buttonSpacing) {
    id = _id;
    panel = _panel;

    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;
    buttons = new Button[panel.width * panel.height];
    buttonCount = 0;

    // As written this loop will create buttons one column at a time.
    // we may want to swap the inner and outer loops so we create one
    // row at a time.
    for (int i = 0; i < panel.width; i++) {
      for (int j = 0; j < panel.height; j++) {
        Button b = new Button(
 //         particleSystemsSimple,
          buttonSpacing * (i + 1), // button X
          (buttonSpacing * (j + 1)) - buttonSize, //button Y
          buttonSize, // button length
          this
        ); 

        // Put button into hashmaps
        // The key below should be the same as b.getOscAddress()
        // String key = "/" + panel.getOscId() + "/" + getOscId() + "/panel/" + (panel.height - j) + "/" + i; // e.g. /1/multitoggle1/1/1
        objectMapOSC.put (b.getOscAddress(), b);
        typeMapOSC.put (b.getOscAddress(), "button");

        buttons[buttonCount++] = b;
      }
    }
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

    return getButtonFromTabCoords(row, col);
  }

  /**
   * getButtonFromTabCoords returns the button at the specified
   * row and column in this panel.
   *
   * @return null if row or col are out of range.
   */
  Button getButtonFromTabCoords(int row, int col) {
    if (row < 0 || col < 0 || row >= height || col >= width) {
      return null;
    }

    // println("Returning index: " + ((row * width) + col));
    // This is what we want if we create buttons one row at a time:
    // return buttons[(row * width) + col];
    // This is what we want if we create buttons one col at a time:
    // (this is the way things are currently implemented)
    return buttons[(col * panel.height) + row];
  }

  String getOscId() {
    return "tab" + (id + 1);
  }

  void draw() {
    for (int i = 0; i < buttons.length; i++) {
      buttons[i].draw(false);
      buttons[i].setHue(masterHue);
    }

  if(second() % 5 == 0 && second() != curSecond){ //does changing the modulo here make color cycle faster or slower?
    masterHue+=1;
    if(masterHue > 100){
      masterHue -=100; 
    }
    curSecond = second();
  }


    for(int i = 0; i < buttons.length; i++){
      buttons[i].draw(true);
    }
  }
}

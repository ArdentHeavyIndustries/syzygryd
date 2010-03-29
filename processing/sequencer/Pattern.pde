/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
class Pattern implements ButtonManager {
  // width and height of the pattern, id numbers for the panel and tab
  int panelId, tabId, pWidth, pHeight;
  Panel parent;
  // the OSC object
  OscCommunicationsProvider oscProvider;
  // A grid of buttons that are controlled by / controlling this pattern
  Button[][] buttonGrid;
  // 2D array for the pattern data
  boolean[][] patternData;


  Pattern(int aPanelId, int aTabId, int aWidth, int aHeight, OscCommunicationsProvider anOscProvider) {
    panelId = aPanelId;
    tabId = aTabId;
    pWidth = aWidth;
    pHeight = aHeight;
    oscProvider = anOscProvider;
    patternData = new boolean[pWidth][pHeight];
    buttonGrid = new Button[pWidth][pHeight];
    // Initialize the patternData and the buttonGrid, initially all off
    for (int row = 0; row < pHeight; row++) {
      for (int column = 0; column < pWidth; column++) {
        Button newButton = new Button(column, row, this);
        buttonGrid[column][row] = newButton;
        // Plug the button's address into the OSC object so we get callbacks for button messages
        oscProvider.osc().plug(newButton, "setState", oscAddressForButton(newButton));
        patternData[column][row] = false;
      }
    }
  }


  int gridHeight() {
    return pHeight;
  }
  
  
  String oscAddressForButton(Button theButton) {
    return "/"+panelId+"_tab"+tabId+"/"+theButton.oscAddress();
  }


  void buttonStateUpdated(Button theButton, boolean newState) {
    setState(theButton.column, theButton.row, newState);
    OscMessage mirrorMessage = new OscMessage(this.oscAddressForButton(theButton));
    mirrorMessage.add(theButton.oscData());
    oscProvider.osc().send(mirrorMessage, oscProvider.clients());
    println("Panel "+panelId+", pattern "+tabId+" just updated button state from " + oscAddressForButton(theButton) + ": "+theButton.column+","+theButton.row+" = "+newState);
  }


  void setState(int column, int row, boolean state) {
    patternData[column][row] = state;
  }


  boolean state(int column, int row) {
    return buttonGrid[column][row].state;
  }


  float oscState(int column, int row) {
    return state(column, row) ? 1.0 : 0.0;
  }


  boolean[] getColumn(int column) {
    return patternData[column];
  }

  
  void send() {
    
  }
}


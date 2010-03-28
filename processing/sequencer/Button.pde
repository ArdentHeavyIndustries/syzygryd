interface ButtonManager {
  void buttonStateUpdated(Button theButton, boolean newState);
  int gridHeight();
}

class Button {
  int row, column;
  boolean state;
  ButtonManager manager;

  Button(int aColumn, int aRow, ButtonManager aManager) {
    manager = aManager;
    row = aRow;
    column = aColumn;
  }

  // This is the function that OSC will call if we get an updated state from a controller
  void setState(float theA) {
    // if the osc data is 0.0, that corresponds to the toggle being off; otherwise it's on
    state = (theA == 0.0) ? false : true; 
    manager.buttonStateUpdated(this, state);
  }
  
  // This version of the function allows us to programatically update the state of a button
  // NOTE: it does not inform the manager of its new status (with buttonStateUpdated) because 
  //       we presume that the manager is in fact the actor updating the status
  void setState(boolean newState) {
    state = newState;
  }

  float oscData() {
    // if the button is on, we send a 1.0; otherwise send a 0.0
    return state ? 1.0 : 0.0;
  }

  String oscAddress() {
    return "panel/"+ (row + 1) +"/"+(column + 1);
  }
}






class Button {
  int row, column;
  float state;
  Panel owner;
  
  Button(int _row, int _column, Panel _owner) {
    owner = _owner;
    row = _row;
    column = _column;
    state = 0;
  }
  
  public void setState(float theA) {
    //println("Hey, "+panel+"/"+row+"/"+column+" new state = "+theA);
    state = theA;
    owner.buttonStateUpdated(this, theA);
  }
  
  float getState() {
    return state;
  }
  
  int getRow() {
    return row;
  }
  
  int getColumn() {
    return column;
  }
  
  String oscAddress() {
    return "multitoggle1/"+(panelHeight - row)+"/"+(column + 1);
  }
  
  void addToBundle(OscBundle theBundle, OscMessage theMessage)
  {
    theMessage.clear();
    theMessage.setAddrPattern(owner.oscAddressForButton(this));
    theMessage.add(this.getState());
    theBundle.add(theMessage);
  }
  
  String to_s()
  {
    return ""+state;
  }
}


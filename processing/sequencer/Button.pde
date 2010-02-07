class Button {
  int row, column;
  //float state;
  Panel owner;
  
  Button(int _row, int _column, Panel _owner) {
    owner = _owner;
    row = _row;
    column = _column;
    //state = 0;
  }
  
  public void setState(float theA) {
    //println("Hey, "+panel+"/"+row+"/"+column+" new state = "+theA);
    //state = theA;
    owner.buttonStateUpdated(this, theA);
  }
  
  String oscAddress() {
    return "multitoggle1/"+(panelHeight - row)+"/"+(column + 1);
  }
  
}


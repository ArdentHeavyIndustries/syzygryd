import oscP5.*;
import netP5.*;
import themidibus.*;

class Panel {
  int pWidth, pHeight, id;
  OscP5 osc;
  MidiBus midiBus;
  NetAddressList clients;
  Button[][] buttonGrid;
  int[] toneMap;
  boolean initialized;

  Panel(int anId, int aWidth, int aHeight, OscP5 anOsc, MidiBus aMidiBus, NetAddressList someClients, int[] aToneMap) {
    initialized = false;
    toneMap = aToneMap;
    id = anId;
    pWidth = aWidth;
    pHeight = aHeight;
    osc = anOsc;
    midiBus = aMidiBus;
    clients = someClients;
    buttonGrid = new Button[pWidth][pHeight];
  }
  
  void setupOsc()
  {
    if (!initialized) {      
      for(int row = 0; row < panelHeight; row++){
        for (int column = 0; column < panelWidth; column++) {
          Button newButton = new Button(row, column, this);
          buttonGrid[column][row] = newButton;
          osc.plug(newButton, "setState", oscAddressForButton(newButton));
        }
      }
      osc.plug(this, "clear", "/4/clear"+id);
      osc.plug(this, "send", "/4/send"+id);
    }
    initialized = true;
  }
  
  String oscAddressForButton(Button theButton) {
    return "/"+id+"/"+theButton.oscAddress();
  }
  
  void buttonStateUpdated(Button theButton, float newState) {
    OscMessage mirrorMessage = new OscMessage(this.oscAddressForButton(theButton));
    mirrorMessage.add(newState);
    osc.send(mirrorMessage, clients);
  }
  
  int[] playNotesForBeat(int beat) {
    this.setupOsc();
    int[] notesPlayed = new int[pHeight];
    for (int i = 0; i < panelHeight; i++) {
      if (buttonGrid[beat][i].getState() != 0.0) {
        notesPlayed[i] = toneMap[i];
        midiBus.sendNoteOn(id - 1,toneMap[i],128);
      } else {
        notesPlayed[i] = 0;
      }
    }
    return notesPlayed;
  }
  
  void send(float theA)
  {
    this.setupOsc();
    OscMessage theMessage = new OscMessage("/foo");
    for (int row = 0; row < panelHeight; row++) {
      OscBundle theBundle = new OscBundle();
      for (int column = 0; column < panelWidth; column++) {
        buttonGrid[column][row].addToBundle(theBundle, theMessage);
      }
      oscP5.send(theBundle, clients);
    }
  }
  
  void clear(float theA)
  {
    this.setupOsc();
    for (int row = 0; row < panelHeight; row++) {
      for (int column = 0; column < panelWidth; column++) {
        buttonGrid[column][row].state = 0.0;
      }
    }  
    send(1.0);
  }
}



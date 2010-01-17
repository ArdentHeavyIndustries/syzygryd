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
    setupOsc();
  }
  
  void setupOsc()
  {
    if (!initialized) {      
      for(int row = 0; row < panelHeight; row++){
        for (int column = 0; column < panelWidth; column++) {
          Button newButton = new Button(row, column, this);
          buttonGrid[column][row] = newButton;
          // This is the magic connection between the multitoggle and the button. oscP5 will route the 
          // message to the appropriate button and call its setState method.
          osc.plug(newButton, "setState", oscAddressForButton(newButton));
        }
      }
      // And this is the magic connection between the panel's clear and send buttons (on page 4 of the TouchOSC 
      // interface). Works similar magic to above routing code for the buttons, but instead calls this panel's 
      // "clear" or "send" methods as appropriate
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
  
  /*
   * This guy sends the panel's current state to whatever controllers happen to be connected at the moment
   * (the argument doesn't do anything. Don't blame Moto, blame oscP5. it's not the best library ever written)
   */
  void send(float theA)
  {
    OscMessage theMessage = new OscMessage("/foo");
    for (int row = 0; row < panelHeight; row++) {
      OscBundle theBundle = new OscBundle();
      for (int column = 0; column < panelWidth; column++) {
        buttonGrid[column][row].addToBundle(theBundle, theMessage);
      }
      oscP5.send(theBundle, clients);
    }
  }
  
  /*
   * This guy clears all buttons and then sends the cleared field of buttons to whatever controllers happen 
   * to be connected at the moment
   * (the argument doesn't do anything. Don't blame Moto, blame oscP5. it's not the best library ever written)
   */
  void clear(float theA)
  {
    for (int row = 0; row < panelHeight; row++) {
      for (int column = 0; column < panelWidth; column++) {
        buttonGrid[column][row].state = 0.0;
      }
    }  
    send(1.0);
  }
}



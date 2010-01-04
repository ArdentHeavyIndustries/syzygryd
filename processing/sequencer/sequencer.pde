/**
 * Syzygryd sequencer
 */


import oscP5.*;
import netP5.*;
import themidibus.*;

MidiBus myBus;
OscP5 oscP5;

//This is a list of addresses of the controllers that have connected
NetAddressList myNetAddressList = new NetAddressList();

/* listeningPort is the port the server is listening for incoming messages */
int myListeningPort = 8000;
/* the broadcast port is the port the clients should listen for incoming messages from the server*/
int myBroadcastPort = 9000;

//Sets up the physical panels
int numPanels = 3;
int panelWidth = 16;
int panelHeight = 10;

int currentRow = 0;

//sets the main tempo
float bpm = 90.0;

MatrixButton [][][] buttonGrid;

//sets up the current available tones
// 60,62,64,67,69,72,74,76,79,81 is C major pentatonic scale, i believe
int[] toneMap = {
  60,62,64,67,69,72,74,76,79,81};


/** 
 * I think the point here is to get the connect/recieve messages 
 * into the osc parser, but yknow. maybe. It seems to see my page 
 * switches no matter what anyway, and nothing really seems to 
 * see buttons no matter what.
 */

String myConnectPattern = "/server/connect";
String myDisconnectPattern = "/server/disconnect";

void setup() {
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  // So this assumes you've set up the IAC Driver (on OS X, under /Apps/Utilities/Audio Midi Setup.app, 
  // click the "MIDI Devices" tab, double-click the "IAC Driver", add a port, and name it "GridSequencer")
  // Then in Live, on each of the three instruments, MIDI From should be "GridSequencer", and channel should be 1, 2, and 3 respectively
  myBus = new MidiBus(this, "GridSequencer", "GridSequencer");

  //start oscP5 listening for incoming messages from controllers.
  oscP5 = new OscP5(this, myListeningPort);
  
  //since we're hooking the draw() method as our loop routine, we want to update the frame an appropriate number of times per second.
  //if each of the 16 columns represented a quarter note in a 4/4 measure, we'd set framerate to (bpm/60) i.e. (beats / minute) / (seconds / minute)
  // but in fact it represents a 16th note, so we update four times as often. Hence the bpm/15 figure.
  frameRate(bpm / 15.0);
  
  //Sets up our layered grid as a bunch of MatrixButtons
  buttonGrid = new MatrixButton[numPanels][panelWidth][panelHeight];
  for (int panelNumber = 0; panelNumber < numPanels; panelNumber++) {
    for(int row = 0; row < panelHeight; row++){
      for (int column = 0; column < panelWidth; column++) {
        MatrixButton foo = new MatrixButton(panelNumber, row, column, toneMap[row], oscP5, myNetAddressList);
        buttonGrid[panelNumber][column][row] = foo;
        oscP5.plug(foo, "setState", foo.touchOSCAddress());
      }
    }
  }
  // upon receiving a specified OSC message, a named function can be called.
  oscP5.plug(this, "clearPanel1", "/4/clear1");
  oscP5.plug(this, "clearPanel2", "/4/clear2");
  oscP5.plug(this, "clearPanel3", "/4/clear3");
  oscP5.plug(this, "sendPanel1", "/4/send1");
  oscP5.plug(this, "sendPanel2", "/4/send2");
  oscP5.plug(this, "sendPanel3", "/4/send3");
}

void draw() {
  beat();
}

void broadcastPanel(int panelNumber)
{
  OscMessage theMessage = new OscMessage("/foo");
  for (int row = 0; row < panelHeight; row++) {
    OscBundle theBundle = new OscBundle();
    for (int column = 0; column < panelWidth; column++) {
      buttonGrid[panelNumber][column][row].addToBundle(theBundle, theMessage);
    }
    oscP5.send(theBundle, myNetAddressList);
  }
}

void clearPanel1(float theA)
{
  clearPanel(0);
}

void clearPanel2(float theA)
{
  clearPanel(1);
}

void clearPanel3(float theA)
{
  clearPanel(2);
}

void sendPanel1(float theA)
{
  broadcastPanel(0);
}

void sendPanel2(float theA)
{
  broadcastPanel(1);
}

void sendPanel3(float theA)
{
  broadcastPanel(2);
}

void clearPanel(int panelNumber)
{
  for (int row = 0; row < panelHeight; row++) {
    for (int column = 0; column < panelWidth; column++) {
      buttonGrid[panelNumber][column][row].setState(0);
    }
  }  
  broadcastPanel(panelNumber);
}

void updatePanelSlider() {
  OscBundle myBundle = new OscBundle();
  OscMessage fader = new OscMessage("/1/fader1");
  float pos = ((float)currentRow) / 15.0;
  for (int panel = 0; panel < numPanels; panel++) {
    fader.setAddrPattern("/"+(panel+1)+"/fader1");
    fader.add(pos);
    myBundle.add(fader);
  }
  OscMessage temposlider = new OscMessage("/temposlider/step");
  temposlider.add(currentRow+1);
  myBundle.add(temposlider);
  oscP5.send(myBundle, myNetAddressList);    
}

void playPanelNotes() {
  int [][] notesToKill = new int [3][panelHeight];
  for (int panel = 0; panel < numPanels; panel++) {    
    MatrixButton[] row = buttonGrid[panel][currentRow];
    for (int i = 0; i < panelHeight; i++) {
      if (row[i].getState() != 0.0) {
        notesToKill[panel][i] = 1;
        myBus.sendNoteOn(panel,row[i].note,128);
      } 
      else {
        notesToKill[panel][i] = 0;
      }
    }
  }
  delay(200);
  for (int panel = 0; panel < numPanels; panel++) {    
    MatrixButton[] row = buttonGrid[panel][currentRow];
    for (int i = 0; i < panelHeight; i++) {
      if (notesToKill[panel][i] != 0) {
        myBus.sendNoteOff(panel,row[i].note,128);
      }
    }
  }
}

void beat() {
  updatePanelSlider();
  playPanelNotes();
  if (++currentRow >=panelWidth) {
    currentRow = 0;
  }
}

void oscEvent(OscMessage theOscMessage) {
  /* check if the address pattern fits any of our patterns */
  if (theOscMessage.addrPattern().equals(myConnectPattern)) {
    connect(theOscMessage.netAddress().address(), true);
  }
  else if (theOscMessage.addrPattern().equals(myDisconnectPattern)) {
    disconnect(theOscMessage.netAddress().address());
  } else {
    // Just in case we're hearing for the first time from a non-connected client, we'll implicitly connect them now
    // (this will not send a refresh of panel state, but will ensure the tempo sliders update)
    connect(theOscMessage.netAddress().address(), false);
  }
}


private void connect(String theIPaddress, Boolean explicit) {
  if (!myNetAddressList.contains(theIPaddress, myBroadcastPort)) {
    myNetAddressList.add(new NetAddress(theIPaddress, myBroadcastPort));
    println("### adding "+theIPaddress+" to the list.");
    if (explicit) { // (implicit connections will not trigger broadcast)
      /* Since we've got a newly connected client, let's get them up to date with what's already in the matrix */
      for (int i = 0; i < 3; i++) {
        broadcastPanel(i);
      }
    }
  } 
}



private void disconnect(String theIPaddress) {
  if (myNetAddressList.contains(theIPaddress, myBroadcastPort)) {
    myNetAddressList.remove(theIPaddress, myBroadcastPort);
    println("### disconnecting controller at "+theIPaddress);
  } 
  else {
    println("### controller from "+theIPaddress+" was not connected.");
  }
  println("### currently there are "+myNetAddressList.list().size()+" controllers connected");
}







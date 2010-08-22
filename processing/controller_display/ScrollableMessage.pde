/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
// implements the scrolling message at the bottom of the panel
class ScrollableMessage {
  
  String[] message;       //array to hold the scrollable messages
  String setAttribution = "We Are SYZYGRYD!!";
  String spacing = "          ";
  float[] messageWidth;   // array to hold the length(in pixels) of each of the above messages. Length is dependent on font used.  
  int messageSelect = 0;  // tracks which message is currently displayed
  float messageXPos;      // tracks the x-position of the current message as it scrolls
  int msgPtr[];   // array to store randomized pointers to the messages. This array gets re-sorted after it has been traversed once. 
  
  ScrollableMessage () {
    messageXPos = width + 15; // initializes with a push off to the right of the screen edge
    
    // load the font for the scrolling message at the bottom of the display
    // msgFont is a Global
    msgFont = createFont("DejaVuSans-25.vlw",25);
    textFont(msgFont);
    
    //load the message array and calc the companion array providing the pixel width of each message
    message = loadStrings("messages.txt");
    messageWidth = new float[message.length];
    msgPtr = new int[message.length];
    for (int i=0; i < message.length; i++) {
      messageWidth[i] = textWidth(message[i]);
      msgPtr[i] = i; //init the msgPtr array...gets randomized below
    }    
    randomizeMessages(); // randominze the msgPtr array
  }  // end constructor
  
  void msgDraw(){
    textFont(msgFont);
    // XXX bug:84 - this isn't working right yet, so for now undo part of svn r573 and revert to white
//     DrawableTab t = (DrawableTab) panels[0].tabs[0];
//     DrawableButton b = t.getButtonFromTabCoords(0, 0);
//     fill(b.getHue(), 50, 40, 40);  //draw message same color as current buttons on tab, constant brightness and alpha
    fill(0,0,99);  // white 
    textAlign(LEFT);
    text(message[msgPtr[messageSelect]], messageXPos, height - 8);
    messageXPos -= 1.8;    
    if (messageXPos < (0 - messageWidth[messageSelect])) {
      messageSelect++;
      if (messageSelect > message.length -1) { 
        //we've got to the end of the array, re-randomize and start over
        randomizeMessages();
        messageSelect = 0;
      }
      messageXPos = width + 15; 
    }
  }  // end msgDraw()
  
  void randomizeMessages() {
    // implement the Durstenfeld algorithm to randomize an array
    for (int i = msgPtr.length; i > 1; i--) {
      int j = int(random(i)); //for zero-based array
      int tmp = msgPtr[j];
      msgPtr[j] = msgPtr[i-1];
      msgPtr[i-1] = tmp;
    } 
  }// end randomizeMessages
}// End ScrollableMessage Class


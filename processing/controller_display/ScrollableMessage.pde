// implements the scrolling message at the bottom of the panel
class ScrollableMessage {
  
  String[] message;       //array to hold the scrollable messages
  float[] messageWidth;   // array to hold the length(in pixels) of each of the above messages. Length is dependent on font used.  
  int messageSelect = 0;  // tracks which message is currently displayed
  float messageXPos;      // tracks the x-position of the current message as it scrolls
  
  ScrollableMessage () {
    messageXPos = width + 15; // initializes with a push off to the right of the screen edge
    
    // load the font for the scrolling message at the bottom of the display
    // msgFont is a Global
    msgFont = createFont("Andale Mono",25);
    textFont(msgFont);
    
    //load the message array and calc the companion array providing the pixel width of each message
    message = loadStrings("messages.txt");
    messageWidth = new float[message.length];
    for (int i=0; i < message.length; i++) {
      messageWidth[i] = textWidth(message[i]);
    }    
  }  // end constructor
  
    void msgDraw(){
      textFont(msgFont);
      fill(0,0,99);  //white
      textAlign(LEFT);
      text(message[messageSelect], messageXPos, height);
      messageXPos -= 1.8;    
      if (messageXPos < (0 - messageWidth[messageSelect])) {
       messageSelect ++;
       messageXPos = width + 25; 
      }
      if (messageSelect > (message.length - 1))   {
        messageSelect = 0;
      }
    }  // end msgDraw()
  }// End ScrollableMessage Class


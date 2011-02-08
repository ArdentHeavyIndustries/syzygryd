/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * DrawableMiniTab
 */

/**
 * DrawableMiniTab class is a miniature representation of a Tab.
 */
class DrawableMiniTab implements Drawable, Pressable {
  DrawableTab tab;
  int x, y;
  int myWidth, myHeight;
  int originX, originY;
  int buttonSize, buttonSpacing;
  int frameCount;
  color lastFill, lastStroke;
  color BLACK = color(0);
  color RED = color(0, 100, 100);
  color ARMED = color(359, 74, 93);
  color GREY = color(50);
  color WHITE = color(0, 0, 100);
  float opacity = 0.0;
  int direction = 1;
  int arcOffset = 10; // how many pixels we need to allow for the arc when drawing the frame
  int buttonGap;
  int frameWeight = 1;
  int frameOffset = 3;
  
  // Frame Coords
  int topX1, topY1, topX2, topY2 ; //x1, y1 and x2 y2 for the top line
  int botX1, botY1, botX2, botY2; //x1, y1 and x2 y2 for the bottom line
  int leftX1, leftY1, leftX2, leftY2; //x1, y1 and x2 y2 for the left line  
  int rightX1, rightY1, rightX2, rightY2; //x1, y1 and x2 y2 for the right line  

  DrawableMiniTab(DrawableTab _tab, int _x, int _y, int _width, int _height, int _buttonSize, int _buttonSpacing) {
    tab = _tab;
    x = _x;
    y = _y;

    myWidth = _width;
    myHeight = _height;

    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;

    originX = ((myWidth - (buttonSpacing * tab.gridWidth)) / 2) + x;
    originY = ((myHeight - (buttonSpacing * tab.gridHeight)) / 2) + y;  
 
// output.println("x,y, myWidth, myHeight, originX, originY: " + x +" "+ y +" "+ myWidth +" "+ myHeight +" "+ originX +" "+ originY); 
 
    frameCount = 0;

    lastFill = BLACK;
    lastStroke = RED;
    
    buttonGap = buttonSpacing - buttonSize; // will use this in the frame calcs. Done this way in case buttonSpacing calc is changed later.
 
    // Coords for frame drawing
    // top line coords
    topX1 = x + arcOffset;
    topY1 = y;
    topX2 = topX1 + myWidth - 2*arcOffset;
    topY2 = y;
    // left line coords
    leftX1 = x + frameOffset;
    leftY1 = y + arcOffset;
    leftX2 = x + frameOffset;
    leftY2 = y + arcOffset + myHeight - 2*arcOffset;
    // bottom line coords
    botX1 = topX1;
    botY1 = y + myHeight; 
    botX2 = topX2;
    botY2 = y + myHeight;
    // right line coords
    rightX1 = x + myWidth;
    rightY1 = leftY1;
    rightX2 = rightX1;
    rightY2 = leftY2;
    
  }

  void draw() {
//    boolean toggleFill = frameCount % 15 == 0;
//    frameCount++;

    drawMiniTabFrame();

//     for (Iterator i = tab.onButtons.values().iterator(); i.hasNext(); ) {
//       try {
//         ((DrawableButton) i.next()).drawMiniTabButton();
//       } catch (ConcurrentModificationException e) {
//         // Do nothing, we'll redraw on the next cycle
//       }
//     }

    for (int j = 0; j < 10; j++) {
      for (int k = 0; k < 16; k++) {
        DrawableButton myButton = (DrawableButton) tab.buttons[k][j];
        myButton.drawMiniTabButton();
      }
    }
  }  // end draw()

  String getClearOscAddress() {
    return "/" + tab.panel.getOscId() + "_control/clear/" + tab.getOscId();
  }

  void press() {
    //debug("Mini tab " + tab.id + " pressed and selected");
    ((DrawablePanel) tab.panel).selectTab(tab.id, true);
  }
  
  void drawMiniTabFrame() {
    if (tab.isSelected()) {
      lastStroke = WHITE;
    } else {
      lastStroke = RED;
    }

    fill(lastFill, opacity);
    stroke(lastStroke);

    if(tab.isSelected()) {
      strokeWeight(tab.frameWeight); // doesn't work right
      strokeWeight(3);  //hack - need to parameterize
      line(topX1, topY1, topX2, topY2); // top line
      //black out the left line of the selected minitab
      stroke(BLACK);
      line(leftX1 - frameOffset - 2, leftY1 - arcOffset - 5, leftX2 - frameOffset- 2, leftY2 + arcOffset + 5); //left line  //need to param the fine tuners
      stroke(lastStroke);
      line(botX1, botY1, botX2, botY2); // bottom line
      line(rightX1, rightY1, rightX2, rightY2); // right line
      
      //Now draw the arcs at the corners
      ellipseMode(RADIUS);
      //arc(x, y, width, height, start, stop) 
      arc(topX1 - 2, leftY1 - 2*arcOffset, arcOffset, arcOffset, PI/2, PI); // Upper Left Corner  //hack - need to parameterize the x - coord
      arc(topX1 -2, leftY2 + 2*arcOffset, arcOffset, arcOffset, PI, TWO_PI-PI/2); // lower left corner //hack - need to parameterize the x - coord
      arc(topX2 , leftY1, arcOffset, arcOffset, TWO_PI-PI/2, TWO_PI); // Upper Right Corner
      arc(topX2 , leftY2 , arcOffset, arcOffset, 0, PI/2); // lower right corner
    }
    else {
//      stroke(frameWeight);  //fucks it up
      line(topX1, topY1, topX2, topY2); // top line
      line(leftX1, leftY1, leftX2, leftY2); //left line
      line(botX1, botY1, botX2, botY2); // bottom line
      line(rightX1, rightY1, rightX2, rightY2); // right line
      
      //Now draw the arcs at the corners
      ellipseMode(RADIUS);
      //arc(x, y, width, height, start, stop) 
      arc(topX1 + frameOffset, leftY1, arcOffset, arcOffset, PI, TWO_PI-PI/2); // Upper Left Corner
      arc(topX1 + frameOffset, leftY2, arcOffset, arcOffset, PI/2, PI); // lower left corner
      arc(topX2 , leftY1, arcOffset, arcOffset, TWO_PI-PI/2, TWO_PI); // Upper Right Corner
      arc(topX2 , leftY2 , arcOffset, arcOffset, 0, PI/2); // lower right corner
    }
  }  //end drawMiniTabFrame();
}

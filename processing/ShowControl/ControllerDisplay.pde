
/* simple DMX visualization - displays grid of controller channels, values represented as grayscale levels */

public void displayControllers(int _cellSize){
  int ctrlrCount = DMXManager.controllers.size();
  int univSize = 0, winHeight = 0, winWidth = 0;
  DMX.Controller controller = null;
  
  ctrlrWindow = new GWindow[ctrlrCount];
  for (int i = 0; i < ctrlrCount; i++) {
    controller = (DMX.Controller)DMXManager.controllers.get(i);
    univSize = controller.universeSize;

    winHeight = (ceil((float)univSize/32) * _cellSize) + 1;
    winWidth = 32 * _cellSize + 1;

    ctrlrWindow[i] = new GWindow(this, "DMX Controller "+i, 100+60*i, 100+60*i,winWidth,winHeight,false, JAVA2D);
    ctrlrWindow[i].setResizable(true);
    ctrlrWindow[i].setOnTop(false);
    
    ctrlrWindow[i].addData(new ctrlrWinData(ctrlrWindow[i].papplet));
    ((ctrlrWinData)ctrlrWindow[i].data).controller = controller;
    ((ctrlrWinData)ctrlrWindow[i].data).univSize = univSize;
    ((ctrlrWinData)ctrlrWindow[i].data).cellSize = _cellSize;
    
    ctrlrWindow[i].addDrawHandler(this, "drawChannelGrid");
  }
}

public void displayControllers(){
  displayControllers(24);
}

void drawChannelGrid(GWinApplet appc, GWinData _data){
  int index = 0, val = 0;
  boolean updated = false;
  ctrlrWinData data = (ctrlrWinData)_data;
  appc.colorMode(RGB);
  appc.textFont(appc.createFont("arial", floor(data.cellSize/2.25)));
  appc.background(data.windowBuffer);
   for (int row = 0; row <= ceil(data.univSize / 32); row++){
    for (int col = 0; (col < 32) && (row * 32 + col < data.univSize); col++){
      index = row * 32 + col;
      val = data.controller.getChannelUnsigned(index);
      if (val != data.valCache[index]) {
        updated = true;
        appc.fill(val,0,0);
        appc.stroke(#ffffff);
        appc.rect((col*data.cellSize),(row*data.cellSize),data.cellSize,data.cellSize);
        appc.fill(#ffffff);
        appc.stroke(#ffffff);
        appc.textAlign(CENTER,CENTER);
        appc.text(appc.str(row*32+col), (col*data.cellSize),(row*data.cellSize),data.cellSize,data.cellSize);
        data.valCache[index] = val;
      }
    }
  }
  if (updated){
    data.windowBuffer = appc.get();
  }
}



class ctrlrWinData extends GWinData {
  DMX.Controller controller;
  int univSize;
  int cellSize;
  int[] valCache;
  PImage windowBuffer;
  
  ctrlrWinData(PApplet appc){
    valCache = new int[512];
    for (int i = 0; i < 512; i++){
      valCache[i] = -1;
    }
    windowBuffer = createImage(appc.width, appc.height, RGB);
    windowBuffer = appc.get();
  }
}

public void handleButtonEvents(GButton button){
  if(button.eventType == GButton.CLICKED){
    if (ctrlrWindow == null) {
      displayControllers();
    }
    else {
      
    }
  }
}

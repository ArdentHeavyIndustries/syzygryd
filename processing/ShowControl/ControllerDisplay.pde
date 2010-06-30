
/* simple DMX visualization - displays grid of controller channels, values represented as grayscale levels */

public void displayControllers(int _cellSize){
  int ctrlrCount = DMXManager.controllers.size();
  int univSize = 0, winHeight = 0, winWidth = 0;
  DMX.Controller controller = null;
  
  GWindow[] ctrlrWindow = new GWindow[ctrlrCount];
  for (int i = 0; i < ctrlrCount; i++) {
    controller = (DMX.Controller)DMXManager.controllers.get(i);
    univSize = controller.universeSize;

    winHeight = (floor(univSize/32) * _cellSize) - 9;
    winWidth = 32 * _cellSize - 9;

    ctrlrWindow[i] = new GWindow(this, "DMX Controller "+i, 100+60*i, 100+60*i,winWidth,winHeight,false, JAVA2D);
    ctrlrWindow[i].setResizable(false);
    
    ctrlrWindow[i].addData(new ctrlrData());
    ((ctrlrData)ctrlrWindow[i].data).controller = controller;
    ((ctrlrData)ctrlrWindow[i].data).univSize = univSize;
    ((ctrlrData)ctrlrWindow[i].data).cellSize = _cellSize;
    
    ctrlrWindow[i].addDrawHandler(this, "drawChannelGrid");
  }
}

void drawChannelGrid(GWinApplet appc, GWinData _data){
  ctrlrData data = (ctrlrData)_data;
  appc.colorMode(RGB);
  appc.textFont(appc.createFont("arial", floor(data.cellSize/2.25)));
     for (int row = 0; row <= ceil(data.univSize / 32); row++){
      for (int col = 0; (col < 32) && (row * 32 + col < data.univSize); col++){
        int val = data.controller.getChannelUnsigned(row * 32 + col);
        appc.fill(val, 0, 0);
        appc.stroke(255);
        appc.rect((col*data.cellSize),(row*data.cellSize),data.cellSize,data.cellSize);
        appc.fill(#ffffff);
        appc.stroke(#000000);
        appc.textAlign(CENTER,CENTER);
        appc.text(appc.str(row*32+col), (col*data.cellSize),(row*data.cellSize),data.cellSize,data.cellSize);
      }
  }
}



public class ctrlrData extends GWinData {
  DMX.Controller controller;
  int univSize;
  int cellSize;
}

/* Derived from codeanticode.prodmx library by Andres Colubri */

class DMX {
  ArrayList controllers = new ArrayList();

  DMX(PApplet _processingObject, int _refreshRate){
    processingObject = _processingObject;
    refreshRate = _refreshRate;
    
    // calculate timer interval (in ms) from refresh rate (in Hz)
    long refreshInterval = round(1000 / refreshRate);
    
    //instantiate timer and task
    boolean bgMode = true;
    Timer refresh = new Timer(bgMode);
    RefreshTask update = new RefreshTask();
    
    // begin refresh cycle
    refresh.schedule(update, 0, refreshInterval);
  }

  void addController(String port, int rate, int universeSize){
    controllers.add(new Controller(port, rate, universeSize));
  }
  
  void addController(String port, int universeSize){
    controllers.add(new Controller(port, 115200, universeSize));
  }
 
  void addController(String port){
    controllers.add(new Controller(port, 115200, 512));
  }

  byte getChannel(int controller, int address){
    Controller ctrlr = (Controller)controllers.get(controller);
    return ctrlr.getChannel(address);
  }

  int getChannelUnsigned(int controller, int address){
    Controller ctrlr = (Controller)controllers.get(controller);
    return ctrlr.getChannelUnsigned(address);
  }

  void setChannel(int controller, int address, byte value){
    Controller ctrlr = (Controller)controllers.get(controller);
    ctrlr.setChannel(address, (byte)value);
  }

  int alloc(Fixture.Channel channel, int controller){
    Controller ctrlr = (Controller)controllers.get(controller);
    return ctrlr.alloc(channel);
  }
   
  int alloc(Fixture.Channel channel, int controller, int address){
    Controller ctrlr = (Controller)controllers.get(controller);
    return ctrlr.alloc(channel, address);
  }
 
  class RefreshTask extends java.util.TimerTask {
     void run() {
       Controller ctrlr = null;
      for (int i = 0; i < controllers.size(); i++){
        ctrlr = (Controller)controllers.get(i);
        if(ctrlr != null) {
            ctrlr.sendFrame();
        }
      }
    }
  }
  
  class Controller {
    private int universeSize = 0;
    private PApplet parent = null;
    private Serial serialInterface = null;
    private byte[] frame;
    private Fixture.Channel[] allocMap;
  
    Controller(String port, int rate, int _universeSize) {
      int dataSize = 0;
      parent = processingObject;
      serialInterface = new Serial(parent, port, rate);
      universeSize = _universeSize;
      dataSize = universeSize + 1;    
      
      //create allocation map
      allocMap = new Fixture.Channel[universeSize];      
      
      //create frame buffer
      frame = new byte[universeSize + 6];
      
      // set up frame header
      frame[0] = DMX_FRAME_START;
      frame[1] = DMX_SEND_PACKET;
      frame[2] = (byte)(dataSize & 255);
      frame[3] = (byte)((dataSize >> 8) & 255);
      frame[4] = 0;
      
      // initialize all channels to zero
      for (int i = 5; i <= universeSize + 4; i++) {
        frame[i] = 0;
      }
      
      // close frame
      frame[universeSize + 5] = DMX_FRAME_END;      
    }
    
    int universeSize(){
      return universeSize;
    }
    
    int alloc(Fixture.Channel channel){
      for (int addr = 0; addr < universeSize; addr++) {
        if (!(allocMap[addr] instanceof Fixture.Channel)) {
          allocMap[addr] = channel;
          return addr;
        }
      }
      return -1;
    }
   
    int alloc(Fixture.Channel channel, int address){
      if (!(allocMap[address] instanceof Fixture.Channel)) {
        allocMap[address] = channel;
        return address;
      } else {
        return -1;
      }
    }
  
    byte getChannel(int address){
      return frame[address + 5];
    }
    
    int getChannelUnsigned(int address){
     return (int)((int)frame[address+5] & 0xFF);
    }
      
  
    void setChannel(int address, byte value){
      frame[address + 5] = value;
    }
  
    void sendFrame(){
      //Could use some error checking to ensure port is successfully initialized before sending
        //serialInterface.write(frame);
    }     
  
    // DMX Control Codes 
    private byte DMX_FRAME_START = (byte)(0x7E);
    private byte DMX_FRAME_END = (byte)(0xE7);
    private byte DMX_SEND_PACKET = (byte)(6);
  }

  // Refresh rate in Hz
  private int refreshRate;

  // Required to set up the serial ports(s)
  private PApplet processingObject;
}



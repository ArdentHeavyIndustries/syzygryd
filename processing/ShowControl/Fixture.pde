class Fixture {
  String type = null;
  HashMap traits;
  HashMap channels;
  DMX dmx;
  
  Fixture(DMX _dmx, String _type){
    dmx = _dmx;
    type = _type;
  }

  class Channel {
    private int controller = -1;
    private int address = -1;
    private float latency = 0;
    
    Channel(int _controller){
      controller = _controller;
      address = dmx.alloc(controller);
    }
    
    Channel(int _controller, int _address){
      controller = _controller;
      address = dmx.alloc(controller, _address);
    }
    
    byte getValue(){
      byte value = 0;
      if (controller >= 0 && address >= 0){
        value = dmx.getChannel(controller, address);
      }
      return value;
    }
    
    void setValue(byte value){
      if (controller >= 0 && address >= 0){
        dmx.setChannel(controller, address, value);
      }
    }
  }  

}

class Fixture {
  
  DMX dmx;
  int controller;
  
  String type = null;
  HashMap traits = new HashMap();
  HashMap channels = new HashMap();
  
  Behavior behavior;
  ArrayList commandQueue = new ArrayList();
  
  Fixture(DMX _dmx, int _controller, String _type){
    dmx = _dmx;
    controller = _controller;
    type = _type;
  }
  
  int addChannel(String channelName){
    channels.put(channelName, new Channel(this, controller));
    return (int)((Channel)channels.get(channelName)).getAddress();
  }

  int addChannel(String channelName, int address){
    channels.put(channelName, new Channel(this, controller, address));
    return (int)((Channel)channels.get(channelName)).getAddress();
  }
  
  void setChannel(String channelName, int value){
    ((Channel)channels.get(channelName)).setValue((byte)value);
  }

  class Channel {
    private Fixture parent;
    private int controller = -1;
    private int address = -1;
    private float latency = 0;
    
    Channel(Fixture _parent, int _controller){
      parent = _parent;
      controller = _controller;
      address = dmx.alloc(this, controller);
    }
    
    Channel(Fixture _parent, int _controller, int _address){
      parent = _parent;
      controller = _controller;
      address = dmx.alloc(this, controller, _address);
    }
    
    int getValue(){
      int value = 0;
      if (controller >= 0 && address >= 0){
        value = dmx.getChannelUnsigned(controller, address);
      }
      
      return value;
    }
    
    void setValue(byte value){
      if (controller >= 0 && address >= 0){
        dmx.setChannel(controller, address, value);
      }
    }
    
    int getAddress(){
      return address;
    }
  }  

}

abstract class Behavior {}
abstract class Command {}

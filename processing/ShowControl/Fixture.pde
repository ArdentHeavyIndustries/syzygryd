class Fixture {
  
  DMX dmx;
  int controller;
  
  String type = null;
  HashMap traits = new HashMap();
  HashMap channels = new HashMap();
  
  FixtureProfile profile;
  
  ArrayList commandQueue = new ArrayList();
  
  Fixture(DMX _dmx, int _controller, String _type){
    dmx = _dmx;
    controller = _controller;
    type = _type;
    //FIXME: add fixture factory setup here
  }
  
  int addChannel(String channelName){
    channels.put(channelName, new Channel(this, controller));
    return (int)((Channel)channels.get(channelName)).getAddress();
  }

  int addChannel(String channelName, int address){
    channels.put(channelName, new Channel(this, controller, address));
    return (int)((Channel)channels.get(channelName)).getAddress();
  }
  
  int addChannel(String channelName, int address, float latency){
    channels.put(channelName, new Channel(this, controller, address, latency));
    return (int)((Channel)channels.get(channelName)).getAddress();
  }
  
  void setChannel(String channelName, int value){
    ((Channel)channels.get(channelName)).setValue((byte)value);
  }

  int getChannel(String channelName){
    return ((Channel)channels.get(channelName)).getValue();
  }

  void addTrait(String traitName, Trait traitDef){
    traits.put(traitName, traitDef);
  }
  
  Trait trait(String traitName){
    return (Trait)(traits.get(traitName));
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
      try {
        address = dmx.alloc(this, controller, _address);
      }
      catch (AddressAllocationException e) {
        System.err.println("Channel allocation on controller " + controller + ", address " + _address + " failed.\n");
        new Channel(parent, controller);
      }
    }
    
    Channel(Fixture _parent, int _controller, int _address, float _latency){
      parent = _parent;
      controller = _controller;
      latency = _latency;
      try {
        address = dmx.alloc(this, controller, _address);
      }
      catch (AddressAllocationException e) {
        System.err.println("Channel allocation on controller " + controller + ", address " + _address + " failed.\n");
        new Channel(parent, controller);
      }
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
    
    float getLatency(){
      return latency;
    }
  }  
}

//abstract class FixtureGroup extends Fixture {
 //it has some fixtures
 //and maybe some behaviors/actions/something
//}

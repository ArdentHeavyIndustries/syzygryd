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
  
  float getChannelLatency(String channelName){
    return ((Channel)channels.get(channelName)).getLatency();
  }

  void addTrait(String traitName, Trait traitDef){
    traits.put(traitName, traitDef);
  }
  
  Trait trait(String traitName){
    return (Trait)(traits.get(traitName));
  }
  
  void setBehavior(Behavior behavior){
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

class FixtureGroup extends Fixture {
  ArrayList<Fixture> members;
  
  FixtureGroup(String _type){
    super((DMX)null, -1, _type);
    members = new ArrayList<Fixture>();
  }
  
  /*
   * Add fixture of matching type to this group. Fails if fixture type does not match group type.
   */
  void addFixture(Fixture _fixture) throws FixtureTypeMismatchException {
    if (_fixture.type == type) {
      members.add(_fixture);
    }
    else {
      System.err.println("Fixture type mismatch while adding Fixture type \"" + _fixture.type + "\" to FixtureGroup type \"" + type + "\"\n\n");
      throw new FixtureTypeMismatchException();
    }
  }
  
  void setChannel(String channelName, int value){
    for (int i = 0; i < members.size(); i++){
      members.get(i).setChannel(channelName, value);
    }
  }
  
  int getChannel(String channelName){
    return members.get(0).getChannel(channelName); // hackish: assumes all members have same values
  }
  
  float getChannelLatency(String channelName){
    return members.get(0).getChannelLatency(channelName); // hackish: assumes all members have same values
  }
    
}

class FixtureTypeMismatchException extends Exception {}

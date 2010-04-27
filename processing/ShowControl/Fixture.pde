class FixtureProfile {
  String type;
  ArrayList traits;
  HashMap channels;
  
  FixtureProfile(XMLElement xml) throws DataFormatException {
    // validate xml
    String name = xml.getName();
    if (!name.equals("fixture_profile")) {
      throw new DataFormatException("The fixture profiles definition XML must have only <fixture_profile> " +
                                    "nodes under the <doc_root> node.  Found " + name + " instead");
    }
    
    // get type
    type = xml.getStringAttribute("type");
    if (type.equals(0)) {
      throw new DataFormatException("Found a <fixture_profile> with no 'type' attribute");
    }
    
    // parse traits
    XMLElement traitsEl = xml.getChild("traits");
    if (traitsEl != null) {
      int traitCount = traitsEl.getChildCount();
      traits = new ArrayList(traitCount);
      for (int i = 0; i < traitCount; i++) {
        XMLElement traitEl = traitsEl.getChild(i);
        String traitType = traitEl.getStringAttribute("type");
        if (traitType.equals(0)) {
          throw new DataFormatException("Found a <trait> with no 'type' attribute");
        }
      
        traits.add(traitType);
      }
    }
    
    // parse channels
    int allowedAttrLen = Configuration.ALLOWED_CHANNEL_ATTRIBUTES.length;

    XMLElement channelsEl = xml.getChild("channels");
    if (channelsEl != null) {
      int channelCount = channelsEl.getChildCount();
      channels = new HashMap(channelCount);
      for (int i = 0; i < channelCount; i++) {
        XMLElement channelEl = channelsEl.getChild(i);

        HashMap channelInfo = new HashMap();

        for (int j = 0; j < allowedAttrLen; j++) {
          String attrName = Configuration.ALLOWED_CHANNEL_ATTRIBUTES[j];
          String attr = channelEl.getStringAttribute(attrName);
          if (!attr.equals(0)) {
            channelInfo.put(attrName, attr);
          }
        }
      
        channels.put(channelInfo.get("name"), channelInfo);
      }
    }
  }
  
  public String getType() {
    return type;
  }
  
  public ArrayList getTraits() {
    return traits;
  }
  
  public HashMap getChannels() {
    return channels;
  }
}

class Fixture {
  
  DMX dmx;
  int controller;
  
  String type = null;
  HashMap traits = new HashMap();
  HashMap channels = new HashMap();
  
  FixtureProfile profile;
  
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

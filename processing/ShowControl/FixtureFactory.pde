/*
 * FixtureFactory - creates Fixture objects from a set of properties describing the fixture
 *
 */
static class FixtureFactory {
  // _registeredProfiles is our list of FixtureProfiles that are available to create Fixtures from
  public static HashMap _registeredProfiles = new HashMap();
  
  /*
   * registerFixtureProfile(profile) - register a FixtureProfile.  The registered
   * profiles are used when creating Fixture objects to assign the right traits
   * and channels to the fixture.
   */
  public static void registerFixtureProfile(FixtureProfile profile) {
    _registeredProfiles.put(profile.getType(), profile);
  }
  
  /*
   * createFixture(DMXManager, xml) - create a Fixture object from a <fixture> xml element
   */
  public static Fixture createFixture(ShowControl parent, DMX DMXManager, XMLElement xml) throws DataFormatException {
    // validate XML
    String name = xml.getName();
    if (!name.equals("fixture")) {
      throw new DataFormatException("The fixture profiles definition XML must have only <fixture> " +
                                    "nodes under the <doc_root> node.  Found " + name + " instead");
    }
    
    // look up fixture profile
    String profileType = xml.getStringAttribute("profile");
    if (profileType.equals(0)) {
      throw new DataFormatException("Found a <fixture> with no 'profile' attribute");
    }
    
    FixtureProfile profile = (FixtureProfile)_registeredProfiles.get(profileType);
    if (profile == null) {
      throw new DataFormatException("Specified profile " + profileType + " does not exist!");
    }
    
    // get dmx universe
    int DMXUniverse = xml.getIntAttribute("dmx_universe", -1);
    if (DMXUniverse == -1) {
      throw new DataFormatException("Found a <fixture> with no 'dmx_universe' attribute");
    }
    
    // create the fixture
    Fixture fixture = parent.new Fixture(DMXManager, DMXUniverse, profileType);
    
    // add the channels
    addChannels(parent, fixture, profile, xml);
    
    // add the traits
    addTraits(parent, fixture, profile, xml);
    
    return fixture;
  }
  
  static void addChannels(ShowControl parent, Fixture fixture, FixtureProfile profile, XMLElement xml) throws DataFormatException {
    HashMap profileChannels = profile.getChannels();
    XMLElement[] channels = xml.getChildren("channels/channel");
    for (int i = 0; i < channels.length; i++) {
      XMLElement channel = channels[i];

      int address = channel.getIntAttribute("address", -1);
      if (address == -1) {
        throw new DataFormatException("No channel address given");
      }

      String name = channel.getStringAttribute("name");
      if (name.equals(0)) {
        throw new DataFormatException("Channel without name found");
      }
      
      int latency = 0;
      HashMap channelInfo = (HashMap)profileChannels.get(name);
      if (channelInfo != null) {
        if (channelInfo.containsKey("latency")) {
          latency = Integer.parseInt((String)channelInfo.get("latency"));
        }
      }
      
      fixture.addChannel(name, address); // TODO: latency?  other properties?
    }
  }
  
  static void addTraits(ShowControl parent, Fixture fixture, FixtureProfile profile, XMLElement xml) throws DataFormatException {
    ArrayList profileTraits = profile.getTraits();
    int traitCount = profileTraits.size();
    for (int i = 0; i < traitCount; i++) {
      String traitName = (String)profileTraits.get(i);
      Trait trait;
      
      if ("RGBColorMixingTrait".equals(traitName)) {
        trait = (Trait)parent.new RGBColorMixingTrait(fixture);
      } else {
        throw new DataFormatException("No known trait " + traitName);
      }
      
      fixture.addTrait(traitName, trait);
    }
  }
}

/* define configuration constants */
interface Configuration {
  public static final String FIXTURE_PROFILES_FILENAME = "fixture_profiles.xml";
  public static final String FIXTURE_DEFINITIONS_FILENAME = "fixture_definitions.xml";
  public static final String[] ALLOWED_CHANNEL_ATTRIBUTES = { "name", "latency" };
}

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


// read the fixture profile and fixture definitions xml files, create the fixtures
// and add them to the fixtures list
void setupFixtures() throws DataFormatException {
  ArrayList fixtureProfiles = getFixtureProfiles();
  
  // register fixture profiles with the factory
  int profileCount = fixtureProfiles.size();
  for (int i = 0; i < profileCount; i++) {
    FixtureFactory.registerFixtureProfile((FixtureProfile)fixtureProfiles.get(i));
  }

  // read fixture definitions from xml  
  XMLElement fixtureDefinitionsXML = new XMLElement(this, Configuration.FIXTURE_DEFINITIONS_FILENAME);
  
  // use factory to create fixture from the fixture definitions
  XMLElement[] fixtureNodes = fixtureDefinitionsXML.getChildren("fixture");
  int fixtureCount = fixtureNodes.length;
  fixtures = new ArrayList(fixtureCount);
  for (int i = 0; i < fixtureCount; i++) {
    Fixture fixture = FixtureFactory.createFixture(this, DMXManager, fixtureNodes[i]);
    fixtures.add(fixture);
  }
}

ArrayList getFixtureProfiles() throws DataFormatException {
  // read fixture profiles from xml
  XMLElement fixtureProfilesXML = new XMLElement(this, Configuration.FIXTURE_PROFILES_FILENAME);

  // create FixtureProfiles from XML
  /* 
   * The fixtureProfilesXML file is expected to be a top-level <doc_root> node with a list 
   * of <fixture_profile> elements underneath.  Each <fixture_profile> element has 
   * a 'type' attribute, a single <traits> child and a singe <channels> child. <traits> contains
   * zero or more <trait> nodes, each with a 'type' attribute.  <channels> contains zero or more <channel> nodes,
   * each with a name attribute.  <channel> nodes can optionally have other attributes, such as 'latency'.
   *   
   */
  
  XMLElement[] profileNodes = fixtureProfilesXML.getChildren("fixture_profile");
  int profileCount = profileNodes.length;
  ArrayList fixtureProfiles = new ArrayList(profileCount);
  for (int i = 0; i < profileCount; i++) {
    FixtureProfile fixtureProfile = new FixtureProfile(profileNodes[i]);
    fixtureProfiles.add(fixtureProfile);
  }
  
  return fixtureProfiles;
}


/* define configuration constants */
interface Configuration {
  public static final String FIXTURE_PROFILES_FILENAME = "fixture_profiles.xml";
  public static final String FIXTURE_DEFINITIONS_FILENAME = "fixture_definitions.xml";
  public static final String[] ALLOWED_CHANNEL_ATTRIBUTES = { 
    "name", "latency"   };
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

      fixture.addChannel(name, address, latency);
    }
  }

  static void addTraits(ShowControl parent, Fixture fixture, FixtureProfile profile, XMLElement xml) throws DataFormatException {
    ArrayList profileTraits = profile.getTraits();
    int traitCount = profileTraits.size();
    for (int i = 0; i < traitCount; i++) {
      String traitName = (String)profileTraits.get(i);
      Trait trait;

      if ("RGBColorMixingTrait".equals(traitName)) {
        trait = parent.new RGBColorMixingTrait(fixture);
      } 
      else {
        throw new DataFormatException("No known trait " + traitName);
      }
      fixture.addTrait(traitName, trait);
    }
  }
}

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



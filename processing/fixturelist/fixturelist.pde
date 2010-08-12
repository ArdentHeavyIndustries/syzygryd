import proxml.*;

proxml.XMLElement fixture_definitions;
XMLInOut xmlIO;

void setup(){
  
  fixture_definitions = new proxml.XMLElement("fixture_definitions");
  xmlIO = new XMLInOut(this);
  
  for(int i = 0; i < 108; i++){
    proxml.XMLElement fixture = new proxml.XMLElement("fixture");
    fixture.addAttribute("profile", "cube");
    fixture.addAttribute("dmx_universe",0);
  
    proxml.XMLElement channel1 = new proxml.XMLElement("channel");
    channel1.addAttribute("name","red");
    channel1.addAttribute("address",i*3);
    proxml.XMLElement channel2 = new proxml.XMLElement("channel");
    channel2.addAttribute("name","green");
    channel2.addAttribute("address",i*3+1);
    proxml.XMLElement channel3 = new proxml.XMLElement("channel");
    channel3.addAttribute("name","blue");
    channel3.addAttribute("address",i*3+2);
    
    proxml.XMLElement channels = new proxml.XMLElement("channels");
    
    channels.addChild(channel1);
    channels.addChild(channel2);
    channels.addChild(channel3);    
  
    fixture.addChild(channels);

    fixture_definitions.addChild(fixture);
  }

  xmlIO.saveElement(fixture_definitions,"fixture_definitions.xml");  
  exit();
}


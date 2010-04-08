/*
 * Early approximation of a Fixture class. 
 * Now a just a placeholder for something that sucks less. 
 */

class Fixture {
  String type;
  String DMXuniverse;
  color lightColor;
  public HashMap props = new HashMap();
  HashMap DMXChannels;
  
  // overloaded to support optional _lightColor argument
  Fixture (String _type, color _lightColor) {
    type = _type;
    lightColor = _lightColor;
    props.put("R",red(lightColor));
    props.put("G",green(lightColor));
    props.put("B",blue(lightColor));
  }
  
  Fixture (String _type) {
    this(_type, color(0,0,0));  
  }
  
 public void addProp(String propName) {
    props.put(propName, 0);    
  }

  private class DMXMap {
    String universe;
    int channel, value;
  }    
}



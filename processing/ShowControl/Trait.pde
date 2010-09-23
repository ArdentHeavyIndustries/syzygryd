abstract class Trait {
  Fixture parent;
  Trait(Fixture _parent) {
    parent = _parent;
  }
}

class RGBColorMixingTrait extends Trait {

  RGBColorMixingTrait(Fixture parent) {
    super(parent);
  }

  public void setColorRGB(color RGBColor) {
    if (parent instanceof FixtureGroup) {
      setColorRGBGroup(RGBColor);
    } 
    else if (parent instanceof Fixture) {
      int r = (RGBColor >> 16 ) & 0xFF;
      int g = (RGBColor >> 8 ) & 0xFF;
      int b = RGBColor & 0xFF;
      parent.setChannel("red", r);
      parent.setChannel("green", g);
      parent.setChannel("blue", b);
    }
  }

  private void setColorRGBGroup(color RGBColor) {
    ArrayList<Fixture> groupFixtures = (ArrayList)((FixtureGroup)parent).members;
    for (int i = 0; i < groupFixtures.size(); i++) {
      ((RGBColorMixingTrait)groupFixtures.get(i).trait("RGBColorMixing")).setColorRGB(RGBColor);
    }
  }

  public color getColorRGB() {
    int a = 255;  
    int r = parent.getChannel("red");  
    int g = parent.getChannel("green"); 
    int b = parent.getChannel("blue"); 
    a = a << 24; 
    r = r << 16;  
    g = g << 8;   

    // Equivalent to "color argb = color(r, g, b, a)" but faster
    color argb = a | r | g | b;

    return argb;
  }
}

class FireTrait extends Trait {

  FireTrait(Fixture parent) {
    super(parent);
  }

  boolean isBurning() {
    return parent.getChannel("fire") == 55; //TODO: change this to final threshold value
  }

  public void color2Fire(color clr) {
    if (parent instanceof FixtureGroup) {
      color2FireGroup(clr);
    } 
    else if (parent instanceof Fixture) {
      if (brightness(clr) > 50){
        parent.setChannel("fire", 55);
      }
    }
  }
  
  private void color2FireGroup(color clr) {
    ArrayList<Fixture> groupFixtures = (ArrayList)((FixtureGroup)parent).members;
    for (int i = 0; i < groupFixtures.size(); i++) {
      ((FireTrait)groupFixtures.get(i).trait("Fire")).color2Fire(clr);
    }
  }

  public void fireOn() {
    if (parent instanceof FixtureGroup) {
      fireOnGroup();
    } 
    else if (parent instanceof Fixture) {
      parent.setChannel("fire", 55);
    }
  }
  
  private void fireOnGroup() {
    ArrayList<Fixture> groupFixtures = (ArrayList)((FixtureGroup)parent).members;
    for (int i = 0; i < groupFixtures.size(); i++) {
      ((FireTrait)groupFixtures.get(i).trait("Fire")).fireOn();
    }
  }
  

  public void fireOff() {
    if (parent instanceof FixtureGroup) {
      fireOffGroup();
    } 
    else if (parent instanceof Fixture) {
      parent.setChannel("fire", 0);
    }
  }
  
  private void fireOffGroup() {
    ArrayList<Fixture> groupFixtures = (ArrayList)((FixtureGroup)parent).members;
    for (int i = 0; i < groupFixtures.size(); i++) {
      ((FireTrait)groupFixtures.get(i).trait("Fire")).fireOff();
    }
  }
}


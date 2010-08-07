class LightingProgram {

  LightingProgram(){
  }
  
  void initialize() {
    
    ((RGBColorMixingTrait)test.trait("RGBColorMixing")).setColorRGB(color(0,255,0));  //set start color   
    ((RGBColorMixingTrait)test2.trait("RGBColorMixing")).setColorRGB(color(128,64,255));  //set start color   
    
    // Create test group
    FixtureGroup testGroup = new FixtureGroup("cube");
    testGroup.addTrait("RGBColorMixing", new RGBColorMixingTrait(testGroup));
    try{
      testGroup.addFixture(fixtures.get(0));
      testGroup.addFixture(fixtures.get(1));
      testGroup.addFixture(fixtures.get(2));
      testGroup.addFixture(fixtures.get(3));
      testGroup.addFixture(fixtures.get(4));
      testGroup.addFixture(fixtures.get(5));
      testGroup.addFixture(fixtures.get(6));
      testGroup.addFixture(fixtures.get(7));
      testGroup.addFixture(fixtures.get(8));
    } catch (FixtureTypeMismatchException ftme){}

    
    new FadeBehavior(testGroup, 9, now()+10000, 10100, color(#ffffff));  // wait 10 secs, then fade to white over 10 secs
    new FadeBehavior(testGroup, 8, now()+20000, 10000, color(#000000));  // wait 20 secs, then fade to black over 10 secs
    new HueRotateBehavior(testGroup, 10); // color cycling    
  }
  
  void drawFrame() {
  }
}


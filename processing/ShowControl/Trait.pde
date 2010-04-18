abstract class Trait {
  Fixture parent;
  Trait(Fixture _parent){
    parent = _parent;
  }
}

class RGBColorTrait extends Trait {
  
  RGBColorTrait(Fixture parent){
    super(parent);
  }
  
  void setColorRGB(color RGBColor){
    parent.setChannel("red", (int)red(RGBColor));
    parent.setChannel("green", (int)green(RGBColor));
    parent.setChannel("blue", (int)blue(RGBColor));
  }

  color getColorRGB(color RGBColor){
    colorMode(RGB);
    return color(parent.getChannel("red"),parent.getChannel("green"),parent.getChannel("blue"));
  }
}

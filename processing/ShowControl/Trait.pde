abstract class Trait {
  Fixture parent;
  Trait(Fixture _parent){
    parent = _parent;
  }
}

class RGBColorMixingTrait extends Trait {
  
  RGBColorMixingTrait(Fixture parent){
    super(parent);
  }
  
  void setColorRGB(color RGBColorMixing){
    parent.setChannel("red", (int)red(RGBColorMixing));
    parent.setChannel("green", (int)green(RGBColorMixing));
    parent.setChannel("blue", (int)blue(RGBColorMixing));
  }

  color getColorRGB(color RGBColorMixing){
    colorMode(RGB);
    return color(parent.getChannel("red"),parent.getChannel("green"),parent.getChannel("blue"));
  }
}

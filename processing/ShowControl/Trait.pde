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
    int r = (RGBColorMixing >> 16 ) & 0xFF;
    int g = (RGBColorMixing >> 8 ) & 0xFF;
    int b = RGBColorMixing & 0xFF;
    parent.setChannel("red", r);
    parent.setChannel("green", g);
    parent.setChannel("blue", b);
  }

  color getColorRGB(){
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

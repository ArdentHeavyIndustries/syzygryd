// FrameBrulee
// A lighting and fire control program for Syzygryd, using the Layer interface
// Jonathan Stray, August 2010


// A BruleeModule is a Layer with some parameters
// It is sensitive to intensity and change messages, and will fade in and out
class BruleeModule extends Layer {
  
  boolean active;    // fading or running
  float fadeInSpeed;
  float fadeOutSpeed;
  
  BruleeModule() {
    active = true;
    fadeInSpeed = 0;
    fadeOutSpeed = 0;
  }
  
  // fades in to 100 opacity from current level, duration is time from 0 to 100
  void startFadeIn(float duration) {
    fadeOutSpeed = 0;
    fadeInSpeed = 1/duration;
    active = true;
  }
  
  // fades to 0 opacity from current level, duration is time from 100 to 0
  void startFadeOut(float duration) {
    fadeOutSpeed = 0;
    fadeInSpeed = 1/duration;
    active = true;
  }

  void animateFades(float elapsedSteps) {
    if (active) {
      
      if (fadeInSpeed > 0) {
        opacity += elapsedSteps * fadeInSpeed;
        if (opacity >= 1) {
          fadeInSpeed = 0;
          opacity = 1;
        }
      } else if (fadeOutSpeed > 0) {
         opacity -= elapsedSteps * fadeOutSpeed;
         if (opacity <= 0) {
           fadeOutSpeed = 0;
           opacity = 0;
           active = false;
         }   
      }
    }
  }
  
  void update(float elapsedSteps, float intensity) {
    animateFades(elapsedSteps);
  }
  
  // we hit a bar or the operator pressed a button or something... change up the parameters
  void change() {
  }
  
}


// TransientLayerModule is a BruleeModule that maintains a bunch of layers that animate on their own. Useful for e.g. note displays

// Globals parameters that control the program. These are exposed to the operator through touchOSC

float fbIntensity = 0.5;       // how much stuff is going on?

float fbAnimationSpeed = 1;    // relative to steps

color fbTint = color(#808080); // central hue and sat 
float fbChroma = 1.0;          // 1.0 means full range, 0 means monochromatic


class FrameBrulee extends LightingProgram {
  
  // mode constants
  static final int MODE_PULSE = 1;
  static final int MODE_DIRECT = 2;
  static final int MODE_PERMUTE = 3;
  static final int MODE_BLACK_PULSE = 4;
  
  // which mode?
  int currentMode = MODE_PULSE;
  
  // Bottom Permanent layers
  HueRotateLayer     baseHueRotate;       // constant hueRotate layer on bottom
  //RippleLayer        baseRipple;          // ripple the base hue (multiplied)
  //DirectDisplayLayer noteDisplay;         // show up the notes directly
  //DirectDisplayLayer permutedNoteDisplay; // display the notes on random cubes
    
  // On top of these we have transient layers for chases
  
  // Top permanent layers
  //TintLayer          tintLayer;
  
  color[] whitePulse = new color[] {color(50, 50, 50), color(100, 100, 100), color(200, 200, 200)}; // simple lighting "pulse" for chase layers
  
  void initialize() {
    
    // Bottom layer is a hue rotate
    layers.clear(); 
    baseHueRotate = new HueRotateLayer(color(#8f0000), 5.0);
    layers.add(baseHueRotate);
  }
  
  int randomMode() {
    float r = random(4);
    if (r<1) 
      return MODE_PULSE;
    else if (r<2)
      return MODE_DIRECT;
    else if (r<3)
     return MODE_PERMUTE;
    else
     return MODE_BLACK_PULSE; 
  }
  
  void update(float elapsedSteps) {
 
    /*
     if (events.fired("bar")) {
       // probabilistic mode switch on the bar
       if (random(1) < fbIntensity) {
         currentMode = randomMode();
       }
     }
    */
    
    for (int i=0; i<3; i++) {   
      if (events.fired("notes" + Integer.toString(i))) {
        layers.add(new ChaseLayer(i, whitePulse, 0.2, -3));
      }
    }
  
  }
}


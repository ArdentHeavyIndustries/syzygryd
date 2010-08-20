// FrameBrulee
// A lighting and fire control program for Syzygryd, using the Layer interface
// Jonathan Stray, August 2010


// ------------------------------------------------- FrameBrulee parameter block  --------------------------------------
// These are all the parameters of a FrameBrulee program. 
// Can be saved/restored. Some are controllable via OSC.
// Individual modules know how to configure their own parameters from the global state.
// The defaults are also here.

class FBParams {
  // overall control
  public float intensity = 0.5;       // how much stuff is going on?
  public float animationSpeed = 1;    // relative to steps

  // hue rotation controls
  public float baseHueRotationSpeed = 1;    // degrees/sec
  public float baseHueSpread = 60; // degrees lead/lag
  public float baseHueSat = 80;
  public float baseHueBright = 60;

  // note display settings
  public float pulseWidth = 1;          // number of cubes that a single pulse lights up
  public float jitter = 3;              // jitter for displays that permute/shift note positions
  public float jitterAcrossArms = 0;    // probability that a note display will be jittered across arms
  
  // final color correction params
  public color fbTint = color(#808080); // central hue and sat 
  public float fbChroma = 1.0;          // 1.0 means full range, 0 means monochromatic
};

// Current FB state
FBParams curFBParams = new FBParams();


// OSC receiver function that modifies the global state 
// Also does OSC control ranges
void processOSCLightEvent(OscMessage m) {

// println(m.addrPattern());
  
  if (m.addrPattern().startsWith("/advanced_lighting/baseHueSpeed")) {
  
    curFBParams. baseHueRotationSpeed = pow(m.get(0).floatValue(), 4) * 150;    // add nonlinearity to widen lower end of the scale
   // println("speed");
  } 
  
  else if (m.addrPattern().startsWith("/advanced_lighting/baseHueSpread")) {
    curFBParams.baseHueSpread = m.get(0).floatValue() * 120;                    // 120 degrees is max spread, for three arms
 //   println("spread");
  } 
  
  else if (m.addrPattern().startsWith("/advanced_lighting/baseHueSaturation")) {
    curFBParams.baseHueSat = m.get(0).floatValue() * 100;  
 //   println("spread");
  } 
  
  else if (m.addrPattern().startsWith("/advanced_lighting/baseHueBrightness")) {
    curFBParams.baseHueBright = m.get(0).floatValue() * 100;  
 //   println("spread");
  } 
}

// ------------------------------------------------- FrameBrulee core --------------------------------------

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
  NoteChaseModule    noteChase;
  NoteDisplayModule  noteDisplay;
  NotePermuteModule  notePermute;
  
  // Top permanent layers
  //TintLayer          tintLayer;
   
  void initialize() {
    // Bottom layer is a hue rotate
    baseHueRotate = new HueRotateLayer(baseHueRotationSpeed);
    noteChase = new NoteChaseModule();
    noteDisplay = new NoteDisplayModule();
    notePermute = new NotePermuteModule();
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
  
  
  // Advance winds all the modules forward, plus changes modes / parameters at bar boundaries
  void advance(float elapsedSteps) {
 
    // get baseHue parameters from the OSC-driven globals
    baseHueRotate.degreesPerStep = baseHueRotationSpeed;
    baseHueRotate.degreesSpread = baseHueSpread;
    baseHueRotate.sat = baseHueSat;
    baseHueRotate.bright = baseHueBright;
    baseHueRotate.advance(elapsedSteps);
    
    noteChase.advance(elapsedSteps);
    noteDisplay.advance(elapsedSteps);
    notePermute.advance(elapsedSteps);
  }
  
  // This is the core rendering stack, that applies all the right modules in the right order, according to mode
  void render(LightingState state) {
    baseHueRotate.apply(state);
    //noteChase.apply(state);
    //noteDisplay.apply(state);
    notePermute.apply(state);
  }

}


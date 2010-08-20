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
  public float jitter = 0.1;          // general unpredictability of positions and timing

  // hue rotation controls
  public float baseHueRotationSpeed = 1; // degrees/sec
  public float baseHueSpread = 60;       // degrees lead/lag
  public float baseHueSat = 80;
  public float baseHueBright = 60;

  // note display settings
  public float pulseWidth = 1;            // number of cubes that a single pulse lights up
  public float permuteAcrossArms = 0;     // probability that a note display will be jittered across arms
  
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

  
  // Bottom Permanent layers
  HueRotateModule     baseHueRotate;       // constant hueRotate layer on bottom
  //RippleLayer        baseRipple;          // ripple the base hue (multiplied)
    
  // On top of these we have transient layers for chases
  NoteChaseModule    noteChase;
  NoteDisplayModule  noteDisplay;
  NotePermuteModule  notePermute;
  
  // Top permanent layers
  //TintLayer          tintLayer;
   
  void initialize() {
    // Bottom layer is a hue rotate
    baseHueRotate = new HueRotateModule(curFBParams);
    noteChase = new NoteChaseModule(curFBParams);
    noteDisplay = new NoteDisplayModule(curFBParams);
    notePermute = new NotePermuteModule(curFBParams);
  }

  
  // Advance winds all the modules forward, plus changes modes / parameters at bar boundaries
  void advance(float elapsedSteps) {
    
    float mutation = 0;
/*    if (events.fired("step")) {
      mutation = MUTATE_BEAT;
    } else if (events.fired("bar")) {
      mutation = MUTATE_BAR;
    } else if (events.fired("4bars")) {
      mutation = MUTATE_4BAR;
    }
  */ 
    if (events.fired("4bars")) {
      mutation = 1;
    }
      
    if (mutation != 0) {
      // mutate globals first since they affect mutations
      curFBParams.intensity = mutateValue(curFBParams.intensity, mutation, 1);
      curFBParams.jitter = mutateValue(curFBParams.jitter, mutation, 1);
  
      // animation speed is a little different: we jitter in log space to give more range to small values
      float logSpeed = log(curFBParams.animationSpeed);
      logSpeed += signedRandom(mutation);
      logSpeed = clip(logSpeed, -2, 2);    // approx 1/8 to 8 (e^2)
      curFBParams.animationSpeed = exp(logSpeed);
      
      baseHueRotate.mutate(mutation);
      noteChase.mutate(mutation);
      noteDisplay.mutate(mutation);
      notePermute.mutate(mutation);
    }
    
    baseHueRotate.masterAdvance(elapsedSteps);
    noteChase.masterAdvance(elapsedSteps);
    noteDisplay.masterAdvance(elapsedSteps);
    notePermute.masterAdvance(elapsedSteps);    
  }
  
  // This is the core rendering stack, that applies all the right modules in the right order, according to mode
  void render(LightingState state) {
    baseHueRotate.apply(state);
    noteChase.apply(state);
//    noteDisplay.apply(state);
    notePermute.apply(state);
  }

}


// returns uniformly distributed in [-v, +v)
float signedRandom(float v) {
  return random(v*2)-v;
}


float mutateValue(float v, float mutation, float maxV) {
  v += (random(maxV) - maxV/2) * mutation;
  if (v<0) {
    v=0;
  } else if (v>maxV) {
    v=maxV;
  }
  return v;
}

float clip (float v, float a, float b) {
  return min(b, max(a, v));
}


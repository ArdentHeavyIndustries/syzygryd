/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

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
  public float lightIntensity = 0.2;    // fraction of simultaneously applied lighting modules
  public float fireIntensity = 0.5;     // ditto fire
  public float animationSpeed = 1;      // relative to steps
  public float jitter = 0.1;            // general unpredictability of positions and timing
  public float attack = 1;              // how fast does stuff come on? steps
  public float decay = 5;               // how fast dues stuff go off? steps

  public boolean hold = false;          // dont switch up the lighting every 4bars
  
  // hue rotation controls
  public float baseHueRotationSpeed = 1; // degrees/sec
  public float baseHueSpread = 60;       // degrees lead/lag
  public float baseHueSat = 80;          // out of 100
  public float baseHueBright = 60;       // out of 100

  // note display settings
  public float pulseWidth = 1;            // number of cubes that a single pulse lights up
  public float permuteAcrossArms = 0;     // probability that a note display will be jittered across arms
  
  // final color correction params
  public color ccTint = color(255,255,255); // central hue and sat 
  public float ccChroma = 1.0;          // 1.0 means full range, 0 means monochromatic
  public float ccBrightness = 0.6;      // we add a lot of effects together; tend to clip if we don't do this
};

// Current FB state
FBParams curFBParams = new FBParams();


// OSC receiver function that modifies the global state 
// Also does OSC control ranges
void processOSCLightEvent(OscMessage m) {

// println(m.addrPattern());
  
  if (m.addrPattern().startsWith("/lightingColor/baseHueSpeed")) {
  
    curFBParams. baseHueRotationSpeed = pow(m.get(0).floatValue(), 4) * 150;    //OSC control is unscaled 0..1. Add nonlinearity to widen lower end of the scale
   // println("speed");
  } 
  
  else if (m.addrPattern().startsWith("/lightingColor/baseHueSpread")) {
    curFBParams.baseHueSpread = m.get(0).floatValue();
 //   println("spread");
  } 
  
  else if (m.addrPattern().startsWith("/lightingColor/baseHueSaturation")) {
    curFBParams.baseHueSat = m.get(0).floatValue() ;  
 //   println("spread");
  } 
  
  else if (m.addrPattern().startsWith("/lightingColor/baseHueBrightness")) {
    curFBParams.baseHueBright = m.get(0).floatValue();  
 //   println("spread");
  } 

  else if (m.addrPattern().startsWith("/lightingColor/tint")) {
    float x = m.get(0).floatValue();  
    float y = m.get(1).floatValue();
    
    colorMode(HSB, 360, 100, 100);
    curFBParams.ccTint = color((degrees(atan2(y,x))+360)%360, min(100, 100*sqrt(x*x + y*y)), 100);   // +360%360 as color ctor does not like negative hues
    colorMode(RGB, 255);
  } 
  
  else if (m.addrPattern().startsWith("/lightingColor/chroma")) {
    curFBParams.ccChroma = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightingColor/brightness")) {
    curFBParams.ccBrightness = m.get(0).floatValue();  
  } 
  
  else if (m.addrPattern().startsWith("/lightingControls/animationSpeed")) {
    curFBParams.animationSpeed = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightingControls/pulseWidth")) {
    curFBParams.pulseWidth = m.get(0).floatValue();  
  //println("pulseWidth:" + curFBParams.pulseWidth);
  } 

  else if (m.addrPattern().startsWith("/lightingControls/attack")) {
    curFBParams.attack = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightingControls/decay")) {
    curFBParams.decay = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightingControls/decay")) {
    curFBParams.decay = m.get(0).floatValue();  
  } 
  
  else if (m.addrPattern().startsWith("/fireControl/hold")) {
    curFBParams.hold = m.get(0).floatValue() != 0;
  } 

  else if (m.addrPattern().startsWith("/fireControl/change")) {
    events.fire("change");
  } 

  else if (m.addrPattern().startsWith("/fireControl/lightIntensity")) {
    curFBParams.lightIntensity = m.get(0).floatValue();    
  } 


}

void sendTouchOSCMsg(String addr, float value) {
  OscMessage msg = new OscMessage(addr);
  msg.add(value);
//  if ( OSCConnection_touchOSC == null) println("null 1");
//  if ( OSCConnection_touchOSC.myRemoteLocation == null) println("null 2");
  
  if ( OSCConnection_touchOSC.myRemoteLocation != null) { 
  OSCConnection_touchOSC.oscP5.send(msg, OSCConnection_touchOSC.myRemoteLocation);
  //println("got it");
  }
}

void outputParamsToOSC(FBParams fb) {
  sendTouchOSCMsg("/lightingColor/baseHueSpread", fb.baseHueSpread);
  sendTouchOSCMsg("/lightingColor/baseHueSaturation", fb.baseHueSat);
  sendTouchOSCMsg("/lightingColor/baseHueBrightness", fb.baseHueBright);  
}


// ------------------------------------------------- FrameBrulee core --------------------------------------

class FrameBrulee extends LightingProgram {

  
  // Bottom Permanent layers
  HueRotateModule     baseHueRotate;       // constant hueRotate layer on bottom
  //RippleLayer        baseRipple;          // ripple the base hue (multiplied)
    
  // On top of these we have transient layers for chases
  ArrayList<FBModule>  lightModules = new ArrayList();
  ArrayList<FBModule>  fireModules = new ArrayList();
  
  TintModule         tinty;
  
  // Top permanent layers
  //TintLayer          tintLayer;
  
  LightingState effectsLayers = new LightingState();   // save a new on every frame
  
  void initialize() {
    
    outputParamsToOSC(curFBParams);
  
    // Fixed modules
    baseHueRotate = new HueRotateModule(curFBParams);
    tinty = new TintModule(curFBParams);

    // Now create a bunch of visualizer modules. These will get stacked in some order, and enabled depending on curFBParams.intensity()
    lightModules.add(new NoteChaseModule(curFBParams));
    lightModules.add(new NoteDisplayModule(curFBParams));
    lightModules.add(new NotePermuteModule(curFBParams));
    lightModules.add(new BeatTrainModule(curFBParams)); 
    lightModules.add(new BassPulseModule(curFBParams));
    
    fireModules.add(new FireChaseModule(curFBParams));
  }

  
  // Advance winds all the modules forward, plus changes modes / parameters at bar boundaries
  void advance(float steps) {
    baseHueRotate.masterAdvance(steps);
    
    for (FBModule m : lightModules) {
      m.masterAdvance(steps);
    }    
    for (FBModule m : fireModules) {
      m.masterAdvance(steps);
    }    
        
    if (events.fired("bar"))
      outputParamsToOSC(curFBParams);
      
    if (!curFBParams.hold && events.fired("change")) {
      change();
    }
  }
  
  // This is the core rendering stack, that applies all the right modules in the right order, according to mode
  void render(LightingState state) {
    baseHueRotate.apply(state);

    // apply the effects separately so we can color correct before adding to base hue    
    effectsLayers.clear();

    // Apply modules depending on intensity
    int numModules = lightModules.size();
    int modulesToApply = min(floor(curFBParams.lightIntensity * (numModules+1)), numModules-1); // min to handle boundary cdn with intensity=1
    for (int i=0; i<modulesToApply; i++) {
      lightModules.get(i).apply(effectsLayers);
    }
        
    // tint the effects and add to the base hue rotate
    tinty.apply(effectsLayers);
    state.blendOverSelf(effectsLayers, ADD, 1);
    
    // add the fire!
    numModules = fireModules.size();
    modulesToApply = min(floor(curFBParams.fireIntensity * (numModules+1)), numModules-1); // min to handle boundary cdn with intensity=1
    for (int i=0; i<modulesToApply; i++) {
      fireModules.get(i).apply(state);
    }
  }
  
  // restack the modules (changing which are active, for a given intensity) and reset their parameters 
  void change() {
    
    // size of change measured in probability of a swap at each step
//    restackModules(lightModules, random(1));
//    restackModules(fireModules, random(1));    

    int[] permute = new int[lightModules.size()];
    for (int i=0; i<permute.length; i++)
      permute[i] = i;
    randomPermute(permute, random(1));
    ArrayList<FBModule> newstack = new ArrayList();
    for (int i=0; i<permute.length; i++)
       newstack.add(lightModules.get(permute[i]));
    lightModules = newstack; 
  }

/*
  // apply some random permutes to restack a module list
  restackModules(ArrayList<FBModule> a, float p) {    
    for (int i=0; i<a.size(); i++) {
      if (p >  random(1)) {
        int j = floor(random(a.size()));
        FBModule tmp = a.get(i);
        a.set(i, a.get(j));
        a.set(j, tmp);
      }   
    }
  }
*/

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



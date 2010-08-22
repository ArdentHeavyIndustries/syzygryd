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
  public float attack = 1;          // how fast does stuff come on? steps
  public float decay = 5;             // how fast dues stuff go off? steps

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

 println(m.addrPattern());
  
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

}

void sendTouchOSCMsg(String addr, float value) {
  OscMessage msg = new OscMessage(addr);
  msg.add(value);
//  if ( OSCConnection_touchOSC == null) println("null 1");
//  if ( OSCConnection_touchOSC.myRemoteLocation == null) println("null 2");
  
  if ( OSCConnection_touchOSC.myRemoteLocation != null) { 
  OSCConnection_touchOSC.oscP5.send(msg, OSCConnection_touchOSC.myRemoteLocation);
  println("got it");
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
  NoteChaseModule    noteChase;
  NoteDisplayModule  noteDisplay;
  NotePermuteModule  notePermute;
  BassPulseModule    bassPulse;
  BeatTrainModule    beatTrain;
  TintModule         tinty;
  FireChaseModule    fireChase;
  
  // Top permanent layers
  //TintLayer          tintLayer;
  
  LightingState effectsLayers = new LightingState();   // save a new on every frame
  
  void initialize() {
    
    outputParamsToOSC(curFBParams);

    baseHueRotate = new HueRotateModule(curFBParams);
    noteChase = new NoteChaseModule(curFBParams);
 //   noteDisplay = new NoteDisplayModule(curFBParams);
    notePermute = new NotePermuteModule(curFBParams);
    beatTrain = new BeatTrainModule(curFBParams); 
    bassPulse = new BassPulseModule(curFBParams);
    tinty = new TintModule(curFBParams);
    fireChase = new FireChaseModule(curFBParams);
  }

  
  // Advance winds all the modules forward, plus changes modes / parameters at bar boundaries
  void advance(float steps) {
    baseHueRotate.masterAdvance(steps);
    noteChase.masterAdvance(steps);
//    noteDisplay.masterAdvance(steps);
    notePermute.masterAdvance(steps);
    beatTrain.masterAdvance(steps);    
    bassPulse.masterAdvance(steps);
    fireChase.masterAdvance(steps);
    
    if (events.fired("bar"))
      outputParamsToOSC(curFBParams);
  }
  
  // This is the core rendering stack, that applies all the right modules in the right order, according to mode
  void render(LightingState state) {
    baseHueRotate.apply(state);

    // apply the effects separately so we can color correct before adding to base hue    
    effectsLayers.clear();
//    noteChase.apply(effectsLayers);
//    noteDisplay.apply(state);
    notePermute.apply(effectsLayers);
//    beatTrain.apply(effectsLayers);
//    bassPulse.apply(effectsLayers);
    
    // tint the effects and add to the base hue rotate
    tinty.apply(effectsLayers);
    state.blendOverSelf(effectsLayers, ADD, 1);
    
    // add the fire!
    fireChase.apply(state);
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


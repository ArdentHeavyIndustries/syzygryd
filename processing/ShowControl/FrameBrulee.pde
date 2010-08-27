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
  
  // effects on/off. These are switched up during change()
  public boolean effectNoteChase = false;
  public boolean effectNoteDisplay = false;
  public boolean effectNotePermute = true;
  public boolean effectBeatTrain = false;
  public boolean effectBassPulse = true;
  
  // fire effects
  public boolean effectFireChase;
  public boolean effectFireDisplay;
  
  // final color correction params
  public color ccTint = color(255,255,255); // central hue and sat 
  public float ccChroma = 1.0;          // 1.0 means full range, 0 means monochromatic
  public float ccBrightness = 0.6;      // we add a lot of effects together; tend to clip if we don't do this
};

// Current FB state
FBParams curFBParams = new FBParams();

// These two functions need to be inverses... or the touchOSC won't work
float baseHueSpeedOSCToInternal(float oscVal) {
  return pow(oscVal, 4) * 150;    //OSC control is unscaled 0..1. Add nonlinearity to widen lower end of the scale
}
float baseHueSpeedInternalToOSC(float internalVal) {
  return pow(internalVal/150, 0.25);
}

// These functions also need to be inverses
color tintOSCToInternal(float x, float y) {
    colorMode(HSB, 360, 100, 100);
    color result = color((degrees(atan2(y,x))+360)%360, min(100, 100*sqrt(x*x + y*y)), 100);   // +360%360 as color ctor does not like negative hues
    colorMode(RGB, 255);
    return result;
}

float tintInternalToOSCx(color c) {
    colorMode(HSB, 360, 100, 100);
    float h = hue(c);
    float s = saturation(c);
    float x = cos(radians(h)) * s/100;
    colorMode(RGB, 255);
    return x;
}
float tintInternalToOSCy(color c) {
    colorMode(HSB, 360, 100, 100);
    float h = hue(c);
    float s = saturation(c);
    float y = sin(radians(h)) * s/100;
    colorMode(RGB, 255);
    return y;
}


// OSC receiver function that modifies the global state 
// Also does OSC control ranges
void processOSCLightEvent(OscMessage m) {

 //println(m.addrPattern());
  
  if (m.addrPattern().startsWith("/lightingColor/baseHueSpeed")) {
    curFBParams.baseHueRotationSpeed = baseHueSpeedOSCToInternal(m.get(0).floatValue());
   // println("speed");
  } 
  
  else if (m.addrPattern().startsWith("/lightingColor/baseHueSpread")) {
    curFBParams.baseHueSpread = m.get (0).floatValue();
    println("spread");
  } 
  
  else if (m.addrPattern().startsWith("/lightingColor/baseHueSaturation")) {
    curFBParams.baseHueSat = m.get(0).floatValue() ;  
  } 
  
  else if (m.addrPattern().startsWith("/lightingColor/baseHueBrightness")) {
    curFBParams.baseHueBright = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightingColor/tint")) {
    curFBParams.ccTint = tintOSCToInternal(m.get(0).floatValue(), m.get(1).floatValue());
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

  else if (m.addrPattern().startsWith("/fireControl/hold")) {
    curFBParams.hold = m.get(0).floatValue() != 0;
  } 

  else if (m.addrPattern().startsWith("/fireControl/change")) {
    events.fire("change");
  } 

  else if (m.addrPattern().startsWith("/fireControl/lightIntensity")) {
    curFBParams.lightIntensity = m.get(0).floatValue();    
  } 

  else if (m.addrPattern().startsWith("/effectControl/display")) {
    curFBParams.effectNoteDisplay = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/effectControl/permute")) {
    curFBParams.effectNotePermute = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/effectControl/noteChase")) {
    curFBParams.effectNoteChase = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/effectControl/beatTrain")) {
    curFBParams.effectBeatTrain = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/effectControl/bassPulse")) {
    curFBParams.effectBassPulse = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/effectControl/fireChase")) {
    curFBParams.effectFireChase = m.get(0).floatValue() != 0;    
    println("curFBParams.effectFireChase: " + curFBParams.effectFireChase);
  } 

  else if (m.addrPattern().startsWith("/effectControl/fireDisplay")) {
    curFBParams.effectFireDisplay = m.get(0).floatValue() != 0;    
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

void sendTouchOSCMsg2(String addr, float x, float y) {
  OscMessage msg = new OscMessage(addr);
  msg.add(x);
  msg.add(y);
  
  if ( OSCConnection_touchOSC.myRemoteLocation != null) { 
    OSCConnection_touchOSC.oscP5.send(msg, OSCConnection_touchOSC.myRemoteLocation);
  }
}

void sendTouchOSCMsg(String addr, boolean b) {
  if (b)
    sendTouchOSCMsg(addr, 1.0);
  else
    sendTouchOSCMsg(addr, 0.0);  
}

void outputParamsToOSC(FBParams fb) {
  sendTouchOSCMsg("/lightingColor/baseHueSpeed", baseHueSpeedInternalToOSC(fb.baseHueRotationSpeed));
  sendTouchOSCMsg("/lightingColor/baseHueSpread", fb.baseHueSpread);
  sendTouchOSCMsg("/lightingColor/baseHueSaturation", fb.baseHueSat);
  sendTouchOSCMsg("/lightingColor/baseHueBrightness", fb.baseHueBright); 

  sendTouchOSCMsg2("/lightingColor/tint", tintInternalToOSCx(curFBParams.ccTint), tintInternalToOSCy(curFBParams.ccTint));
  sendTouchOSCMsg("/lightingColor/chroma", curFBParams.ccChroma);
  sendTouchOSCMsg("/lightingColor/brightness", curFBParams.ccBrightness);
  
  sendTouchOSCMsg("/lightingControls/animationSpeed", curFBParams.animationSpeed);
  sendTouchOSCMsg("/lightingControls/pulseWidth", curFBParams.pulseWidth);
  sendTouchOSCMsg("/lightingControls/attack", curFBParams.attack);
  sendTouchOSCMsg("/lightingControls/decay", curFBParams.decay);

  sendTouchOSCMsg("/effectControl/display", curFBParams.effectNoteDisplay);
  sendTouchOSCMsg("/effectControl/permute", curFBParams.effectNotePermute);
  sendTouchOSCMsg("/effectControl/noteChase",   curFBParams.effectNoteChase);
  sendTouchOSCMsg("/effectControl/beatTrain",  curFBParams.effectBeatTrain);
  sendTouchOSCMsg("/effectControl/bassPulse",  curFBParams.effectBassPulse);
    
  sendTouchOSCMsg("/effectControl/fireChase",  curFBParams.effectFireChase);
  sendTouchOSCMsg("/effectControl/fireDisplay",  curFBParams.effectFireDisplay);
  
  sendTouchOSCMsg("/fireControl/hold", curFBParams.hold);
}



// ------------------------------------------------- FrameBrulee core --------------------------------------

class FrameBrulee extends LightingProgram {


  // Bottom Permanent layers
  HueRotateModule     baseHueRotate;       // constant hueRotate layer on bottom

  NoteChaseModule noteChase;
  NoteDisplayModule noteDisplay;
  NotePermuteModule notePermute;
  BeatTrainModule beatTrain;
  BassPulseModule bassPulse;    
  
  TintModule         tinty;
  
  // Now the fire...
  FireChaseModule fireChase;
  NoteDisplayModule fireDisplay;
  
  LightingState effectsLayers;
  
  void initialize() {
    
    outputParamsToOSC(curFBParams);
  
    // Fixed modules
    baseHueRotate = new HueRotateModule(curFBParams);
    tinty = new TintModule(curFBParams);

    // Visualizer modules, can be turned on and off
    noteChase = new NoteChaseModule(curFBParams);
    noteDisplay = new NoteDisplayModule(curFBParams, LIGHT);
    notePermute = new NotePermuteModule(curFBParams, LIGHT);
    beatTrain = new BeatTrainModule(curFBParams, LIGHT);
    bassPulse = new BassPulseModule(curFBParams);
   
    fireChase = new FireChaseModule(curFBParams);
    fireDisplay = new NoteDisplayModule(curFBParams, FIRE);
    
    effectsLayers = new LightingState();
    
    change();
    outputParamsToOSC(curFBParams);
 }


  // Advance winds all the modules forward, plus changes modes / parameters at bar boundaries
  void advance(float steps) {
    baseHueRotate.masterAdvance(steps);
    
    noteChase.masterAdvance(steps);
    noteDisplay.masterAdvance(steps);
    notePermute.masterAdvance(steps);
    beatTrain.masterAdvance(steps);
    bassPulse.masterAdvance(steps);

    fireChase.masterAdvance(steps);
    fireDisplay.masterAdvance(steps);
    
    if (events.fired("bar"))
      outputParamsToOSC(curFBParams);
      
    if ( (events.fired("4bars") && !curFBParams.hold) ||
         events.fired("change") )
      change();
  }
 
  // This is the core rendering stack, that applies all the right modules in the right order, according to mode
  void render(LightingState state) {
    baseHueRotate.apply(state);

    // apply the effects separately so we can color correct before adding to base hue    
    effectsLayers.clear();

    // Apply modules depending on intensity
    if (curFBParams.effectNoteChase)
      noteChase.apply(effectsLayers);
    if (curFBParams.effectNoteDisplay)
      noteDisplay.apply(effectsLayers);
    if (curFBParams.effectNotePermute)
      notePermute.apply(effectsLayers);
    if (curFBParams.effectBeatTrain)
      beatTrain.apply(effectsLayers);
    if (curFBParams.effectBassPulse)
      bassPulse.apply(effectsLayers);

    // tint the effects and add to the base hue rotate
    tinty.apply(effectsLayers);
    state.blendOverSelf(effectsLayers, ADD, 1);
    
    // add the fire!
    if (curFBParams.effectFireChase)
      fireChase.apply(state);
    if (curFBParams.effectFireDisplay)
      fireDisplay.apply(state);
    
  }

  // turn on different modules, switch up parameters
  void change() {
    println("Change!");
    
    float p = 0.4;  // probability that each module is on
    
    curFBParams.effectNoteDisplay = random(1) < p;
    curFBParams.effectNotePermute = random(1) < p;
    curFBParams.effectNoteChase = random(1) < p;
    curFBParams.effectBeatTrain = random(1) < p;
    curFBParams.effectBassPulse = random(1) < p;
    
    curFBParams.effectFireChase = random(1) < p;
    curFBParams.effectFireDisplay = random(1) < p;
    
    if (curFBParams.effectNoteDisplay) println("NoteDisplay");
    if (curFBParams.effectNotePermute) println("NotePermute");
    if (curFBParams.effectNoteChase) println("NoteChase");
    if (curFBParams.effectBeatTrain) println("BeatTrain");
    if (curFBParams.effectBassPulse) println("BassPulse");
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


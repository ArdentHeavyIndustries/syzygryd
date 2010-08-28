/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

// FrameBrulee
// A lighting and fire control program for Syzygryd, using the Layer interface
// Jonathan Stray, August 2010

// ------------------------------------------------- FrameBrulee parameter block  --------------------------------------
// These are all the parameters of a FrameBrulee program. 
// Can be saved/restored. Some are controllable via OSC.
// Individual modules know how to configure their own parameters from the global state.
// The defaults are also here.

class FBParams implements Cloneable {
  public int   changeRate = 4;          // indexes changeRatePeriod array, index 4 = every 64 steps = every 4 bars
  public float mutationRate = 0.2;            // 1 = change everything when mutating, 0 = change nothing
  public boolean changeEffectSettings = true;
  public boolean changeEffectColors = true;
  public boolean changeEffectPatterns = true;
  
  // effect settings
  public float animationSpeed = 1;      // relative to steps
  public float pulseWidth = 1;            // number of cubes that a single pulse lights up
  public float flicker = 0.1;            // general unpredictability of positions and timing
  public float attack = 1;              // how fast does stuff come on? steps
  public float decay = 5;               // how fast dues stuff go off? steps
  
  // hue rotation controls
  public float baseHueRotationSpeed = 1; // degrees/sec
  public float baseHueSpread = 60;       // degrees lead/lag
  public float baseHueSat = 80;          // out of 100
  public float baseHueBright = 60;       // out of 100
  
  // effects on/off. These are switched up during change()
  public boolean effectNoteChase = false;
  public boolean effectNoteDisplay = false;
  public boolean effectNotePermute = true;
  public boolean effectBeatTrain = false;
  public boolean effectBassPulse = true;
  
  // fire effects
  public boolean effectFireChase = true;
  public boolean effectFireDisplay = true;
  
  // final color correction params
  public color effectTint = color(255,255,255); // central hue and sat 
  public float effectChroma = 100;          // 100 means full range, 0 means monochromatic
  public float effectBright = 50;          // we add a lot of effects together; tend to clip if we aren't moderate here
  
  public Object clone()
  {
    try {  
      return super.clone();  
    } catch (CloneNotSupportedException e) { 
      throw new InternalError();  
    }  
  }
};

// The number of steps that pass before we change, for each position of the slider
int changeRatePeriods[] = {1, 4, 16, 32, 64, 128, 256, -1};
String changeRateLabels[] ={"change every step", "change every beat", "change every bar", "change every 2 bars", 
                            "change every 4 bars", "change every 8 bars", "change every 16 bars", "change never"};
int CHANGE_NEVER = 7;

// Effect settings min, max, and typical values. Used for mutating the effects.
// Min and max need to match touchOSC limits
// Normally the center ("typical") values for these settings would correspond to the default values
float ANIMATION_SPEED_MIN = 0;
float ANIMATION_SPEED_TYPICAL = 1;
float ANIMATION_SPEED_MAX = 10;
float PULSE_WIDTH_MIN = 0;
float PULSE_WIDTH_TYPICAL = 1;
float PULSE_WIDTH_MAX = 10;
float FLICKER_MIN = 0;
float FLICKER_TYPICAL = 0;
float FLICKER_MAX = 1;
float ATTACK_MIN = 0;
float ATTACK_TYPICAL = 1;
float ATTACK_MAX = 16;
float DECAY_MIN = 0;
float DECAY_TYPICAL = 3;
float DECAY_MAX = 16;
float HUE_ROTATE_MIN = 0;
float HUE_ROTATE_TYPICAL = 5;
float HUE_ROTATE_MAX = 150;
float HUE_SPREAD_MIN = 0;
float HUE_SPREAD_TYPICAL = 60;
float HUE_SPREAD_MAX = 120;
float HUE_SAT_MIN = 0;
float HUE_SAT_TYPICAL = 80;
float HUE_SAT_MAX = 100;
float HUE_BRIGHT_MIN = 0;
float HUE_BRIGHT_TYPICAL = 60;
float HUE_BRIGHT_MAX = 100;
float EFFECT_CHROMA_MIN = 0;
float EFFECT_CHROMA_TYPICAL = 80;
float EFFECT_CHROMA_MAX = 100;
float EFFECT_BRIGHT_MIN = 0;
float EFFECT_BRIGHT_TYPICAL = 50;
float EFFECT_BRIGHT_MAX = 100;


// Current FB state, and the state that we are interpolating to
FBParams curFBParams = new FBParams();
FBParams uiFBParams = new FBParams();

// ---------------------------------------------- OSC Translation functions ----------------------------------------
// To translate between internal values and OSC representations
// Each pair of functions needs to be inverses... or the touchOSC won't work

float baseHueSpeedOSCToInternal(float oscVal) {
  return pow(oscVal, 4) * 150;    //OSC control is unscaled 0..1. Add nonlinearity to widen lower end of the scale
}
float baseHueSpeedInternalToOSC(float internalVal) {
  return pow(internalVal/150, 0.25);
}

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

 println("FB OSC: " + m.addrPattern());
  
  if (m.addrPattern().startsWith("/lightControl/changeButton")) {
    events.fire("change");
  } 
  
  if (m.addrPattern().startsWith("/lightControl/changeRate")) {
    uiFBParams.changeRate = (int)clip( floor(m.get(0).floatValue()), 0, changeRatePeriods.length-1);
    sendTouchOSCMsg("/lightControl/changeRateLabel", changeRateLabels[uiFBParams.changeRate]);
  } 

  else if (m.addrPattern().startsWith("/lightControl/mutationRate")) {
    uiFBParams.mutationRate = m.get(0).floatValue();    
  } 
 
  else if (m.addrPattern().startsWith("/lightControl/changePatterns")) {
    uiFBParams.changeEffectPatterns = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/lightControl/changeSettings")) {
    uiFBParams.changeEffectSettings = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/lightControl/changeColors")) {
    uiFBParams.changeEffectColors = m.get(0).floatValue() != 0;    
  } 
  
  else if (m.addrPattern().startsWith("/lightPatterns/noteDisplay")) {
    uiFBParams.effectNoteDisplay = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/lightPatterns/notePermute")) {
    uiFBParams.effectNotePermute = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/lightPatterns/noteChase")) {
    uiFBParams.effectNoteChase = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/lightPatterns/beatTrain")) {
    uiFBParams.effectBeatTrain = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/lightPatterns/bassPulse")) {
    uiFBParams.effectBassPulse = m.get(0).floatValue() != 0;    
    println("uiFBParams.effectBassPulse: " + uiFBParams.effectBassPulse);
  } 
 
  else if (m.addrPattern().startsWith("/lightColor/baseHueSpeed")) {
    uiFBParams.baseHueRotationSpeed = baseHueSpeedOSCToInternal(m.get(0).floatValue());
  } 
  
  else if (m.addrPattern().startsWith("/lightColor/baseHueSpread")) {
    uiFBParams.baseHueSpread = m.get (0).floatValue();
  } 
  
  else if (m.addrPattern().startsWith("/lightColor/baseHueSaturation")) {
    uiFBParams.baseHueSat = m.get(0).floatValue() ;  
  } 
  
  else if (m.addrPattern().startsWith("/lightColor/baseHueBrightness")) {
    uiFBParams.baseHueBright = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightColor/tint")) {
    uiFBParams.effectTint = tintOSCToInternal(m.get(0).floatValue(), m.get(1).floatValue());
  } 
  
  else if (m.addrPattern().startsWith("/lightColor/chroma")) {
    uiFBParams.effectChroma = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightColor/brightness")) {
    uiFBParams.effectBright = m.get(0).floatValue();  
    println("uiFBParams.effectBrightness: " + uiFBParams.effectBright);
  } 
  
  else if (m.addrPattern().startsWith("/lightSettings/animationSpeed")) {
    uiFBParams.animationSpeed = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightSettings/pulseWidth")) {
    uiFBParams.pulseWidth = m.get(0).floatValue();  
  //println("pulseWidth:" + uiFBParams.pulseWidth);
  } 

  else if (m.addrPattern().startsWith("/lightSettings/attack")) {
    uiFBParams.attack = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightSettings/decay")) {
    uiFBParams.decay = m.get(0).floatValue();  
  } 

  else if (m.addrPattern().startsWith("/lightControl/fireChase")) {
    uiFBParams.effectFireChase = m.get(0).floatValue() != 0;    
    println("uiFBParams.effectFireChase: " + uiFBParams.effectFireChase);
  } 

  else if (m.addrPattern().startsWith("/lightControl/fireDisplay")) {
    uiFBParams.effectFireDisplay = m.get(0).floatValue() != 0;    
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

void sendTouchOSCMsg(String addr, String value) {
  OscMessage msg = new OscMessage(addr);
  msg.add(value);
  if ( OSCConnection_touchOSC.myRemoteLocation != null) { 
    OSCConnection_touchOSC.oscP5.send(msg, OSCConnection_touchOSC.myRemoteLocation);
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
    
  sendTouchOSCMsg("/lightControl/changeRate", uiFBParams.changeRate);
  sendTouchOSCMsg("/lightControl/mutationRate", uiFBParams.mutationRate);
  sendTouchOSCMsg("/lightControl/changeRateLabel", changeRateLabels[uiFBParams.changeRate]);
  sendTouchOSCMsg("/lightControl/changePatterns", uiFBParams.changeEffectPatterns);
  sendTouchOSCMsg("/lightControl/changeSettings", uiFBParams.changeEffectSettings);
  sendTouchOSCMsg("/lightControl/changeColors", uiFBParams.changeEffectColors);
    
  sendTouchOSCMsg("/lightPatterns/noteDisplay", uiFBParams.effectNoteDisplay);
  sendTouchOSCMsg("/lightPatterns/notePermute", uiFBParams.effectNotePermute);
  sendTouchOSCMsg("/lightPatterns/noteChase",   uiFBParams.effectNoteChase);
  sendTouchOSCMsg("/lightPatterns/beatTrain",  uiFBParams.effectBeatTrain);
  sendTouchOSCMsg("/lightPatterns/bassPulse",  uiFBParams.effectBassPulse);

  sendTouchOSCMsg("/lightColor/baseHueSpeed", baseHueSpeedInternalToOSC(fb.baseHueRotationSpeed));
  sendTouchOSCMsg("/lightColor/baseHueSpread", fb.baseHueSpread);
  sendTouchOSCMsg("/lightColor/baseHueSaturation", fb.baseHueSat);
  sendTouchOSCMsg("/lightColor/baseHueBrightness", fb.baseHueBright); 

  sendTouchOSCMsg2("/lightColor/tint", tintInternalToOSCx(uiFBParams.effectTint), tintInternalToOSCy(uiFBParams.effectTint));
  sendTouchOSCMsg("/lightColor/chroma", uiFBParams.effectChroma);
  sendTouchOSCMsg("/lightColor/brightness", uiFBParams.effectBright);
  
  sendTouchOSCMsg("/lightSettings/animationSpeed", uiFBParams.animationSpeed);
  sendTouchOSCMsg("/lightSettings/pulseWidth", uiFBParams.pulseWidth);
  sendTouchOSCMsg("/lightSettings/attack", uiFBParams.attack);
  sendTouchOSCMsg("/lightSettings/decay", uiFBParams.decay);
    
  sendTouchOSCMsg("/lightControl/fireChase",  uiFBParams.effectFireChase);
  sendTouchOSCMsg("/lightControl/fireDisplay",  uiFBParams.effectFireDisplay);
}

float ANIMATION_TIME = 8;  // time to converge to new parameter value, in steps

float animateParameter(float toVal, float fromVal, float steps) {
  return fromVal + steps/ANIMATION_TIME * (toVal-fromVal);
}

color animateParameter(color toVal, color fromVal, float steps) {
  return lerpColor(fromVal, toVal, steps/ANIMATION_TIME);
}

// Copy the current parameters from their UI values, animating the continuous parameters toward their UI values
// ? use "animationSpeed" to control the speed of the shift? 
void copyAndAnimateUIParams(FBParams uiFBParams, FBParams curFBParams, float steps) {

  //println("copyAndAnimateUIParams");
  
  curFBParams.changeRate = uiFBParams.changeRate;
  curFBParams.mutationRate = uiFBParams.mutationRate;
  curFBParams.changeEffectSettings = uiFBParams.changeEffectSettings;
  curFBParams.changeEffectColors = uiFBParams.changeEffectColors;
  
  curFBParams.animationSpeed = animateParameter(uiFBParams.animationSpeed, curFBParams.animationSpeed, steps);
  curFBParams.flicker = animateParameter(uiFBParams.flicker, curFBParams.flicker, steps);
  curFBParams.pulseWidth = animateParameter(uiFBParams.pulseWidth, curFBParams.pulseWidth, steps);
  curFBParams.attack = animateParameter(uiFBParams.attack, curFBParams.attack, steps);
  curFBParams.decay = animateParameter(uiFBParams.decay, curFBParams.decay, steps);

  curFBParams.baseHueRotationSpeed = animateParameter(uiFBParams.baseHueRotationSpeed, curFBParams.baseHueRotationSpeed, steps);
  curFBParams.baseHueSpread = animateParameter(uiFBParams.baseHueSpread, curFBParams.baseHueSpread, steps);
  curFBParams.baseHueSat = animateParameter(uiFBParams.baseHueSat, curFBParams.baseHueSat, steps);
  curFBParams.baseHueBright = animateParameter(uiFBParams.baseHueBright, curFBParams.baseHueBright, steps);

  curFBParams.effectNoteChase = uiFBParams.effectNoteChase;
  curFBParams.effectNoteDisplay = uiFBParams.effectNoteDisplay;
  curFBParams.effectNotePermute = uiFBParams.effectNotePermute;
  curFBParams.effectBeatTrain = uiFBParams.effectBeatTrain;
  curFBParams.effectBassPulse = uiFBParams.effectBassPulse;

  curFBParams.effectFireChase = uiFBParams.effectFireChase;
  curFBParams.effectFireDisplay = uiFBParams.effectFireDisplay;

  curFBParams.effectTint = animateParameter(uiFBParams.effectTint, curFBParams.effectTint, steps);
  curFBParams.effectChroma = animateParameter(uiFBParams.effectChroma, curFBParams.effectChroma, steps);
  curFBParams.effectBright =  animateParameter(uiFBParams.effectBright, curFBParams.effectBright, steps);  
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
    
    // start with UI params immediately on startup
    curFBParams = (FBParams)uiFBParams.clone();
    
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
    outputParamsToOSC(uiFBParams);
 }


  // Advance winds all the modules forward, plus changes modes / parameters at bar boundaries
  void advance(float steps) {
    // First, copy the current parameters from their UI values. Most are direct, some are animated towards the ui values as targets
    copyAndAnimateUIParams(uiFBParams, curFBParams, steps);
    
    // Advance each module
    baseHueRotate.masterAdvance(steps);
    
    noteChase.masterAdvance(steps);
    noteDisplay.masterAdvance(steps);
    notePermute.masterAdvance(steps);
    beatTrain.masterAdvance(steps);
    bassPulse.masterAdvance(steps);

    fireChase.masterAdvance(steps);
    fireDisplay.masterAdvance(steps);
    
    if (events.fired("bar"))
      outputParamsToOSC(uiFBParams);
      
    // change every N steps, as set by curFBParams.changeRate, or when we get the "change" event
    if ( (events.fired("step") && (uiFBParams.changeRate != CHANGE_NEVER) && ((totalSteps % changeRatePeriods[curFBParams.changeRate]) == 0)) ||
         events.fired("change") )  {
      change();
    }
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
//    println("Change!");
    
    println("curFBParams.changeEffectPatterns: " + curFBParams.changeEffectPatterns)
    
    if (curFBParams.changeEffectPatterns)
      changeWhichEffectsAreOn();
    
    if (curFBParams.changeEffectColors)
      changeEffectColors(uiFBParams);
      
    if (curFBParams.changeEffectSettings)
      changeEffectSettings(uiFBParams);
    
    outputParamsToOSC(uiFBParams);
  }

  boolean mutateMe() {
    return random(1) < curFBParams.mutationRate;
  }

  // Flips the on state of effects with specified mutation rate
  void changeWhichEffectsAreOn() {
            
    if (mutateMe()) uiFBParams.effectNoteDisplay = !curFBParams.effectNoteDisplay;
    if (mutateMe()) uiFBParams.effectNotePermute = !curFBParams.effectNotePermute;
    if (mutateMe()) uiFBParams.effectNoteChase = !curFBParams.effectNoteChase;
    if (mutateMe()) uiFBParams.effectBeatTrain = !curFBParams.effectBeatTrain;
    if (mutateMe()) uiFBParams.effectBassPulse = !curFBParams.effectBassPulse;
    
    if (mutateMe()) uiFBParams.effectFireChase = !curFBParams.effectFireChase;
    if (mutateMe()) uiFBParams.effectFireDisplay = !curFBParams.effectFireDisplay;    
  }
  
  void changeEffectColors(FBParams fb) {
    // Rotate effect chroma, animate...
    if (mutateMe()) fb.baseHueRotationSpeed = skewedRandom(ANIMATION_SPEED_MIN, ANIMATION_SPEED_TYPICAL, ANIMATION_SPEED_MAX);
    if (mutateMe()) fb.baseHueSpread = skewedRandom(HUE_SPREAD_MIN, HUE_SPREAD_TYPICAL, HUE_SPREAD_MAX);
    if (mutateMe()) fb.baseHueSat = skewedRandom(HUE_SAT_MIN, HUE_SAT_TYPICAL, HUE_SAT_MAX);
    if (mutateMe()) fb.baseHueBright = skewedRandom(HUE_BRIGHT_MIN, HUE_BRIGHT_TYPICAL, HUE_BRIGHT_MAX);
    if (mutateMe()) fb.effectChroma = skewedRandom(EFFECT_CHROMA_MIN, EFFECT_CHROMA_TYPICAL, EFFECT_CHROMA_MAX);
    if (mutateMe()) fb.effectBright = skewedRandom(EFFECT_BRIGHT_MIN, EFFECT_BRIGHT_TYPICAL, EFFECT_BRIGHT_MAX);
   
    // Now pick a tint color. Choose from a range opposite the current hue, saturation from a skewed distribution
    if (mutateMe()) {
       colorMode(HSB,360,100,100);

       float h = baseHueRotate.phase - fb.baseHueSpread + random(2*fb.baseHueSpread);  // choose around color opposing center of base hue spread
       float sat =  skewedRandom(EFFECT_CHROMA_MIN, EFFECT_CHROMA_TYPICAL, EFFECT_CHROMA_MAX);
       fb.effectTint = color(h % 360, sat, 100);  // brightness ignored

       colorMode(RGB, 255);
    } 
  }
  
  // Change settings just by picking new random numbers
  void changeEffectSettings(FBParams fb) {
    //println("totally changing those settings...");
    
    if (mutateMe()) fb.animationSpeed = skewedRandom(ANIMATION_SPEED_MIN, ANIMATION_SPEED_TYPICAL, ANIMATION_SPEED_MAX);
    if (mutateMe()) fb.pulseWidth = skewedRandom(PULSE_WIDTH_MIN, PULSE_WIDTH_TYPICAL, PULSE_WIDTH_MAX);
    if (mutateMe()) fb.flicker = skewedRandom(FLICKER_MIN, FLICKER_TYPICAL, FLICKER_MAX);
    if (mutateMe()) fb.attack = skewedRandom(ATTACK_MIN, ATTACK_TYPICAL, ATTACK_MAX);
    if (mutateMe()) fb.decay = skewedRandom(DECAY_MIN, DECAY_TYPICAL, DECAY_MAX);
  }
    
} // FrameBrulee


// Returns random from mn to mx with peak of the distribution at typical
// Algorithm: start with a uniform random, then compress the range on each side of typical by raising it to a power
float skewedRandom(float mn, float typical, float mx) {
  float SHARPNESS = 3;
  
  float r = random(mx - mn) +  mn;
  float s;
  
  if (r < typical) {
    s = (r-mn) / (typical-mn); // rescale region smaller than typical to 0..1
    s = 1-pow(1-s, SHARPNESS);
    s = mn + s*(typical-mn);    // rescale back
  } else {
    s = (mx - r) / (mx - typical); // rescale region larger than typical 0..1
    s = pow(s, SHARPNESS);
    s = typical + s*(mx - typical);  // rescale back
  }
  return s;
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


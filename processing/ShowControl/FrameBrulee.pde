/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

// FrameBrulee
// A lighting and fire control program for Syzygryd, using the Layer interface
// Jonathan Stray, August 2010

// ------------------------------------------------- FrameBrulee parameter block  --------------------------------------
// These are all the parameters of a FrameBrulee program. 
// Can be saved/restored. Some are controllable via OSC.
// Individual modules know how to configure their own parameters from the global state.
// The defaults are also here.


// Per-arm paramters
class FBArmParams implements Cloneable {
  // effect settings
  public float animationSpeed = 1;      // relative to steps
  public float pulseWidth = 1;            // number of cubes that a single pulse lights up
  public float attack = 1;              // how fast does stuff come on? steps
  public float decay = 5;               // how fast dues stuff go off? steps  

  // effects on/off. These are switched up during change()
  public boolean effectNoteChase = false;
  public boolean effectNoteDisplay = false;
  public boolean effectNotePermute = true;
  public boolean effectBeatTrain = false;
  public boolean effectBassPulse = true;
  
  // fire effects
  public boolean effectFireChase = false;
  public boolean effectFireDisplay = false;
  
  // color correction params
  public color effectTint = color(255,255,255); // central hue and sat 
  public float effectChroma = 100;          // 100 means full range, 0 means monochromatic
  public float effectBright = 50;          // we add a lot of effects together; tend to clip if we aren't moderate here
}

class FBParams implements Cloneable {
  public int   changeRate = 4;          // indexes changeRatePeriod array, index 4 = every 64 steps = every 4 bars
  public boolean hold = false;          // if true, never change
  public float mutationRate = 0.2;            // 1 = change everything when mutating, 0 = change nothing
  public boolean changeEffectSettings = true;
  public boolean changeEffectColors = true;
  public boolean changeEffectPatterns = true;
  
  public float flicker = 0.1;            // general unpredictability of positions and timing
  
  // hue rotation controls
  public float baseHueRotationSpeed = 1; // degrees/sec
  public float baseHueSpread = 60;       // degrees lead/lag
  public float baseHueSat = 80;          // out of 100
  public float baseHueBright = 60;       // out of 100
  
  public FBArmParams[] arms;
    
  // Manually controlled fire effects ("FIRE!" panel)
  public boolean  manualFireRepeat = false;          // repeat button on 
  public int manualFirePatternIndex = -1;            // -1 means all off
  public int manualFireSpeed = FIRE_SPEED_STEP;      //  used as an index ala changeRate
  public float manualFireDecay = 1;                  // steps

  FBParams() {
    arms = new FBArmParams[3];
    for (int i=0; i<3; i++) { 
      arms[i] = new FBArmParams();
    }
    //println("made new arms!");
  }
  
  public Object clone() {  
    try {  
       return super.clone();  
    } catch (CloneNotSupportedException e) { 
      throw new InternalError();  
    }
  }
  
}

// The number of steps that pass before we change, for each position of the slider
int changeRatePeriods[] = {1, 4, 16, 32, 64, 128, 256, -1};
String changeRateLabels[] ={"change every step", "change every beat", "change every bar", "change every 2 bars", 
                            "change every 4 bars", "change every 8 bars", "change every 16 bars", "change never"};
int CHANGE_NEVER = 7;

// A similar index into timings for manual fire pattern speed. In effects per step 
float manualFireSpeeds[] = {1/4.0, 1/2.0, 1, 2, 4, 8, 16};
int FIRE_SPEED_STEP = 2; // index into the fireSpeeds array for 1.0 steps

// OSC addresses of the different manual fire patterns
String manualFirePatternOSCAddr[] = {"/manualFire/patternSerial", "/manualFire/patternParallel", "/manualFire/patternSpiral", "/manualFire/patternAll"};

// Effect settings min, max, and typical values. Used for mutating the effects.
// Min and max need to match touchOSC limits
// Normally the center ("typical") values for these settings would correspond to the default values
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
float ANIMATION_SPEED_MIN = 0.1;
float ANIMATION_SPEED_TYPICAL = 1;
float ANIMATION_SPEED_MAX = 10;
float PULSE_WIDTH_MIN = 1;
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
  
  if (m.addrPattern().startsWith("/lightControl/hold")) {
    uiFBParams.hold = m.get(0).floatValue() != 0;
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

  else if (m.addrPattern().startsWith("/manualFire/patternRepeat")) {
    uiFBParams.manualFireRepeat = m.get(0).floatValue() != 0;  
  } 
  
  else if (m.addrPattern().startsWith("/manualFire/patternSpeed")) {
    uiFBParams.manualFireSpeed = floor(clip(m.get(0).floatValue(), 0, manualFireSpeeds.length-1));  
  }
  
  else if (m.addrPattern().startsWith("/manualFire/patternDecay")) {
    uiFBParams.manualFireDecay = m.get(0).floatValue();  
  } 
  
  // Receive manual fire pattern button events
  // if repeat is off, trigger an event and immediately disable the button
  // else toggle, and radio-button the rest 
  for (int i=0; i<manualFirePatternOSCAddr.length; i++) {
    if (m.addrPattern().startsWith(manualFirePatternOSCAddr[i])) {
      
      if (m.get(0).floatValue() != 0) {           // if the button turned on...
      
        if (!uiFBParams.manualFireRepeat) {
          events.fire("manualFirePattern" + i);   // when repeat is off, fire a single pattern and turn off button immediately 
          sendTouchOSCMsg(manualFirePatternOSCAddr[i], false);
        } else {
          uiFBParams.manualFirePatternIndex = i;  // when repeat is on, turn off all other buttons (as only one can be active at once)
          updateTouchOSCRadioButtons(manualFirePatternOSCAddr, i);
        }
        
      } else {
        if (i == uiFBParams.manualFirePatternIndex)  // if the button turned off, and it was selected, then we are no longer firing a pattern
          uiFBParams.manualFirePatternIndex = -1;
      }  
    }
  }
  
  for (int arm=0; arm<3; arm++) {
    String armStr = "/arm" + arm + "/";
    
    if (m.addrPattern().startsWith(armStr + "noteDisplay")) {
      uiFBParams.arms[arm].effectNoteDisplay = m.get(0).floatValue() != 0;    
    } 

    if (m.addrPattern().startsWith(armStr + "notePermute")) {
      uiFBParams.arms[arm].effectNotePermute = m.get(0).floatValue() != 0;    
    } 

    if (m.addrPattern().startsWith(armStr + "noteChase")) {
      uiFBParams.arms[arm].effectNoteChase = m.get(0).floatValue() != 0;    
    } 

    if (m.addrPattern().startsWith(armStr + "beatTrain")) {
      uiFBParams.arms[arm].effectBeatTrain = m.get(0).floatValue() != 0;    
    } 

    if (m.addrPattern().startsWith(armStr + "bassPulse")) {
      uiFBParams.arms[arm].effectBassPulse = m.get(0).floatValue() != 0;    
    } 

    if (m.addrPattern().startsWith(armStr + "fireDisplay")) {
      uiFBParams.arms[arm].effectFireDisplay = m.get(0).floatValue() != 0;    
    } 

    if (m.addrPattern().startsWith(armStr + "fireChase")) {
      uiFBParams.arms[arm].effectFireChase = m.get(0).floatValue() != 0;    
    } 

    else if (m.addrPattern().startsWith(armStr + "effectTint")) {
      uiFBParams.arms[arm].effectTint = tintOSCToInternal(m.get(0).floatValue(), m.get(1).floatValue());
    } 
    
    else if (m.addrPattern().startsWith(armStr + "effectChroma")) {
      uiFBParams.arms[arm].effectChroma = m.get(0).floatValue();  
    } 
  
    else if (m.addrPattern().startsWith(armStr + "effectBright")) {
      uiFBParams.arms[arm].effectBright = m.get(0).floatValue();  
    } 

    if (m.addrPattern().startsWith(armStr + "animationSpeed")) {
      uiFBParams.arms[arm].animationSpeed = m.get(0).floatValue();    
    } 

    if (m.addrPattern().startsWith(armStr + "pulseWidth")) {
      uiFBParams.arms[arm].pulseWidth = m.get(0).floatValue();    
    } 

    if (m.addrPattern().startsWith(armStr + "attack")) {
      uiFBParams.arms[arm].attack = m.get(0).floatValue();    
    } 

    if (m.addrPattern().startsWith(armStr + "decay")) {
      uiFBParams.arms[arm].decay = m.get(0).floatValue();    
    } 
    
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

void updateTouchOSCRadioButtons(String addrs[], int selected) {
  for (int i=0; i<addrs.length; i++) {
    if (i == selected) {
      sendTouchOSCMsg(addrs[i], true); 
    } else {
      sendTouchOSCMsg(addrs[i], false); 
    }
  }
}

void outputParamsToOSC(FBParams fb) {
    
  sendTouchOSCMsg("/lightControl/changeRate", uiFBParams.changeRate);
  sendTouchOSCMsg("/lightControl/hold", uiFBParams.hold);
  sendTouchOSCMsg("/lightControl/mutationRate", uiFBParams.mutationRate);
  sendTouchOSCMsg("/lightControl/changeRateLabel", changeRateLabels[uiFBParams.changeRate]);
  sendTouchOSCMsg("/lightControl/changePatterns", uiFBParams.changeEffectPatterns);
  sendTouchOSCMsg("/lightControl/changeSettings", uiFBParams.changeEffectSettings);
  sendTouchOSCMsg("/lightControl/changeColors", uiFBParams.changeEffectColors);

  sendTouchOSCMsg("/lightColor/baseHueSpeed", baseHueSpeedInternalToOSC(fb.baseHueRotationSpeed));
  sendTouchOSCMsg("/lightColor/baseHueSpread", fb.baseHueSpread);
  sendTouchOSCMsg("/lightColor/baseHueSaturation", fb.baseHueSat);
  sendTouchOSCMsg("/lightColor/baseHueBrightness", fb.baseHueBright); 

  sendTouchOSCMsg("/fireControl/patternRepeat", uiFBParams.manualFireRepeat);
  sendTouchOSCMsg("/fireControl/patternSpeed", uiFBParams.manualFireSpeed);
  sendTouchOSCMsg("/fireControl/patternDecay", uiFBParams.manualFireDecay);  
  updateTouchOSCRadioButtons(manualFirePatternOSCAddr, uiFBParams.manualFirePatternIndex);  // if -1, turns all off

  for (int arm=0; arm<3; arm++) {    
    String armStr = "/arm" + arm + "/";
    
    sendTouchOSCMsg(armStr + "noteDisplay", uiFBParams.arms[arm].effectNoteDisplay);
    sendTouchOSCMsg(armStr + "notePermute", uiFBParams.arms[arm].effectNotePermute);
    sendTouchOSCMsg(armStr + "noteChase",   uiFBParams.arms[arm].effectNoteChase);
    sendTouchOSCMsg(armStr + "beatTrain",  uiFBParams.arms[arm].effectBeatTrain);
    sendTouchOSCMsg(armStr + "bassPulse",  uiFBParams.arms[arm].effectBassPulse);

    sendTouchOSCMsg(armStr + "fireDisplay", uiFBParams.arms[arm].effectFireDisplay);
    sendTouchOSCMsg(armStr + "fireChase",   uiFBParams.arms[arm].effectFireChase);

    sendTouchOSCMsg2(armStr + "effectTint", tintInternalToOSCx(uiFBParams.arms[arm].effectTint), tintInternalToOSCy(uiFBParams.arms[arm].effectTint));
    sendTouchOSCMsg(armStr + "effectChroma", uiFBParams.arms[arm].effectChroma); 
    sendTouchOSCMsg(armStr + "effectBright", uiFBParams.arms[arm].effectBright);

    sendTouchOSCMsg(armStr + "animationSpeed", uiFBParams.arms[arm].animationSpeed);
    sendTouchOSCMsg(armStr + "pulseWidth", uiFBParams.arms[arm].pulseWidth);
    sendTouchOSCMsg(armStr + "attack", uiFBParams.arms[arm].attack);
    sendTouchOSCMsg(armStr + "decay", uiFBParams.arms[arm].decay);
  }
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
  curFBParams.hold = uiFBParams.hold;
  curFBParams.mutationRate = uiFBParams.mutationRate;
  curFBParams.changeEffectPatterns = uiFBParams.changeEffectPatterns;
  curFBParams.changeEffectSettings = uiFBParams.changeEffectSettings;
  curFBParams.changeEffectColors = uiFBParams.changeEffectColors;

  curFBParams.flicker = animateParameter(uiFBParams.flicker, curFBParams.flicker, steps);
  
  curFBParams.baseHueRotationSpeed = animateParameter(uiFBParams.baseHueRotationSpeed, curFBParams.baseHueRotationSpeed, steps);
  curFBParams.baseHueSpread = animateParameter(uiFBParams.baseHueSpread, curFBParams.baseHueSpread, steps);
  curFBParams.baseHueSat = animateParameter(uiFBParams.baseHueSat, curFBParams.baseHueSat, steps);
  curFBParams.baseHueBright = animateParameter(uiFBParams.baseHueBright, curFBParams.baseHueBright, steps);

  curFBParams.manualFireRepeat = uiFBParams.manualFireRepeat;
  curFBParams.manualFireSpeed = uiFBParams.manualFireSpeed;    // express as float so it animates smoothly?
  curFBParams.manualFireDecay = animateParameter(uiFBParams.manualFireDecay, curFBParams.manualFireDecay, steps);  
  curFBParams.manualFirePatternIndex = uiFBParams.manualFirePatternIndex;
 
  for (int arm=0; arm<3; arm++) {
    curFBParams.arms[arm].effectNoteDisplay = uiFBParams.arms[arm].effectNoteDisplay;
    curFBParams.arms[arm].effectNotePermute = uiFBParams.arms[arm].effectNotePermute;
    curFBParams.arms[arm].effectNoteChase = uiFBParams.arms[arm].effectNoteChase;
    curFBParams.arms[arm].effectBeatTrain = uiFBParams.arms[arm].effectBeatTrain;
    curFBParams.arms[arm].effectBassPulse = uiFBParams.arms[arm].effectBassPulse;

    curFBParams.arms[arm].effectFireDisplay = uiFBParams.arms[arm].effectFireDisplay;
    curFBParams.arms[arm].effectFireChase = uiFBParams.arms[arm].effectFireChase;
  
    curFBParams.arms[arm].animationSpeed = animateParameter(uiFBParams.arms[arm].animationSpeed, curFBParams.arms[arm].animationSpeed, steps);
    curFBParams.arms[arm].pulseWidth = animateParameter(uiFBParams.arms[arm].pulseWidth, curFBParams.arms[arm].pulseWidth, steps);
    curFBParams.arms[arm].attack = animateParameter(uiFBParams.arms[arm].attack, curFBParams.arms[arm].attack, steps);
    curFBParams.arms[arm].decay = animateParameter(uiFBParams.arms[arm].decay, curFBParams.arms[arm].decay, steps);
    
    curFBParams.arms[arm].effectTint = animateParameter(uiFBParams.arms[arm].effectTint, curFBParams.arms[arm].effectTint, steps);
    curFBParams.arms[arm].effectChroma = animateParameter(uiFBParams.arms[arm].effectChroma, curFBParams.arms[arm].effectChroma, steps);
    curFBParams.arms[arm].effectBright =  animateParameter(uiFBParams.arms[arm].effectBright, curFBParams.arms[arm].effectBright, steps);  
  }
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
  ManualFireModule manualFire;
  
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
    manualFire = new ManualFireModule(curFBParams);
    
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
    manualFire.masterAdvance(steps);
    
    if (events.fired("bar"))
      outputParamsToOSC(uiFBParams);
      
    // change every N steps, as set by curFBParams.changeRate, or when we get the "change" event
    if ( (events.fired("step") && (uiFBParams.changeRate != CHANGE_NEVER) && (!uiFBParams.hold) && ((totalSteps % changeRatePeriods[curFBParams.changeRate]) == 0)) ||
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
    noteChase.apply(effectsLayers);
    noteDisplay.apply(effectsLayers);
    notePermute.apply(effectsLayers);
    beatTrain.apply(effectsLayers);
    bassPulse.apply(effectsLayers);

    // tint the effects and add to the base hue rotate
    tinty.apply(effectsLayers);
    state.blendOverSelf(effectsLayers, ADD, 1);
    
    // add the fire!
    fireChase.apply(state);
    fireDisplay.apply(state);
    manualFire.apply(state);
  }

  // turn on different modules, switch up parameters
  void change() {
//    println("Change!");
//    println("curFBParams.changeEffectPatterns: " + curFBParams.changeEffectPatterns);
    
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

//    println(curFBParams.changeRate);
//    println(curFBParams.arms[0].effectNoteDisplay);
    
    for (int panel=0; panel<3; panel++) {    
      if (mutateMe()) uiFBParams.arms[panel].effectNoteDisplay = !curFBParams.arms[panel].effectNoteDisplay;
      if (mutateMe()) uiFBParams.arms[panel].effectNotePermute = !curFBParams.arms[panel].effectNotePermute;
      if (mutateMe()) uiFBParams.arms[panel].effectNoteChase = !curFBParams.arms[panel].effectNoteChase;
      if (mutateMe()) uiFBParams.arms[panel].effectBeatTrain = !curFBParams.arms[panel].effectBeatTrain;
      if (mutateMe()) uiFBParams.arms[panel].effectBassPulse = !curFBParams.arms[panel].effectBassPulse;

//      if (mutateMe()) uiFBParams.arms[panel].effectFireChase = !curFBParams.arms[panel].effectFireChase;
//      if (mutateMe()) uiFBParams.arms[panel].effectFireDisplay = !curFBParams.arms[panel].effectFireDisplay;    
    }
    
  }
  
  void changeEffectColors(FBParams fb) {
    
    if (mutateMe()) fb.baseHueRotationSpeed = skewedRandom(ANIMATION_SPEED_MIN, ANIMATION_SPEED_TYPICAL, ANIMATION_SPEED_MAX);
    if (mutateMe()) fb.baseHueSpread = skewedRandom(HUE_SPREAD_MIN, HUE_SPREAD_TYPICAL, HUE_SPREAD_MAX);
    if (mutateMe()) fb.baseHueSat = skewedRandom(HUE_SAT_MIN, HUE_SAT_TYPICAL, HUE_SAT_MAX);
    if (mutateMe()) fb.baseHueBright = skewedRandom(HUE_BRIGHT_MIN, HUE_BRIGHT_TYPICAL, HUE_BRIGHT_MAX);

    for (int panel=0; panel<3; panel++) {    
      // Rotate effect chroma, animate...
      if (mutateMe()) fb.arms[panel].effectChroma = skewedRandom(EFFECT_CHROMA_MIN, EFFECT_CHROMA_TYPICAL, EFFECT_CHROMA_MAX);
      if (mutateMe()) fb.arms[panel].effectBright = skewedRandom(EFFECT_BRIGHT_MIN, EFFECT_BRIGHT_TYPICAL, EFFECT_BRIGHT_MAX);
     
      // Now pick a tint color. Choose from a range opposite the current hue, saturation from a skewed distribution
      if (mutateMe()) {
         colorMode(HSB,360,100,100);
  
         float h = baseHueRotate.phase - fb.baseHueSpread + random(2*fb.baseHueSpread);  // choose around color opposing center of base hue spread
         float sat =  skewedRandom(EFFECT_CHROMA_MIN, EFFECT_CHROMA_TYPICAL, EFFECT_CHROMA_MAX);
         fb.arms[panel].effectTint = color(h % 360, sat, 100);  // brightness ignored
  
         colorMode(RGB, 255);
      } 
    }
  }
  
  // Change settings just by picking new random numbers
  void changeEffectSettings(FBParams fb) {
    //println("totally changing those settings...");
    if (mutateMe()) fb.flicker = skewedRandom(FLICKER_MIN, FLICKER_TYPICAL, FLICKER_MAX);
    
    for (int panel=0; panel<3; panel++) {    
      if (mutateMe()) fb.arms[panel].animationSpeed = skewedRandom(ANIMATION_SPEED_MIN, ANIMATION_SPEED_TYPICAL, ANIMATION_SPEED_MAX);
      if (mutateMe()) fb.arms[panel].pulseWidth = skewedRandom(PULSE_WIDTH_MIN, PULSE_WIDTH_TYPICAL, PULSE_WIDTH_MAX);
      if (mutateMe()) fb.arms[panel].attack = skewedRandom(ATTACK_MIN, ATTACK_TYPICAL, ATTACK_MAX);
      if (mutateMe()) fb.arms[panel].decay = skewedRandom(DECAY_MIN, DECAY_TYPICAL, DECAY_MAX);
    }
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


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

  // effects on/off. These are switched up during change()
  public boolean effectNoteChase = false;
  public boolean effectNoteDisplay = true;
  public boolean effectNotePermute = false;
  public boolean effectBeatTrain = false;
  public boolean effectBassPulse = true;
  
  // fire effects
  public boolean effectFireChase = false;
  public boolean effectFireDisplay = false;
  
  // color correction params
  public color effectTint = color(255,255,255); // central hue and sat 
  public float effectChroma = 100;          // 100 means full range, 0 means monochromatic
  public float effectBright = 90;
}

class FBParams implements Cloneable {
  public int   changeRate = 4;            // indexes changeRatePeriod array, index 4 = every 64 steps = every 4 bars
  public boolean autoChange = false;      // if true, never change
  public float mutationRate = 0.2;        // 1 = change everything when mutating, 0 = change nothing
  public boolean changeEffectSettings = true;
  public boolean changeEffectColors = true;
  public boolean changeEffectPatterns = true;
  public boolean changeFirePatterns = true;
  
  public float flicker = 0.1;            // general unpredictability of positions and timing
  
  // hue rotation controls
  public float baseHueRotationSpeed = 1; // degrees/sec
  public float baseHueSpread = 60;       // degrees lead/lag
  public float baseHueSat = 80;          // out of 100
  public float baseHueBright = 40;       // out of 100

  // note display settings
  public float pulseWidth = 1;            // number of cubes that a single pulse lights up
  public float permuteAcrossArms = 0;     // probability that a note display will be jittered across arms
  
  // final color correction params
  public color ccTint = color(255,255,255); // central hue and sat 
  public float ccChroma = 1.0;          // 1.0 means full range, 0 means monochromatic
  public float ccBrightness = 0.6;      // we add a lot of effects together; tend to clip if we don't do this
};

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
float HUE_BRIGHT_TYPICAL = 40;
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
float EFFECT_BRIGHT_TYPICAL = 90;
float EFFECT_BRIGHT_MAX = 100;


// Current FB state, and the state that we are interpolating to
FBParams curFBParams = new FBParams();


// OSC receiver function that modifies the global state 
// Also does OSC control ranges
void processOSCLightEvent(OscMessage m) {

// println(m.addrPattern());
  
  if (m.addrPattern().startsWith("/lightingColor/baseHueSpeed")) {
  
    curFBParams. baseHueRotationSpeed = pow(m.get(0).floatValue(), 4) * 150;    //OSC control is unscaled 0..1. Add nonlinearity to widen lower end of the scale
   // println("speed");
  } 
  
  if (m.addrPattern().startsWith("/lightControl/autoChange")) {
    uiFBParams.autoChange = m.get(0).floatValue() != 0;
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
  
  else if (m.addrPattern().startsWith("/lightControl/changeFire")) {
    uiFBParams.changeFirePatterns = m.get(0).floatValue() != 0;    
  } 

  else if (m.addrPattern().startsWith("/lightControl/changeColors")) {
    uiFBParams.changeEffectColors = m.get(0).floatValue() != 0;    
  } 
 
  else if (m.addrPattern().startsWith("/lightColor/baseHueSpeed")) {
    uiFBParams.baseHueRotationSpeed = baseHueSpeedOSCToInternal(m.get(0).floatValue());
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

// Used only for sending arm hue to the controller, hence built for int since we send ARGB colors 
void sendControllerOSCMsg(String addr, Integer val0, Integer val1, Integer val2) {
  OscMessage msg = new OscMessage(addr);
  msg.add(val0);
  msg.add(val1);
  msg.add(val2);
  if ( OSCConnection.myRemoteLocation != null) { 
    OSCConnection.oscP5.send(msg, OSCConnection.myRemoteLocation);
  }
}

void outputParamsToOSC(FBParams fb) {
    
  sendTouchOSCMsg("/lightControl/changeRate", uiFBParams.changeRate);
  sendTouchOSCMsg("/lightControl/autoChange", uiFBParams.autoChange);
  sendTouchOSCMsg("/lightControl/mutationRate", uiFBParams.mutationRate);
  sendTouchOSCMsg("/lightControl/changeRateLabel", changeRateLabels[uiFBParams.changeRate]);
  sendTouchOSCMsg("/lightControl/changePatterns", uiFBParams.changeEffectPatterns);
  sendTouchOSCMsg("/lightControl/changeSettings", uiFBParams.changeEffectSettings);
  sendTouchOSCMsg("/lightControl/changeColors", uiFBParams.changeEffectColors);
  sendTouchOSCMsg("/lightControl/changeFirePatterns", uiFBParams.changeFirePatterns);

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
  curFBParams.autoChange = uiFBParams.autoChange;
  curFBParams.mutationRate = uiFBParams.mutationRate;
  curFBParams.changeEffectPatterns = uiFBParams.changeEffectPatterns;
  curFBParams.changeEffectSettings = uiFBParams.changeEffectSettings;
  curFBParams.changeEffectColors = uiFBParams.changeEffectColors;
  curFBParams.changeFirePatterns = uiFBParams.changeFirePatterns;

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
    
    effectsLayers = new LightingState();
    
//    change();
    outputParamsToOSC(uiFBParams);
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
      
    // change every N steps, as set by curFBParams.changeRate, or when we get the "change" event
    if ( (events.fired("step") && (uiFBParams.changeRate != CHANGE_NEVER) && (uiFBParams.autoChange) && ((totalSteps % changeRatePeriods[curFBParams.changeRate]) == 0)) ||
         events.fired("change") )  {
      change();
    }
    
    // Update the panel colors once per step
    if (events.fired("step")) {
      colorMode(HSB, 360, 100, 100);
      color clr0 = color(baseHueRotate.getArmHue(0), 100, 100);
      color clr1 = color(baseHueRotate.getArmHue(1), 100, 100);
      color clr2 = color(baseHueRotate.getArmHue(2), 100, 100);      
      sendControllerOSCMsg("/color", clr0, clr1, clr2);
      colorMode(RGB, 255);
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
    
    if (curFBParams.changeEffectPatterns)
      changeWhichEffectsAreOn();
    
    if (curFBParams.changeEffectColors)
      changeEffectColors(uiFBParams);
      
    if (curFBParams.changeEffectSettings)
      changeEffectSettings(uiFBParams);
      
    if (curFBParams.changeFirePatterns)
      changeFirePatterns(uiFBParams);
    
    outputParamsToOSC(uiFBParams);
  }

    int[] permute = new int[lightModules.size()];
    for (int i=0; i<permute.length; i++)
      permute[i] = i;
    randomPermute(permute, random(1));
    ArrayList<FBModule> newstack = new ArrayList();
    for (int i=0; i<permute.length; i++)
       newstack.add(lightModules.get(permute[i]));
    lightModules = newstack; 
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
    }
  }
  
  void changeFirePatterns(FBParams fb) {
    for (int panel=0; panel<3; panel++) {        
      if (mutateMe()) uiFBParams.arms[panel].effectFireChase = !curFBParams.arms[panel].effectFireChase;
      if (mutateMe()) uiFBParams.arms[panel].effectFireDisplay = !curFBParams.arms[panel].effectFireDisplay; 
    }
  }
  
  void changeEffectColors(FBParams fb) {
    
    if (mutateMe()) fb.baseHueRotationSpeed = skewedRandom(ANIMATION_SPEED_MIN, ANIMATION_SPEED_TYPICAL, ANIMATION_SPEED_MAX);
    if (mutateMe()) fb.baseHueSpread = skewedRandom(HUE_SPREAD_MIN, HUE_SPREAD_TYPICAL, HUE_SPREAD_MAX);
    if (mutateMe()) fb.baseHueSat = skewedRandom(HUE_SAT_MIN, HUE_SAT_TYPICAL, HUE_SAT_MAX);
    if (mutateMe()) fb.baseHueBright = skewedRandom(HUE_BRIGHT_MIN, HUE_BRIGHT_TYPICAL, HUE_BRIGHT_MAX);

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



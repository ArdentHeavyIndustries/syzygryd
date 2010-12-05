// ------------------------------------------------- Modules for FrameBrulee -----------------------------------------
// An FBModule is a Layer with some parameters, which it can set from an FBParams block.
// It is sensitive to intensity and change messages, and knows how to fade in and out

abstract class FBModule extends Layer {
  
  boolean active;    // fading or running
  FBParams fb;
  
  FBModule(FBParams _fb) {
    fb = _fb;
    active = true;
  }
  
  void setParams(FBParams _fb) {
    fb = _fb;
  }
    
  // we hit a bar or the operator pressed a button or something... change up the parameters
  // howMuch is from 0..1, see constants below
  void mutate(float howMuch) {
  }
}

// Size of changes
float MUTATE_BEAT = 0.1;
float MUTATE_BAR = 0.25;
float MUTATE_4BAR = 0.5;
float MUTATE_SET = 1.0;


//------------------------------------------------- HueRotateModule -----------------------------------------
// Cycles hues across arms. Always 120 degrees apart, using saturation, brightness, and initial phase of baseColor

class HueRotateModule extends FBModule {

  float phase;
  
  HueRotateModule(FBParams _fb) {
    super(_fb);
    phase = 0;
  }

  void advance(float steps) {
    phase += steps*fb.baseHueRotationSpeed;
  }
  
  void apply(LightingState dst)
  {
    LightingState state = new LightingState();

    colorMode(HSB,360,100,100);
    state.fillArm(0, color(phase % 360, fb.baseHueSat, fb.baseHueBright));
    state.fillArm(1, color((phase + fb.baseHueSpread) % 360, fb.baseHueSat, fb.baseHueBright));
    state.fillArm(2, color((phase - fb.baseHueSpread) % 360, fb.baseHueSat, fb.baseHueBright));
    colorMode(RGB, 255);
    
    dst.blendOverSelf(state, blendMode, opacity);    
  }
  
}

//------------------------------------------------- TransientLayerModule -----------------------------------------
// TransientLayerModule is a BruleeModule that maintains a bunch of layers that animate on their own. Useful for e.g. note displays

class TransientLayerModule extends FBModule {
  
  TransientLayerModule(FBParams _fb) {
    super(_fb);
  }
  
  ArrayList<Layer> myLayers = new ArrayList();
  
  void apply(LightingState state) {    
    for (int i=0; i<myLayers.size(); i++) {
      Layer l = myLayers.get(i);
      
      if (!l.finished()) {
        l.apply(state);
      } else {
        myLayers.remove(i);
        i--;
      }
    }
  }
 
  // over-ride update() with something that creates layers, then call super.update() to move all layers forward in time 
  void advance(float elapsedTime) {
    for (Layer layer : myLayers) {
      if (!layer.finished()) {
        layer.masterAdvance(elapsedTime);
      } 
    }
  }
  
}

//------------------------------------------------- NoteDisplays -----------------------------------------

// Some textures
color[] CMYPulseTexture = new color[] {color(150, 150, 00), color(150, 0, 150), color(0, 150, 150)}; // simple lighting "pulse" for chase layers 
color[] whitePulseTexture = new color[] {color(100, 100, 100), color(200, 200, 200), color(100, 100, 100)};  

// Note chase sends a pulse down the arm for each step where a note is on
// Parameters used: 
//   - FBParams.intensity controls how often we can fire (every bar --> every note)
//   - FBParams.flicker controls whether we fire predictably (for current intensity level) or probabilistically 
//   - FBParams.animationSpeed to set the speed of (newly created, not pre-existing) chases
//   - FBParams.width to set the chase width
class NoteChaseModule extends TransientLayerModule {

  NoteChaseModule(FBParams _fb) {
    super(_fb);
  }
  
  void advance(float elapsed) {
    super.advance(elapsed);
        
    for (int panel=0; panel<3; panel++) {
   
      // generate new chase if 
      // - chase is enabled for this arm
      // - we've hit a step with notes
      // we're on a bar boundary
      if ( fb.arms[panel].effectNoteChase && 
           (events.fired("notes" + Integer.toString(panel)) &&
           (totalSteps % 16)==0) ) {
          
        // Create a moving texture that erases itself when it goes completely off the arm
        ColorRampLayer cr = new ColorRampLayer(panel, CMYPulse, -3); // start completely off the arm
        cr.origin = 1; // scale from the middle
        cr.scaling = curFBParams.arms[panel].pulseWidth;
        cr.terminateWithPosition = true;
        cr.motionSpeed = max(fb.arms[panel].animationSpeed, 0.2);  // dont let speed go to zero, or it lasts forever

        myLayers.add(cr);
      }
    }
  }
  
}


// Note display triggers a fixed set of cubes for each note. 
// we use 
//   - FBParams.animationSpeed to set the speed of (newly created, not pre-existing) fades
//   - FBParams.pulseWidth to set the width of note display
//   - FBParams.flicker to mix it up a bit
class NoteDisplayModule extends TransientLayerModule {
   
  int lightOrFire;
  
  NoteDisplayModule(FBParams _fb, int _lightOrFire) {
    super(_fb);
    lightOrFire = _lightOrFire;
  }
  
  // translates grid position (0-9) into a cube location on the sculpute. There is where spacing, permutation, randomization, etc. happen
  // Subclass for funkier permuted displays
  float notePosition(int panel, int pitch) {
    // convert 0-9 into 0-35, somehow
    if (lightOrFire == FIRE) {
      // We have eight flame effects, ten pitches. Map bottom two to first, top two to last. Bass notes on the inside for fire (larger effects)
      return 7 - clip(pitch-1, 0, 7); 
    } else {
      // Bass notes start outside for sound 
      return pitch*3;
    }
  }
  
  int noteArm(int panel, int pitch) {
    return panel;
  }
  
  // redefine for subclasses to control when new layers are generated
  boolean enabled(int panel) {
    if (lightOrFire == LIGHT) {
      return fb.arms[panel].effectNoteDisplay;
    } else {
      return fb.arms[panel].effectFireDisplay;
    }
  }
  
  // Advance spits out a transient layer for each sequenced note
  void advance(float elapsed) {
    super.advance(elapsed);

    for (int panel=0; panel<3; panel++) {
   
      // Generate new note layers if
      //  - this effect is enabled for this panel
      //  - there are notes on the current step   
      if (enabled(panel) && events.fired("notes" + Integer.toString(panel))) {
   
        for (int pitch=0; pitch<sequencerState.PITCHES; pitch++) {
            if (sequencerState.isNoteAtCurTime(panel, pitch)) {

              Envelope env = new AttackDecayEnvelope(fb.arms[panel].attack, fb.arms[panel].decay, 0, 1);
              
              if (lightOrFire == LIGHT) {
                // Create a static texture that fades out
                ColorRampLayer cr = new ColorRampLayer(noteArm(panel, pitch), basicPulse, notePosition(panel, pitch) - 1); // -1 cause the texture is 3 wide, so center it
                cr.origin = 1; // scale from the middle
                cr.scaling = curFBParams.arms[panel].pulseWidth;
                cr.opacityEnvelope = env;
                cr.terminateWithOpacity = true;
                myLayers.add(cr);
              } else {
                // For fire, activate only a single effect at a time (no "width" response -- is this right?)
                SimpleChaseLayer sc = new SimpleChaseLayer(panelToArmFire(panel));
                
                sc.position = notePosition(panel, pitch);
                sc.opacityEnvelope = env;
                sc.terminateWithOpacity = true;
                sc.terminateWithPosition = false;
                
//                sc.position = 0;
//                sc.motionSpeed = fb.arms[panel].animationSpeed;

                myLayers.add(sc);
  
//                println("Fire display, arm: " + panel + ", pitch: " + pitch + ", position: " + sc.position);              
              }
            }
        }
      }
    }
  }
  
}

// Note permute is very similar but scrambles the notes so they're no longer sequential, or necessarily on the same arm 
// parameters
// Globals:
//   - FBParams.flickerAcrossArms
//   - FBParams.intensity;
// Local:
//   - permuteSeed
//   - panelsIdentical
class NotePermuteModule extends NoteDisplayModule {

  NotePermuteModule(FBParams _fb, int _lightOrFire) {
    super(_fb, _lightOrFire);
  }
  
  boolean initialized = false;
  
  int permuteSeed = 1;               // start here, can change()
  boolean panelsIdentical = false;   // same permutation (rotated) for all panels?
  float permuteAcrossArms = 0.5;     // distribute notes from one panel to different arms, with different probability
  
  // Store the permuted note positions here
  float[][] permOffsets = new float[PANELS][PITCHES];
  int[][] permArms = new int[PANELS][PITCHES];
   
  // Set note position and arm from these arrays   
  float notePosition(int panel, int pitch) {
    if (!initialized) {
      initialize();
    }
    return permOffsets[panel][pitch];
  }
  
  // confine to the panel arm
  int noteArm(int panel, int pitch) {
    return permArms[panel][pitch];
  }

  boolean enabled(int panel) {
    return fb.arms[panel].effectNotePermute;
  }

  // create a permutation for one arm
  void generateSinglePanelPerm(int panel) {

    // permute the pitches, but not completely: use "intensity" to control the number of swaps (average number = intensity*PITCHES)    
    int[] permArray = new int[PITCHES];   
    for (int i=0; i<PITCHES; i++)
      permArray[i] = i;
    randomPermute(permArray, 0.5);
    
    // Start with even, integer spacing, then flicker
    int spacing = 3;  // so, 3 for lighting arms (as opposed to fire arms);
    int start = 3;
 
    // Permote pitches, space them out evenly on the arms, then move to some to other arms with probability flickerAcrossArms     
    for (int i=0; i<PITCHES; i++) {
      permOffsets[panel][i] = start + spacing*permArray[i] + 10*(random(fb.flicker) - fb.flicker/2);  // move +/-5 cubes when flicker=1
   
      permArms[panel][i] = generateArmNumber(panel);
    }
  }
  
  // used if panelsIdentical
  void rotatePanel0IntoPanel12() {
    for (int i=0; i<PITCHES; i++) {
      permOffsets[1][i] = permOffsets[0][i];
      permArms[1][i] = (permArms[0][i]+1) % PANELS;
          
      permOffsets[2][i] = permOffsets[0][i];
      permArms[2][i] = (permArms[0][i]+2) % PANELS;
    }
  }
  
  // generate an arm number for a note on a specific panel
  // always = panel # if flickerAcrossArms is 0, otherwise shifted with some probability
  int generateArmNumber(int panel) {
      if (permuteAcrossArms > random(1)) {
        return floor(random(PANELS));
      } else {
        return panel;
      }
  }
  
  // swap a given number of elements in the permutation of a givel panel
  void makeSomeSwaps(int panel, int numToSwap) {
    for (int i=0; i<numToSwap; i++) {
          
    int idx1 = floor(random(PITCHES));
    int idx2 = floor(random(PITCHES));
          
    float tmp = permOffsets[panel][idx1];
    permOffsets[panel][idx1] = permOffsets[panel][idx2];
    permOffsets[panel][idx2] = tmp;
          
    // reassign the arms too
    permArms[panel][idx1] = generateArmNumber(panel);
    permArms[panel][idx2] = generateArmNumber(panel);          
    }
  }
  
  // Set up a map between notes and positions on the arms, a flickered permutation.
  void initialize() {      
    randomSeed(permuteSeed);

    generateSinglePanelPerm(0);
    
    // rotate single permutation into other arms if panelsIdentical, else a new permutation for each panel
    if (panelsIdentical) {
      rotatePanel0IntoPanel12();
    } else {
      generateSinglePanelPerm(1);
      generateSinglePanelPerm(2);
    }
    
    initialized = true;
  }

}

// Knuth's algorithm for random permutation, but we only do a swap with probability p
void randomPermute(int[] a, float p) {
  for (int i=0; i<a.length; i++) {
    if (p >  random(1)) {
      int j = floor(random(a.length));
      int tmp = a[i];
      a[i] = a[j];
      a[j] = tmp;   
    }
  }
}


//------------------------------------------------- ColorRamps -------------------------------------------------
// And code to initialize them from arrays of colors

boolean rampsInitialized = false;

ColorVertex[] fireRamp;    // black to red, orange, yellow, white
float fireRampLength;      // so we can set the origin correctly
ColorVertex[] basicPulse;  // just white, triangular (black-white-black) so only a single fixture lights when integer offset, scale=1
ColorVertex[] squarePulse; // width=1 full on pulse. To center on a fixture you need a half-pixel offset
ColorVertex[] CMYPulse;    

color basicPulseColors[] = {color(0,0,0), color(255,255,255), color(0,0,0)};
color squarePulseColors[] = {color(255,255,255), color(255,255,255)};
color CMYPulseColors[] = {color(0,255,255), color(255,0,255), color(255,255,0)};
color fireRampColors[] = {color(50,0,0), color(100, 0, 0), color(255, 255, 0), color(255,255,255)};

// create a ColorVertex ramp from an array of colors, setting the width of each segment to 1
// often, that's all you'll need
ColorVertex[] initVertices(color[] colors) {
  ColorVertex[] result = new ColorVertex[colors.length];
  for (int i=0; i<colors.length; i++) {
    result[i] = new ColorVertex();
    result[i].c = colors[i];
    result[i].w = 1;
  }
  return result;
}

// What a terribly awkward way to initialize these structures. Makes me want aggregate initializers ala C++
// though I suppose I could start with color arrays, which can be initialized 
void initializeRamps() {

  if (rampsInitialized) 
    return;
    
  colorMode(RGB,255);
  
  basicPulse = initVertices(basicPulseColors);
  squarePulse = initVertices(squarePulseColors);
  CMYPulse = initVertices(CMYPulseColors);
 
  //println("CMY INITIAL: " +  colorToString(CMYPulse[0].c) + ", " + colorToString(CMYPulse[1].c) + ", " + colorToString(CMYPulse[2].c));
  
  // fireRamp segments get smaller and smaller, so yellow->white segment is just the tip
  fireRamp = initVertices(fireRampColors);
  fireRamp[0].w = 3;
  fireRamp[1].w = 2;
  fireRamp[2].w = 1;
  fireRampLength = 6;
 
  rampsInitialized = true;
}

//------------------------------------------------- BeatTrainModule -------------------------------------------------
// This sends a series of pulses out from the panel, brightness corresponding to the number of notes active on each step
// the idea is to produce a flowing visual representation of the music
// Parameters used:
//   fb.animationSpeed
//   fb.pulseWidth
// With defaults, pulses are 1 wide with gaps of 1 between them, so that they are clearly separated

class BeatTrainModule extends TransientLayerModule {

  int lightOrFire;    // if FIRE, we render to the flame effects
  
  BeatTrainModule(FBParams _fb, int _lightOrFire) {
    super(_fb);
    lightOrFire = _lightOrFire;
  }

  // applies a non-linear ramp to the number of notes active, to provide contrast and make the patterns clearer
  // Scales adaptively to the maximum number of notes in any column
  float numNotesGammaCorrect(float num, float maxPerCol) {
    float v = num/maxPerCol;    // call 4 notes at once full brightness
    v = min(1,v);               // clip at 1
    return v*v*v;               // fall off from peak value very rapidly 
  }
    
  // Figure out the intensity of the current step for the current panel
  // We count the number of notes in the column, divide by the max number of notes in any column, and gamma correct
  float noteIntensity(int panel, int col) {
    int notesInThisCol = 0;
    int notesInAnyCol = 0;
    
    // scan across columns of the sequencer state for this panel
    for (int step=0; step<sequencerState.STEPS; step++) {
      
      // count number in this col
      int curn=0;
      for (int pitch=0; pitch<sequencerState.PITCHES; pitch++) {
        if (sequencerState.notes[panel][sequencerState.curTab[panel]][step][pitch])
          curn++;
      }
      
      // update max, possibly cur 
      notesInAnyCol = max(curn, notesInAnyCol);
      if (step == col)
        notesInThisCol = curn;
    }
    
    return numNotesGammaCorrect(notesInThisCol, notesInAnyCol);
  } 
    
  void advance(float elapsed) {
    super.advance(elapsed);
    
     // for each panel: if enabled, fire when there are notes    
     for (int panel=0; panel<3; panel++) {   
      if (fb.arms[panel].effectBeatTrain && events.fired("notes" + Integer.toString(panel))) {

        // Fire off a colorRampLayer for this note
        float intensity = noteIntensity(panel, floor(sequencerState.stepPosition));

        ColorRampLayer cr = new ColorRampLayer(panelToArm(panel, lightOrFire), basicPulse, -2);  // basicPulse is 3 wide, so -2 starts just onscreen
        
        cr.motionSpeed = fb.arms[panel].animationSpeed * 2;  // by default keep a gap of 1 fixture between pulses
        cr.terminateWithPosition = true;
        
        myLayers.add(cr);
      }
    }
  }
  
}


//------------------------------------------------- BassPulseModule -------------------------------------------------
// This runs a single colored pulse out from the center to the edges, when triggered by notes in the bass lines

//figures out the lowest note set on the given sequencer panel. Lower = lower pitch, actually higher index  
int findLowestNote(int panel) {
  for (int pitch=sequencerState.PITCHES-1; pitch>=0; pitch--) 
    for (int step=0; step<sequencerState.STEPS; step++) 
      if (sequencerState.notes[panel][sequencerState.curTab[panel]][step][pitch])
        return pitch;

  return 0; // no notes, but we're going to use this an an index into the steps, so don't do -1 or something silly
}


// Uses:
//  - fb.pulseWith to control overall size
//  - fb.attack, fb.decay to contol animation

class BassPulseModule extends TransientLayerModule {

  // if true, pulses go from panels in, otherwise center out
  boolean fromOutside;
  
  BassPulseModule(FBParams _fb) {
    super(_fb);
    initializeRamps();
    fromOutside = false;
  }
  
  void advance(float elapsed) {
    super.advance(elapsed);    
 
    // for each panel: if enabled, fire when there are notes    
    for (int panel=0; panel<3; panel++) {   
      if (fb.arms[panel].effectBassPulse && events.fired("notes" + Integer.toString(panel))) {

        int lowestPitch = findLowestNote(panel);
        
        if (sequencerState.isNoteAtCurTime(panel, lowestPitch)) {           // bottom row on sequencer triggers
          ColorRampLayer cr = new ColorRampLayer(panel, fireRamp, 0);
  
          if (fromOutside) {
            cr.scaleEnvelope = new AttackDecayEnvelope(fb.arms[panel].attack, fb.arms[panel].decay, 0, fb.arms[panel].pulseWidth*10 / fireRampLength);  // normal size is 10 cubes
          } else {
            cr.scaleEnvelope = new AttackDecayEnvelope(fb.arms[panel].attack, fb.arms[panel].decay, 0, -fb.arms[panel].pulseWidth*10 / fireRampLength);  // scale is negative because we're going the other way
            cr.position = CUBES_PER_ARM - 1;
          }
          
          cr.terminateWithScale = true;
          
          myLayers.add(cr);
        }
      }
    }
  }
  
}


//------------------------------------------------- FireChaseModule -------------------------------------------------
// Do a fire chase... at the end of every bar, for the moment, for testing 
class FireChaseModule extends TransientLayerModule {
  
    // if true, pulses go from panels in, otherwise center out
  boolean fromOutside;
  
  FireChaseModule(FBParams _fb) {
    super(_fb);
    fromOutside = false;
  }
  
  void advance(float elapsed) {
    super.advance(elapsed);    
    
    for (int panel=0; panel<3; panel++) {   
      if (fb.arms[panel].effectFireChase && events.fired("bar")) {

        //println("new simplechase");
        
        SimpleChaseLayer sc = new SimpleChaseLayer(panelToArmFire(panel));
          
        if (fromOutside) {
          sc.position = -1;
          sc.motionSpeed = fb.arms[panel].animationSpeed;
        } else {
          sc.position = armResolution(sc.arm);
          sc.motionSpeed = -fb.arms[panel].animationSpeed;
        }
          
        myLayers.add(sc);
      }
    }
  }

}


// ---------------------------------------- TintModule ----------------------------------------- 
// This is layer that modulates the state it's applied to. It's a color correction.
// Uses
//  - fb.ccTint
//  - fb.ccChroma
//  - fb.ccBrightness

class TintModule extends FBModule {
  
  TintModule(FBParams _fb) {
    super(_fb);
  }

  // advance is a NOP, we don't animate (yet?)
  
  color correct(int panel, color in) {
    colorMode(HSB,360,100,100);

    float inhue = radians(hue(in));
    float insat = saturation(in);
    float inx = insat*cos(inhue);
    float iny = insat*sin(inhue);
    
    float tinthue = radians(hue(fb.arms[panel].effectTint));
    float tintsat = saturation(fb.arms[panel].effectTint);
    float tintx = tintsat*cos(tinthue);
    float tinty = tintsat*sin(tinthue);

    inx *= fb.arms[panel].effectChroma/100;
    iny *= fb.arms[panel].effectChroma/100;
    inx += tintx;
    iny += tinty;
    
    float outhue = (degrees(atan2(iny, inx))+360)%360;   // color ctor doesn't like negative hue
    float outsat = sqrt(inx*inx + iny*iny);
    
    if (outsat > 100) {
      outsat = 100;
    } else if (outsat < 0) {
      outsat = 0;
    }
      
    color out = color(outhue, outsat, brightness(in)*fb.arms[panel].effectBright/100);

    colorMode(RGB, 255);
    
 //   out = fb.tintColor; 
    return out;
  }
 
  void apply(LightingState state) {
    for (int panel=0; panel<3; panel++) // only bother with lighting arms
      for (int i=0; i<armResolution(panel); i++) {
        state.armColor[panel][i] = correct(panel, state.armColor[panel][i]);
      }
  }
}


// ---------------------------------------- Fire Modules ----------------------------------------- 
// This module manages all of the flame effects that go across arms
// Uses: fb.manualFire*

class ManualFireModule extends TransientLayerModule {
  
  ManualFireModule(FBParams _fb) {
    super(_fb);
  }
 
  // trigger the specified pattern right now
  void firePattern(int i) {
    
    DecayRaceLayer dr0, dr1, dr2;
    
    switch (i) {
     
      case 0: // serial
        dr0 = new DecayRaceLayer(panelToArmFire((totalSteps / sequencerState.STEPS) % 3),       // cycle between three different arms
                                 manualFireSpeeds[fb.manualFireSpeed],
                                 fb.manualFireDecay);
        myLayers.add(dr0);
        break;
        
      case 1:  // parallel
          dr0 = new DecayRaceLayer(panelToArmFire(0), manualFireSpeeds[fb.manualFireSpeed], fb.manualFireDecay);
          myLayers.add(dr0);
          dr1 = new DecayRaceLayer(panelToArmFire(1), manualFireSpeeds[fb.manualFireSpeed], fb.manualFireDecay);
          myLayers.add(dr1);
          dr2 = new DecayRaceLayer(panelToArmFire(2), manualFireSpeeds[fb.manualFireSpeed], fb.manualFireDecay);
          myLayers.add(dr2);
          break;
  
      case 2:  // spiral
        // Create three different races with different phases
        float thirdSpeed = manualFireSpeeds[fb.manualFireSpeed]/3.0;
        
        dr0 = new DecayRaceLayer(panelToArmFire(0), thirdSpeed, fb.manualFireDecay);
        dr0.startWait = 0;
        myLayers.add(dr0);
        dr1 = new DecayRaceLayer(panelToArmFire(1), thirdSpeed, fb.manualFireDecay);
        dr1.startWait = thirdSpeed;
        myLayers.add(dr1);
        dr2 = new DecayRaceLayer(panelToArmFire(2), thirdSpeed, fb.manualFireDecay);
        dr2.startWait = 2*thirdSpeed;
        myLayers.add(dr2);
        break;
     
     case 3:  // all
        // implemented by starting a parallel run with 0 wait between steps
        dr0 = new DecayRaceLayer(panelToArmFire(0), 0, fb.manualFireDecay);
        myLayers.add(dr0);
        dr1 = new DecayRaceLayer(panelToArmFire(1), 0, fb.manualFireDecay);
        myLayers.add(dr1);
        dr2 = new DecayRaceLayer(panelToArmFire(2), 0, fb.manualFireDecay);
        myLayers.add(dr2);
        break;       
    }
  }

  // Advance triggers new layers in two cases:
  //  - one-shot OSC messages, if repeat is off
  //  - step changes, if repeat is on 
  void advance(float elapsed) {
  
    super.advance(elapsed);    
    
    // Fire chases right now if we're not in repeat mode and someone hit the pattern button
    for (int i=0; i<manualFirePatternOSCAddr.length; i++) {
      if (events.fired("manualFirePattern" + i)) {
        firePattern(i);
      }
    }
      
    // otherwise fire on the bar if we're in repeat mode
    if (fb.manualFireRepeat && events.fired("bar")) {
      if (fb.manualFirePatternIndex != -1) {
        firePattern(fb.manualFirePatternIndex);
      }
    }
  }

}



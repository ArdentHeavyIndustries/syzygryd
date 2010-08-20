// ------------------------------------------------- Modules for FrameBrulee -----------------------------------------
// An FBModule is a Layer with some parameters, which it can set from an FBParams block.
// It is sensitive to intensity and change messages, and knows how to fade in and out


abstract class FBModule extends Layer {
  
  boolean active;    // fading or running
  float fadeInSpeed;
  float fadeOutSpeed;
  
  FBModule() {
    active = true;
    fadeInSpeed = 0;
    fadeOutSpeed = 0;
  }
  
  void setParams(FBParams fb) {
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
  
  void masterAdvance(float elapsedSteps) {
    animateFades(elapsedSteps);
    advance(elapsedSteps);
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
  
  // we use 
  //   - FBParams.animationSpeed to set the speed of (newly created, not pre-existing) chases
  //   - FBParams.wifth to set the chase width
  float degreesPerStep = 1;
  float degreeSpread = 120;
  float sat = 100;
  float bright = 100;
  
  void setParams(FBParams fb) {
     super.setParams(fb);
     degreesPerStep = fb.baseHueRotationSpeed;
     degreeSpread   = fb.baseHueSpread;
     sat = fb.baseHueSat;
     bright = fb.baseHueBright;
  }

  HueRotateModule() {
    phase = 0;
  }

  void advance(float steps) {
    phase += steps*degreesPerStep;
  }
  
  void apply(LightingState dst)
  {
    LightingState state = new LightingState();

    colorMode(HSB,360,100,100);
    state.fillArm(0, color(phase % 360, sat, bright));
    state.fillArm(1, color((phase + degreeSpread) % 360, sat, bright));
    state.fillArm(2, color((phase - degreeSpread) % 360, sat, bright));
    colorMode(RGB);
    
    dst.blendOverSelf(state, blendMode, opacity);    
  }
  
}

//------------------------------------------------- TransientLayerModule -----------------------------------------
// TransientLayerModule is a BruleeModule that maintains a bunch of layers that animate on their own. Useful for e.g. note displays

class TransientLayerModule extends FBModule {
  
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
        layer.advance(elapsedTime);
      } 
    }
  }
  
}

//------------------------------------------------- NoteDisplays -----------------------------------------

// Some textures
color[] CMYPulseTexture = new color[] {color(150, 150, 00), color(150, 0, 150), color(0, 150, 150)}; // simple lighting "pulse" for chase layers 
color[] whitePulseTexture = new color[] {color(100, 100, 100), color(200, 200, 200), color(100, 100, 100)};  

// Note chase sends a pulse down the arm for each step where a note is on
class NoteChaseModule extends TransientLayerModule {

  // we use 
  //   - FBParams.animationSpeed to set the speed of (newly created, not pre-existing) chases
  //   - FBParams.wifth to set the chase width
  float animationSpeed;
  float pulseWidth;
  void setParams(FBParams fb) {
     super.setParams(fb);
     animationSpeed = fb.animationSpeed;
     pulseWidth = fb.pulseWidth;
  }
  
  void advance(float elapsed) {
    super.advance(elapsed);
    
    for (int i=0; i<3; i++) {   
      if (events.fired("notes" + Integer.toString(i))) {
        
        if (floor(sequencerState.stepPosition) % 8 == 0) {
  
          // $$ use chaseWidth          
          // Create a moving texture that erases itself when it goes completely off the arm
          TextureLayer cl = new TextureLayer(i, CMYPulseTexture, -3);
          cl.terminateWhenOffscreen = true;
          cl.motionSpeed = 4 * animationSpeed;
          
          myLayers.add(cl);
        }
      }
    }
  }
  
}

// Note display triggers a fixed set of cubes for each note. 
class NoteDisplayModule extends TransientLayerModule {
  
  // we use 
  //   - FBParams.animationSpeed to set the speed of (newly created, not pre-existing) fades
  //   - FBParams.pulseWidth to set the width of note display
  //   - FBParams.jitter to mix it up a bit
  float animationSpeed;
  float pulseWidth;
  float jitter;
  void setParams(FBParams fb) {
     super.setParams(fb);
     animationSpeed = fb.animationSpeed;
     pulseWidth = fb.pulseWidth;
     jitter = fb.jitter;
  }
    
  // translates grid position (0-9) into a cube location on the sculpute. There is where spacing, permutation, randomization, etc. happen
  // Subclass for funkier permuted displays
  float notePosition(int panel, int pitch) {
    // convert 0-9 into 0-35, somehow
    return pitch*3;
  }
  
  int noteArm(int panel, int pitch) {
    return panel;
  }
  
  // Advance spits out a transient layer for each sequenced note
  void advance(float elapsed) {
    super.advance(elapsed);

    for (int arm=0; arm<3; arm++) {   
      if (events.fired("notes" + Integer.toString(arm))) {
   
        for (int pitch=0; pitch<sequencerState.PITCHES; pitch++) {
            if (sequencerState.isNoteAtCurTime(arm, pitch)) {

              // Create a static texture that fades out
              TextureLayer cl = new TextureLayer(noteArm(arm, pitch), whitePulseTexture, notePosition(arm, pitch) - 1); // -1 cause the texture is 3 wide, so center it
              cl.fadeSpeed = 0.2;
              cl.terminateWhenFaded = true;
        
              myLayers.add(cl);
            }
        }
      }
    }
  }
}

// Note permute is very similar but 
class NotePermuteModule extends NoteDisplayModule {

  boolean initialized = false;
  
  // parameters
  // Globals:
  //   - FBParams.jitterAcrossArms
  //   - FBParams.intensity;
  // Local:
  //   - permuteSeed
  //   - panelsIdentical
  float jitterAcrossArms;
  float intensity;
  int permuteSeed = 1;         // start here, can change()
  boolean panelsIdentical;     // same permutation (rotated) for all panels?

  void setParams(FBParams fb) {
    super.setParams(fb);
    jitterAcrossArms = fb.jitterAcrossArms;
    intensity = fb.intensity;
  }
  
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

  // create a permutation for one arm
  void generateSinglePanelPerm(int panel) {

    // permute the pitches, but not completely: use "intensity" to control the number of swaps (average number = intensity*PITCHES)    
    int[] permArray = new int[PITCHES];   
    for (int i=0; i<PITCHES; i++)
      permArray[i] = i;
    randomPermute(permArray , intensity);
    
    // Start with even, integer spacing, then jitter
    int spacing = 3;  // so, 3 for lighting arms (as opposed to fire arms);
    int start = 3;
 
    // Permote pitches, space them out evenly on the arms, then move to some to other arms with probability jitterAcrossArms     
    for (int i=0; i<PITCHES; i++) {
      permOffsets[panel][i] = start + spacing*permArray[i] + random(jitter) - jitter/2;
   
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
  // always = panel # if jitterAcrossArms is 0, otherwise shifted with some probability
  int generateArmNumber(int panel) {
      if (jitterAcrossArms > random(1)) {
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
  
  // Set up a map between notes and positions on the arms, a jittered permutation.
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

  // If the change is at least 4 bar, re-seed the permutation 
  void mutate(float howMuch) {
    super.mutate(howMuch);
    
    if (howMuch >= MUTATE_4BAR) {
      permuteSeed = floor(random(1000));
      panelsIdentical = (intensity < random(1));  // lower intensity, more likely the panels are identical  
      initialize();
    } else {
      int numToSwap = floor(2 * (howMuch / MUTATE_BAR));  // switch up about 2 per bar  
      makeSomeSwaps(0, numToSwap);
      
      if (panelsIdentical) {
        rotatePanel0IntoPanel12();
      } else {
        makeSomeSwaps(1, numToSwap);
        makeSomeSwaps(2, numToSwap);
      }
    }
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




// FrameBrulee
// A lighting and fire control program for Syzygryd, using the Layer interface
// Jonathan Stray, August 2010


// A BruleeModule is a Layer with some parameters
// It is sensitive to intensity and change messages, and will fade in and out
class BruleeModule extends Layer {
  
  boolean active;    // fading or running
  float fadeInSpeed;
  float fadeOutSpeed;
  
  BruleeModule() {
    active = true;
    fadeInSpeed = 0;
    fadeOutSpeed = 0;
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
  
  void advance(float elapsedSteps) {
    animateFades(elapsedSteps);
  }
  
  // we hit a bar or the operator pressed a button or something... change up the parameters
  void change() {
  }
  
}


// TransientLayerModule is a BruleeModule that maintains a bunch of layers that animate on their own. Useful for e.g. note displays
class TransientLayerModule extends BruleeModule {
  
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


// Note chase sends a pulse down the arm for each step where a note is on
class NoteChaseModule extends TransientLayerModule {

  color[] whitePulse = new color[] {color(50, 50, 50), color(100, 100, 100), color(200, 200, 200)}; // simple lighting "pulse" for chase layers 
 
  void advance(float elapsed) {
    super.advance(elapsed);
    
    for (int i=0; i<3; i++) {   
      if (events.fired("notes" + Integer.toString(i))) {
        
        // Create a moving texture that erases itself when it goes completely off the arm
        TextureLayer cl = new TextureLayer(i, whitePulse, -3);
        cl.motionSpeed = 0.2;
        cl.terminateWhenOffscreen = true;
        
        myLayers.add(cl);
      }
    }
  }
  
}

// Note display triggers a fixed set of cubes for each note. Linear and permuted modes, other tricks.
class NoteDisplayModule extends TransientLayerModule {
  
  color[] whitePulse = new color[] {color(100, 100, 100), color(200, 200, 200), color(100, 100, 100)};  
  
  // translates grid position (0-9) into a cube location. There is where spacing, permutation, randomization, etc. happen
  float notePosition(int noteIndex) {
    // convert 0-9 into 0-35, somehow
    return noteIndex*3 + 4;
  }
  
  void advance(float elapsed) {
    super.advance(elapsed);

    for (int arm=0; arm<3; arm++) {   
      if (events.fired("notes" + Integer.toString(arm))) {
   
        for (int pitch=0; pitch<sequencerState.PITCHES; pitch++) {
            if (sequencerState.isNoteAtCurTime(arm, pitch)) {

              // Create a static texture that fades out
              TextureLayer cl = new TextureLayer(arm, whitePulse, notePosition(pitch) - 1); // -1 cause the texture is 3 wide, so center it
              cl.fadeSpeed = 0.2;
              cl.terminateWhenFaded = true;
        
              myLayers.add(cl);
            }
        }
      }
    }
  }
  
}

// Globals parameters that control the program. These are exposed to the operator through touchOSC

float fbIntensity = 0.5;       // how much stuff is going on?

float fbAnimationSpeed = 1;    // relative to steps

color fbTint = color(#808080); // central hue and sat 
float fbChroma = 1.0;          // 1.0 means full range, 0 means monochromatic


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
  
  // Top permanent layers
  //TintLayer          tintLayer;
   
  void initialize() {
    // Bottom layer is a hue rotate
    baseHueRotate = new HueRotateLayer(color(#8f0000), 5.0);
    noteChase = new NoteChaseModule();
    noteDisplay = new NoteDisplayModule();
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
 
    baseHueRotate.advance(elapsedSteps);
    noteChase.advance(elapsedSteps);
    noteDisplay.advance(elapsedSteps);

  }
  
  // This is the core rendering stack, that applies all the right modules in the right order, according to mode
  void render(LightingState state) {
    baseHueRotate.apply(state);
   // noteChase.apply(state);
    noteDisplay.apply(state);
  }

}


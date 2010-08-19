
// A layer is a single animation (across lights and effects.)
// It runs until it completes or is removed.
// Layers are rendered sequentially, modifying a lighting state, to produce the final result

// Most basic layer abstraction
abstract class Layer {

  boolean finishedFlag = false;
  float stepsSinceBirth = 0;

  // public, controllable paramters
  public float animationSpeed = 1;    // measured w.r.t in steps
  public float opacity = 1;           // when opacity = 0, applpy should be a NOP

  // call Layer.advance() if you want to use stepsSinceBirth
  void advance(float steps) {
    stepsSinceBirth += steps;
  }

  boolean finished() {
    return finishedFlag;
  }

  void finish() {
    finishedFlag = true;
  }

  // Apply this layer to the given state. 
  void apply(LightingState otherState) {
  }
}

// This is a layer that has a lighting image and applies itself by blending
abstract class ImageLayer extends Layer {

  public int blendMode = ADD;
  public LightingState state = new LightingState();
  boolean finishedFlag = false;

  // Apply ourself to the image underneath
  void apply(LightingState otherState) {
    otherState.blendOverSelf(state, blendMode, opacity);
  }
}

/*
// TimedLayer automatically removes itself from the master layer after a specified number of steps have elapsed
 // Used for things like single pulses that travels an arm and then is gone 
 abstract class TimedLayer extends Layer {
 float curSteps;
 float totalSteps;
 
 void TimedBehavior(float duration) {  // duration in steps
 curSteps = 0;
 totalSteps = duration;
 }
 
 
 // Returns proportion of scheduled duration already passed, as a value between 0 (not started) and 1 (complete).
 public float proportionDone() {
 return min(1, curSteps / totalSteps);
 }
 
 void advance(float steps) {
 curSteps += steps;
 if (curSteps >= totalSteps)
 finish();
 else
 draw(curSteps / totalSteps);
 }  
 
 void drawFrame(float proportionDone) {
 // your rendering code here
 }
 }
 */

// ---------------------------------------- HueRotateLayer ----------------------------------------- 
// Cycles hues across arms. Always 120 degrees apart, using saturation, brightness, and initial phase of baseColor

class HueRotateLayer extends ImageLayer {

  color baseColor;
  float startTime; // in steps
  public float degreesPerStep;
  public float degreesSpread;

  HueRotateLayer(color _baseColor, float _degreesPerStep) {
    baseColor = _baseColor;
    degreesPerStep = _degreesPerStep;
    degreesSpread = 120;
    startTime = curTimeInSteps();
  }

  void advance(float steps) {
    super.advance(steps);

    float phase = stepsSinceBirth*degreesPerStep;

    colorMode(HSB,360,100,100);
    state.fillArm(0, color((phase + hue(baseColor)) % 360, saturation(baseColor), brightness(baseColor)));
    state.fillArm(1, color((phase + hue(baseColor) + degreesSpread) % 360, saturation(baseColor), brightness(baseColor)));
    state.fillArm(2, color((phase + hue(baseColor) + degreesSpread) % 360, saturation(baseColor), brightness(baseColor)));
    colorMode(RGB);
  }
}

// ---------------------------------------- TextureLayer ----------------------------------------- 

// Render one texture into another with a float offset, lerping between pixels of src. Outside src is considered black.
void copy1DTexture(color[] src, color[] dst, float offset) {

  for (int i=0; i<dst.length; i++) {

    float srcIdx = i - offset;
    int floorIdx = floor(srcIdx);
    float fracIdx = srcIdx - floorIdx;

    if (srcIdx < -1) {

      // off start of seq, black
      dst[i] = 0;
    } 
    else if (srcIdx < 0) {

      // within one cube of start, lerp from black to first color
      dst[i] = lerpColor(0, src[0], srcIdx+1);
    } 
    else if (floorIdx+1 < src.length) {

      // between two elements of sequence, lerp
      dst[i] = lerpColor(src[floorIdx], src[floorIdx+1], fracIdx);
    } 
    else if (floorIdx < src.length) {

      // within one cube of end, lerp from last color to black 
      dst[i] = lerpColor(src[src.length-1], 0, fracIdx);
    } 
    else { 

      // past the end
      dst[i] = 0;
    }
  } // for
}


// TextureLayer renders a texture on an arm. Linearly interpolates between colors if non-integer aligned.
// Built in support for motion and opacity animation.
//  - cubesPerStep controls speed, normally out->in, but can be negative for in->out. 
//  - offset is the index of seq[0]. So -seq.length() if the head of the sequence starts at cube 0
// Terminates when:
//  - a moving the pattern falls completely off one end of the arm, if terminateWhenOffscreen is true
//  - opacity hits zero, if terminateWhenFaded is true

class TextureLayer extends ImageLayer {
  public color[] tex;
  public int arm;
  public float offset;

  public float motionSpeed = 0;
  public float fadeSpeed = 0;    // positive means losing opacity. 

  public boolean terminateWhenOffscreen = false;
  public boolean terminateWhenFaded = false;

  TextureLayer(int _arm, color[] _tex, float _offset) {
    tex = _tex;
    arm = _arm;
    offset = _offset;
    blendMode = ADD;
  }

  // Draw, then advance (so first frame is aligned with starting offset)
  void advance(float steps) {
    super.advance(steps);

    // zero length seq protection
    if (tex.length < 1) {
      finish();
      return;
    }

    // render
    copy1DTexture(tex, state.armColor[arm], offset);

    // animate
    offset += motionSpeed * animationSpeed * steps;
    opacity -= fadeSpeed * animationSpeed * steps;

    // stop fades if we hit opacity limits   
    if (opacity >= 1) {
      opacity = 1;
      fadeSpeed = 0;
    }

    if (opacity <= 0) {
      // remove when opacity hits zero, if told to do so
      if (terminateWhenFaded) {
        finish();
        return;
      } 
      else {
        opacity = 0;
        fadeSpeed = 0;
      }
    }

    // if the pattern is completely off the arm in the direction of travel, remove this layer, if told to do so
    if (terminateWhenOffscreen) {
      if ( ((motionSpeed > 0) && (offset >= state.armColor[arm].length)) ||
        ((motionSpeed < 0) && (offset <= -tex.length)) ) {
        finish();
      }
    }
  }
}


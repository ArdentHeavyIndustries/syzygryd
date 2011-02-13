// A layer is a single animation (across lights and effects.)
// It runs until it completes or is removed.
// Layers are rendered sequentially, modifying a lighting state, to produce the final result

// Most basic layer abstraction
abstract class Layer {

  // public, controllable paramters
  public float opacity = 1;           // when opacity = 0, applpy should be a NOP
  public int blendMode = ADD;

  boolean finishedFlag = false;
  float stepsSinceBirth = 0;

 // move any animation forward
 void masterAdvance(float steps) {
    stepsSinceBirth += steps;
    advance(steps);
  }

  // subclasses to override this one
  void advance(float time) { 
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

  public LightingState state = new LightingState();

  // Apply ourself to the image underneath
  void apply(LightingState otherState) {
    otherState.blendOverSelf(state, blendMode, opacity);
  }
}

// ---------------------------------------- Envelopes ----------------------------------------- 
// Classes that implement 1D animation, for a pre-specified finite interval

abstract class Envelope {
  boolean isFinished() {    // animation over
    return true;
  }  
  
  float getVal() {          // current value
    return 0;
  }
  
  void advance(float time) {  // move the envelope forward
  }
}

// A small class that animates a value from off to on value (off may be >  on) over specified attack/decay time
class AttackDecayEnvelope extends Envelope {
  float attackTime;
  float decayTime;
  float offVal;
  float onVal;
  boolean hitPeak;
  float elapsedTime;
  boolean finished;
  
  AttackDecayEnvelope(float _attackTime, float _decayTime, float _offVal, float _onVal) {
    attackTime = _attackTime;
    decayTime = _decayTime;
    if (attackTime > 0) { 
      hitPeak = false;
    } else {
      hitPeak = true;
    }
    elapsedTime = 0;
    offVal = _offVal;
    onVal = _onVal;
    if (attackTime + decayTime > 0) {
      finished = false;
    } else {
      finished = true;
    }
  }
  
  boolean isFinished() {
    return finished;
  }
  
  float getVal() {
    if (finished) {
      return offVal;
    } else {
      if (!hitPeak) {
        return offVal + (elapsedTime / attackTime) * (onVal - offVal); // in attack
      } else {
        return offVal + (1-(elapsedTime / decayTime)) * (onVal - offVal); // in decay
      }
    } 
  }
  
  void advance(float time) {
    elapsedTime += time;
    if (!hitPeak) {
      if (elapsedTime > attackTime) {
        elapsedTime = elapsedTime - attackTime;  // switch from attack to decay
        hitPeak = true;
      }
    }
      
    if (hitPeak) {
      if (elapsedTime > decayTime) {
        finished = true;                          // switch from decay to finished
      }
    }
  }
  
}

// ---------------------------------------- MoveableShapeLayer ----------------------------------------- 
// Animates a shape across an arm. Motion and opacity controlled with envelopes.
// Terminates when:
//  - a moving the pattern falls completely off one end of the arm, if terminateWhenOffscreen is true
//  - opacity hits zero when decaySpeed is positive, if terminateWhenFaded is true

abstract class MoveableShapeLayer extends ImageLayer {

  public int arm;

  public Envelope opacityEnvelope;
  
  public Envelope positionEnvelope;
  public float position;                  // used if no envelope
  public float motionSpeed;

  public Envelope scaleEnvelope;
  public float scaling;                 // used if no envelope

  public boolean terminateWithOpacity = false;
  public boolean terminateWithPosition = false;
  public boolean terminateWithScale = false;
  
  MoveableShapeLayer(int _arm, float _position) {
    arm = _arm;
    position = _position;
  }

  // Children need to define render and shapeWidth 
  void render(color[] armColor, float position, float scaling) {
  }
  float shapeWidth() {
    return 0;
  }
  
  // Update all animation parameters (motion, fades)
  // terminate self if any of the various terminateWith... conditions are met
  void advance(float steps) {
  
    // animate
    if (opacityEnvelope != null) {
      opacityEnvelope.advance(steps);
      if (terminateWithOpacity && opacityEnvelope.isFinished()) {
        finish();
        return;
      }
      opacity = opacityEnvelope.getVal();
    }

    if (positionEnvelope != null) {
      positionEnvelope.advance(steps);
      if (terminateWithPosition && positionEnvelope.isFinished()) {
        finish();
        return;
      }
      position = positionEnvelope.getVal();
    } else {
      
      // manual animation, no motion envelope, move at constant rate, terminate when offscreen
      position += motionSpeed * steps;  
      if (terminateWithPosition) {
        if ( ((motionSpeed > 0) && (position >= state.armColor[arm].length)) ||
             ((motionSpeed < 0) && (position <= -shapeWidth())) ) {
          finish();
 //         println("Killed it. position: " + position + ", shapeWidth: " + shapeWidth());
          return;
        }
      }
    }
    
    if (scaleEnvelope != null) {
      scaleEnvelope.advance(steps);
      if (terminateWithScale && scaleEnvelope.isFinished()) {
        finish();
        return;
      }
      scaling = scaleEnvelope.getVal();
 //     println("scaling: " + scaling);
    } 
  }
  
  // render the shape at offset
  void apply(LightingState otherState) {
    render(state.armColor[arm], position, scaling);
    otherState.blendOverSelf(state, blendMode, opacity);
  }
}

// ---------------------------------------- SimpleChaseLayer ----------------------------------------- 
// A MoveableShape that lights exactly one fixture at a time, stepping without anti-aliasing
// Good for testing, and flame effects
class SimpleChaseLayer extends MoveableShapeLayer {
  
  SimpleChaseLayer(int arm) {
    super(arm, 0);  // default to position 0, speed 1 (outside in)
    motionSpeed = 1;
    terminateWithPosition = true;
  }

  float shapeWidth() {
    return 1;
  }
  
  // Children need to define render and shapeWidth 
  void render(color[] armColor, float position, float scaling) {
    state.clear();
    int pos = floor(position+0.5);
    if ((pos >= 0) && (pos < armResolution(arm))) {
//      println("simplechase render, arm: " +  arm + ", pos: " + pos);
      state.armColor[arm][pos] = color(255,255,255);
    }
  }
 
}


// ---------------------------------------- TextureLayer ----------------------------------------- 
// A MovableShape layer that renders with a texture

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

class TextureLayer extends MoveableShapeLayer {
  public color[] tex;

  TextureLayer(int _arm, color[] _tex, float _offset) {
    super(_arm, _offset);    
    tex = _tex;
  }

  // Render just copies the texture
  void render(color[] armColor, float offset, float scaling) {
    copy1DTexture(tex, armColor, offset);      // scaling ignored! because I haven't written a texture scaler... not hard, but...
  }
  
  float shapeWidth() {
    return tex.length;
  }
}


// ---------------------------------------- ColorRampLayer ----------------------------------------- 
// This is a MovableShapeLayer that renders a color ramp, with an arbitrary number of colors
// Each segment in the ramp is specified as RGBA,width.
// There is also an overall scaling, which is applied with the first vertex treated as the origin

class ColorVertex {
  color c;          // RGB and A used
  float w;          // width until next vertex. 
}


// Does anti-aliasing of non-uniformly spaced color ramps
// Ramp goes from 0 to rampLength, and is 100% intensity inside that, zero-alpha black outside.
// rampX contains cumulative X position of each vertex. Last element must = rampLength
color sampleRamp(ColorVertex[] ramp, float[] rampX, float rampLength, float start, float span) {

  // error checking
  assert(ramp.length>=2);
  assert(rampX[ramp.length-1] == rampLength);

  // first dispense with edge cases: not visible, or zero scaling
  if ((start >= rampLength) || (start + span < 0) || (span==0)) {
    return color(0,0,0,0);
  }

  float accum_r = 0, accum_g = 0, accum_b = 0, accum_a = 0;
  float pos = start;
  float end = start+span;

  // handle negative spans
  if (end < pos) {
    pos = end;
    end = start;
    span = abs(span);
  }   
  
  // nothing exists outside left edge
  if (pos<0)      
    pos=0;

  // We're going to scan across the ramp, from pos to end, intersecting against one segment at a time, 
  // with the following invariants:   
  //   rampX[vtxA] <= pos < rampX[vtxB]; 
  //   vtxB = vtxA + 1
  int vtxA = 0;
  int vtxB = 1;  
  while (pos >= rampX[vtxB]) {
    vtxA++;
    vtxB++;
  }
 
  assert(vtxB < ramp.length);
   

  // now add in each ramp segment, or part thereof
  while ((pos < end) && (vtxB < ramp.length)) {      // we'll break out on second condition if span exceeds right edge of ramp

    assert(rampX[vtxA] <= pos);
    assert(pos < rampX[vtxB]); 

    // Sample whole range between vertices, or just part?
    color color1, color2;
    float x2;
     
    // color at pos is a vertex color or somewhere between  
    if (pos == rampX[vtxA]) {
      color1 = ramp[vtxA].c;
    } else {
      color1 = lerpColor(ramp[vtxA].c, ramp[vtxB].c, (pos - rampX[vtxA]) / ramp[vtxA].w); 
    }
     
    // end is either past vtxB of this segment, or within it
    if (end >= rampX[vtxB]) {
      color2 = ramp[vtxB].c;     // end is past vtxB
      x2 = rampX[vtxB];
    } else {
      color2 = lerpColor(ramp[vtxA].c, ramp[vtxB].c, (end - rampX[vtxA]) / ramp[vtxA].w);  // end is before vtxB
      x2 = end;
    }
     
    // Add in the segment as the integral of the ramp between the two colors. 
    // Since the ramp is linear, this integral is just the mid point of the two colors times the width
//    accum += lerpColor(color1, color2, 0.5) * (x2-pos);    // operator +,+= doesn't work on Processing color type !
    accum_r += (red(color1) +  red(color2)) * (x2-pos)/2;
    accum_g += (green(color1) +  green(color2)) * (x2-pos)/2;
    accum_b += (blue(color1) +  blue(color2)) * (x2-pos)/2;
    accum_a += (alpha(color1) +  alpha(color2)) * (x2-pos)/2;
         
    // Advance pos up the point we've accumulated
    pos = x2; 
    vtxA++;
    vtxB++;
  }
   
  color accum = color(accum_r / span, accum_g / span, accum_b / span, accum_a / span);    // normalize, we want the average color over the span
  return accum;
}

class ColorRampLayer extends MoveableShapeLayer {
  
  ColorVertex[] ramp;
  float[] rampX;
  float rampLength;    // sum of vertices.w
  
  public float origin;       // this position (within the ramp) is fixed as the scaling increases 
  
  ColorRampLayer(int _arm, ColorVertex[] _ramp, float _position) {
    super(_arm, _position); 
    ramp = _ramp;
    scaling=1;
    origin=0;
    
    // Compute vertex positions and total ramp length
    rampLength=0;
    rampX = new float[ramp.length];
    rampX[0] = 0;
    for (int i=0; i<ramp.length-1; i++)  {    // NB we ignore w (width) of last vertex, because there's nothing after it
      rampLength += ramp[i].w;
      rampX[i+1] = rampLength;
    }
  }

  // Render steps through the ramp and samples the colors. 
  void render(color[] armColor, float offset, float scaling) {

    //println("scaling: " + scaling);
    
    for (int i=0; i<armColor.length; i++) {
      if (abs(scaling)>0.0001) {
        armColor[i] = sampleRamp(ramp, rampX, rampLength, ((i-offset)-origin)/scaling + origin, 1/scaling); 
      } else {
        armColor[i] = 0;
      }
    }
  }
  
  float shapeWidth() {
    return rampLength * scaling;
  }
}

// ---------------------------------------- DecayRaceLayer ----------------------------------------- 
// This is a very simple layer that races through an arm, turning on effects as it goes, then turning them off after a specified time
// It's the primitive used by manual fire control
class DecayRaceLayer extends ImageLayer {

  int arm;
  float raceTime;          // time between turning on the next effect 
  float decayTime;
  float startWait;
  
  int effectsOn;
  float nextEffectWait;
  float[] effectTimeRemaining;
  
  DecayRaceLayer(int _arm, float _raceTime, float _decayTime) {
    arm = _arm;
    raceTime = _raceTime;
    decayTime = _decayTime;
    startWait = 0;
    effectsOn = 0;
    nextEffectWait = 0;
    effectTimeRemaining = new float[armResolution(arm)];   
    
//    println("DecayRaceLayer - raceTime: " +  raceTime + ", decayTime: " + decayTime);  
  }
  
  // returns the fixture index of the effect with a given sequence number
  // currently, we step from inside to out
  int effectIndex(int seq) {
    return (armResolution(arm)-1) - seq;
  }
  
  void advance(float time) { 
 
    float timeRemaining = time;
    
    // first wait until we go
    if (startWait > 0) {
      startWait -= time;
      if (startWait < 0)
        timeRemaining = -startWait;
      else
        timeRemaining = 0;
    }      
    
    // keep firing events until no more are on (or we've hit end)
    while ((timeRemaining > 0) && (effectsOn < armResolution(arm))) {
    
        nextEffectWait -= timeRemaining;
        
        if (nextEffectWait <= 0) {
          // we've hit or passed the trigger time for the next effect
          state.armColor[arm][effectIndex(effectsOn)] = color(255,255,255);
          effectTimeRemaining[effectsOn] = decayTime;
          effectsOn++;
          
          timeRemaining = -nextEffectWait;
          nextEffectWait = raceTime;

        } else {          
          timeRemaining = 0;
        }
    }
  
    // Now advance the timing on all the effects, turning off any where the time remaning goes below zero
    int effectsStillOn = 0;
    
    for (int i=0; i<effectTimeRemaining.length; i++) {
      if (effectTimeRemaining[i] > 0) {
        effectsStillOn++;
       
        // found an effect on, count it down by time
        effectTimeRemaining[i] -= time;
        if (effectTimeRemaining[i] < 0) {
          state.armColor[arm][effectIndex(i)] = color(0,0,0);          
        }
      }
    }
    
    // if there are no effects on, yet we've turned them all on once, we're done
    if ((effectsStillOn == 0) && (effectsOn >= armResolution(arm)))
      finish();
  }

}

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 3
**   tab-width: 3
**   indent-tabs-mode: nil
** End:
**
** vim: softtabstop=3 tabstop=3 expandtab cindent shiftwidth=3
**
*/


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
    otherState.blendOverSelf(state, blendMode);
  }
}

/*
// TimedLayer automatically removes itself from the master layer after a specified number of steps have elapsed
// Used for things like single pulses that travels an arm and then is gone 
abstract class TimedLayer extends Layer {
  float curSteps;
  float totalSteps;
  
  TimedBehavior(float duration) {  // duration in steps
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
  float degreesPerStep;

  HueRotateLayer(color _baseColor, float _degreesPerStep) {
    baseColor = _baseColor;
    degreesPerStep = _degreesPerStep;
    startTime = curTimeInSteps();
  }

  void advance(float steps) {
    super.advance(steps);
    
    float phase = stepsSinceBirth*degreesPerStep;
     
    colorMode(HSB,360,100,100);
    state.fillArm(0, color((phase + hue(baseColor)) % 360, saturation(baseColor), brightness(baseColor)));
    state.fillArm(1, color((phase + hue(baseColor) + 120) % 360, saturation(baseColor), brightness(baseColor)));
    state.fillArm(2, color((phase + hue(baseColor) + 240) % 360, saturation(baseColor), brightness(baseColor)));
    colorMode(RGB);
  }
}

// ---------------------------------------- ChaseLayer ----------------------------------------- 

// ChaseLayer runs a sequence of colors up or down an arm. Linearly interpolates between colors as it moves.
//  - cubesPerStep controls speed, normally out->in, but can be negative for in->out. 
//  - startCube is the index of seq[0]. So -seq.length() if the head of the sequence starts at cube 0
// Terminates when the pattern falls completely off the end 
class ChaseLayer extends ImageLayer {
   color[] seq;
   float cubesPerStep;
   float offset;
   int arm;
   
   ChaseLayer(int _arm, color[] _seq, float _cubesPerStep, int startCube) {
     seq = _seq;
     cubesPerStep = _cubesPerStep;
     arm = _arm;
     offset = startCube;
     blendMode = ADD;
   }
 
 
   // Draw, then advance (so first frame is aligned with startCube)
   void advance(float steps) {
     super.advance(steps);
     
     // zero length seq protection
     if (seq.length < 1) {
       finished();
       return;
     }
    
     for (int i=0; i<state.armColor[arm].length; i++) {
       float seqIdx = i - offset;
       int floorIdx = floor(seqIdx);
       float fracIdx = seqIdx - floorIdx;
  
       if (seqIdx < -1) {

         // off start of seq, black
         state.armColor[arm][i] = 0;                  

       } else if (seqIdx < 0) {

         // within one cube of start, lerp from black to first color
         state.armColor[arm][i] = lerpColor(0, seq[0], seqIdx+1);

       } else if (floorIdx+1 < seq.length) {
         
         // between two elements of sequence, lerp
         state.armColor[arm][i] = lerpColor(seq[floorIdx], seq[floorIdx+1], fracIdx);
         
       } else if (floorIdx < seq.length) {
         
         // within one cube of end, lerp from last color to black 
         state.armColor[arm][i] = lerpColor(seq[seq.length-1], 0, fracIdx);
      
       } else { 
         
         // past the end
         state.armColor[arm][i] = 0;
       }
     
     } // for
  
     // animate
     offset += cubesPerStep * animationSpeed;
    
     // if the pattern is completely off the arm in the direction of travel, remove this layer
     if ( ((cubesPerStep > 0) && (offset >= state.armColor[arm].length)) ||
          ((cubesPerStep < 0) && (offset <= -seq.length)) ) {
       finish();
     }
    
   }

}



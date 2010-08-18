// wrapper function to make code more readable
int now(){
  return millis();
}

abstract class Behavior {
  Fixture fixture;
  int startTime;
  int state;
  boolean initialized = false;
  
  public static final int ACTIVE = 1; // Currently running
  public static final int INACTIVE = 0; // Waiting to run, or disabled
  public static final int COMPLETE = -1; // Execution finished, ready to be removed from execution queue
  
  int priority = 0;
  public int blendMode = REPLACE;
  
  void masterDrawFrame() {

    int currState = state();
    if (currState != ACTIVE) {
      if (currState == COMPLETE) {
        fixture.removeBehavior(this);
      }
      return;
    }
    else {
      
      if(!initialized){
        initialize();
        initialized = true;
      }

      drawFrame();
    }
  }
  
  void initialize() {
    return;
  }
  
  void drawFrame() {
    setColor(currentColor());
  }

  public int state() {
    return INACTIVE;
  }  

  /* 
   * Gets current color of fixture if fixture supports RGBColorMixing trait, otherwise returns white (255,255, 255)
   */
  public color currentColor() {
    if (fixture.traits.containsKey("RGBColorMixing")) {
      return ((RGBColorMixingTrait)fixture.trait("RGBColorMixing")).getColorRGB();
    }
    else {
      colorMode(RGB);
      return(color(255));
    }
  }
  
  /* 
   * Sets color of fixture if fixture supports RGBColorMixing trait; hides ugly Trait syntax
   */
  public void setColor(color value) {
    if (fixture.traits.containsKey("RGBColorMixing")) {
      color newColor = blendColor(currentColor(), value, blendMode);
      ((RGBColorMixingTrait)fixture.trait("RGBColorMixing")).setColorRGB(newColor);
    }
  }
  
}


abstract class TimedBehavior extends Behavior {
  int endTime;
  int duration;

  TimedBehavior(Fixture _fixture, int _priority, int _startTime, int _duration) {
    fixture = _fixture;
    startTime = _startTime;
    int overlap = (2 * int(1000/FRAMERATE)); // Hack: Add two frames to duration to ensure slight overlap between sequential behaviors. TODO: Find a better method to ensure behaviors chain properly.
    endTime = _startTime + _duration + overlap; 
    duration = _duration + overlap;
    priority = _priority;
    fixture.addBehavior(this, priority);
  }

  // If called with duration but no start time, use now() as start time.
  TimedBehavior(Fixture _fixture, int _priority, int _duration) {
    this(_fixture, _priority, now(), _duration);
  }

  // Program is "active" if scheduled start time has passed and behavior has not completed.
  public int state() {
    if (now() > startTime){
      if (proportionDone() < 1) {
        return ACTIVE;
      } 
      else {
        return COMPLETE;
      }
    }
    else {
      return INACTIVE;
    }
  }  

  // Returns proportion of scheduled duration already passed, as a value between 0 (not started) and 1 (complete).
  public float proportionDone() {
    int now = now();
    if (now > endTime) {
      return 1;
    }
    else if (now >= startTime) {
      return (float)(now - startTime) / duration;
    }
    else {
      return 0;
    }
  }
}

abstract class IndefiniteBehavior extends Behavior {

  int lastTime; // used by refresh()
  int refreshInterval; // used by refresh()


  IndefiniteBehavior(Fixture _fixture, int _priority, int _startTime) {
    fixture = _fixture;
    state = ACTIVE;
    startTime = _startTime;
    lastTime = startTime;
    priority = _priority;
    fixture.addBehavior(this, priority);
  }


  IndefiniteBehavior(Fixture _fixture, int _priority) {
    this(_fixture, _priority, now());
  }


  public int state() {
    if (now() >= startTime) {
      return state;
    }
    else {
      return INACTIVE;
    }
  }  


  /* Sets a refresh rate (in Hz) for this behavior, independently of the draw loop. See refresh() method below.
   * Note that the refresh rate of draw() sets an upper limit on the effective refresh rate.
   */
  public void setRate(float Hz) {
    refreshInterval = int(1000/Hz);
  }


  /*
   * Returns true with a frequency determined by the setRate() method above. Use this method if your behavior needs to refresh with consistent
   * timing at a rate below the current framerate. 
   */
  public boolean refresh() {

    // get current clock
    int now = now();

    // if now < lastTime, behavior still hasn't begun; return false. Otherwise...
    if (now >= lastTime) {

      // if the time difference between now and the last refresh is equal to the refresh interval or greater, we should refresh again
      boolean go = ((now - lastTime) >= refreshInterval);

      if (go) 
        lastTime = now; // we're refreshing, so time to update the timestamp for next time around

      return go; // either way, return go/no-go
    }
    else {
      return false;
    }
  }
}



/* ------------------------------------- Behavior Implementations ----------------------------------------- */

// SetColor: Sets fixture/group to supplied color value. If optional "sticky" flag is set true, refreshes 
// color every frame until behavior is cleared; otherwise sets color and clears itself.
class SetColor extends IndefiniteBehavior {

  color colorValue;
  boolean sticky;
  
  SetColor(Fixture _fixture, int _priority, int _startTime, color _colorValue, boolean _sticky){
    super(_fixture, _priority, _startTime);
    colorValue = _colorValue;
    sticky = _sticky;
  }
  
  SetColor(Fixture _fixture, int _priority, color _colorValue, boolean _sticky){
    this(_fixture, _priority, now(),_colorValue, _sticky);
  }
  
  SetColor(Fixture _fixture, int _priority, color _colorValue){
    this(_fixture, _priority, now(),_colorValue, false);
  }
  
  void initialize(){
    setColor(colorValue);
    if (!sticky) {
      state = COMPLETE;
    }
  }
  
  void drawFrame() {
    if(sticky){
      setColor(colorValue);
    }
  }
  
}



// FadeTo: Fades from current color of fixture to specified color over specified duration.
class FadeTo extends TimedBehavior {

  //Assign behavior-specific fields
  color startColor, endColor;

  //Behaviors should override both constructor signatures to support both immediate and scheduled invocation
  FadeTo (Fixture _fixture, int _priority, int _startTime, int _duration, color _endColor) {
    super(_fixture, _priority, _startTime, _duration);
    colorMode(RGB);
    endColor = _endColor;
  }

  FadeTo(Fixture _fixture, int _priority, int _duration, color _endColor) {
    this(_fixture, _priority, now(), _duration, _endColor);
  }

  void initialize(){
    startColor = currentColor();
  }

  void drawFrame() {
    
    colorMode(RGB);
    //set new color on fixture
    setColor(lerpColor(startColor, endColor,proportionDone()));

  }
}




class HueRotate extends IndefiniteBehavior {
  
  color current;

  int frame; // debugging - remove

  HueRotate(Fixture _fixture, int _priority, int _startTime) {
    super(_fixture, _priority, _startTime);
    setRate(30);
  }

  HueRotate(Fixture _fixture, int _priority) {
    this(_fixture, _priority, now());
  }

  void initialize(){
    // get current color from fixture
    current = currentColor();
  }

  void drawFrame() {

    if (refresh()) { // this behavior refreshes at a dependable rate set by setRate() in the constructor.

      // increment hue component by 1/4 degree
      colorMode(HSB,360,100,100);
      float newHue = (hue(current) + 0.25) % 360;
      color newColor = color(newHue, saturation(current), brightness(current));
 
      // set fixture to new color
      setColor(newColor);
      current = newColor;
    }
    else {
      setColor(current);
    }
    colorMode(RGB);
  }
}


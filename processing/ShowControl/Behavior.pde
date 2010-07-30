// wrapper function to make code more readable
int now(){
  return millis();
}

abstract class Behavior {
  Fixture fixture;
  int startTime;
  int state;
  
  public static final int ACTIVE = 1; // Currently running
  public static final int INACTIVE = 0; // Waiting to run, or disabled
  public static final int COMPLETE = -1; // Execution finished, ready to be removed from execution queue
  
  void masterDrawFrame(){
    if (state() != ACTIVE) {
      return;
    }
    else {
      drawFrame();
    }
  }
  
  void drawFrame() {
    return;
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
}


abstract class TimedBehavior extends Behavior {
  int endTime;
  int duration;

  TimedBehavior(Fixture _fixture, int _startTime, int _duration) {
    fixture = _fixture;
    startTime = _startTime;
    endTime = _startTime + _duration;
    duration = _duration;
  }

  // If called with duration but no start time, use current time from millis() as start time.
  TimedBehavior(Fixture _fixture, int _duration) {
    this(_fixture, now(), _duration);
  }

  // Program is "active" if scheduled start time has passed and behavior has not completed.
  public int state() {
    if (now() > startTime){
      if (proportionDone() <= 1) {
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

abstract class ConstantBehavior extends Behavior {

  int lastTime; // used by refresh()
  int refreshInterval; // used by refresh()


  ConstantBehavior(Fixture _fixture, int _startTime) {
    fixture = _fixture;
    state = ACTIVE;
    startTime = _startTime;
    lastTime = startTime;
  }


  ConstantBehavior(Fixture _fixture) {
    this(_fixture, now());
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

      // if the difference between now and the last time we refreshed is larger than the refresh interval, we should refresh again
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



/* ------------------------------------- Implementations ----------------------------------------- */

class FadeBehavior extends TimedBehavior {

  //Assign behavior-specific fields
  color startColor, endColor;

  //Timed behaviors should override both constructor signatures to support both immediate and scheduled invocation
  FadeBehavior (Fixture _fixture, int _startTime, int _duration, color _endColor) {
    super(_fixture, _startTime, _duration);
    colorMode(RGB);
    endColor = _endColor;
    startColor = currentColor();
  }

  FadeBehavior(Fixture _fixture, int _duration, color _endColor) {
    this(_fixture, millis(), _duration, _endColor);
  }

  public void drawFrame() {

    colorMode(HSB);

    float startHue, startSaturation, startValue;
    float endHue, endSaturation, endValue;
    float newHue, newSaturation, newValue;


    startValue = brightness(startColor);
    startSaturation = saturation(startColor);

    /*
     * if start hue is undefined (i.e., color is grayscale), 
     * peg start hue to end hue to avoid unexpected color shifts
     */
    if (startSaturation == 0 || startValue == 0) {
      startHue = hue(endColor);
    }
    else {
      startHue = hue(startColor);
    }

    endValue = brightness(endColor);
    endSaturation = hue(endColor);

    /*
     * if end hue is undefined (i.e., color is grayscale), 
     * peg end hue to start hue to avoid unexpected color shifts
     */
    if (endSaturation == 0 || endValue == 0) {
      endHue = hue(startColor);
    }
    else {
      endHue = hue(endColor);
    }

    //interpolate H, S and V values over elapsed time interval
    newValue = startValue + ((endValue - startValue) * proportionDone());
    newSaturation = startSaturation + ((endSaturation - startSaturation) * proportionDone());
    newHue = startHue + ((endHue - startHue) * proportionDone());

    //set new color on fixture
    ((RGBColorMixingTrait)fixture.trait("RGBColorMixing")).setColorRGB(color(newHue, newSaturation, newValue));

    //print("proportion done = " + proportionDone() + "\nhue = " + newHue + "\nsaturation = " + newSaturation + "\nvalue = " + newValue + "\n\n");
  }
}

class HueRotateBehavior extends ConstantBehavior {
  
  color current;

  //int frame; // debugging - remove

  HueRotateBehavior(Fixture _fixture, int _startTime) {
    super(_fixture, _startTime);
    setRate(30);
    //frame = 0; // debugging - remove
  }


  HueRotateBehavior(Fixture _fixture) {
    this(_fixture, now());
  }


  public void drawFrame() {

    //print(++frame + "\n\n"); // debugging - remove

    if (refresh()) { // this behavior refreshes at a dependable rate set by setRate() in the constructor.
      //frame = 0; // debugging - remove

      // get current color from fixture
      current = currentColor();

      // increment hue component by 1/4 degree
      colorMode(HSB,360,100,100);
      float newHue = (hue(current) + 0.25) % 360;
      color newColor = color(newHue, saturation(current), brightness(current));
 
      // set fixture to new color
      RGBColorMixingTrait trait = ((RGBColorMixingTrait)fixture.trait("RGBColorMixing"));
      trait.setColorRGB(newColor);

      // debugging - remove
      //print("time = " + millis() + "\nhue = " + newHue + "\nsaturation = " + saturation(current) + "\nvalue = " + brightness(current) + "\n\n");
    }
  }
}


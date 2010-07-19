/*

 An action is anything that happens with the light or fire at a discrete moment in time.
 It could be setting several lights to a particular color, arming a fire element, or 
 turning off all of the lights.  
 
 You can also do prolonged actions, like fades, using recursion...see below for example
 
 */

abstract class Action {
  //the notion of time here could be more sophisticated
  int timeToFire;

  void perform() {
    //does the action(s)
  }

  boolean isReady() {
    //returns yes if it's time to perform the action
    //if an action needs to fire early (for example to warm up a fire element) it should override this method
    return timeToFire <= currentBeat;
  }
}


class Blink extends Action {

  color RGBcolor;
  RGBColorMixingTrait colorTrait;
  Blink(int time, RGBColorMixingTrait t, color c) {
    timeToFire = time;
    colorTrait = t;
    RGBcolor = c;
  } 

  void perform() {
    if(events.fired("tick")){
      if (colorTrait.getColorRGB() == RGBcolor) {
        colorTrait.setColorRGB(color(0,0,0));
      } 
      else {
        colorTrait.setColorRGB(RGBcolor);
      }
    }
  }
}

//a test fade action
class Fade extends Action {
  RGBColorMixingTrait colorTrait;
  int increment;
  int initialHue;

  Fade(int time, RGBColorMixingTrait t, int h, int i) {
    timeToFire = time;
    colorTrait = t;
    initialHue = h;
    increment = i;
  } 

  void perform() {
    if(initialHue > 0) {
      color nextColor = color(initialHue,255,255);
      colorTrait.setColorRGB(nextColor);

      Fade nextAction = new Fade(timeToFire + 1, colorTrait, initialHue - increment, increment);
      waitingActions.add(nextAction);
    }
  }
}


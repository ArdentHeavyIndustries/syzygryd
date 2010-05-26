/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Animation
 */

/**
 * The Animation class represents an animation.
 */
abstract class Animation {
  abstract void step();
}

class ButtonPressAnimation extends Animation {
  DrawableTab tab;
  DrawableButton pressedButton;
  Vector surroundingButtons;
  int activeSteps;
  ButtonPressAnimation(DrawableTab _tab, DrawableButton _pressedButton) {
    super();
    tab = _tab;
    pressedButton = _pressedButton;
    surroundingButtons = new Vector(4);
    surroundingButtons.add(tab.getButtonFromTabCoords(pressedButton.row - 1, pressedButton.col)); // up
    surroundingButtons.add(tab.getButtonFromTabCoords(pressedButton.row + 1, pressedButton.col)); // down
    surroundingButtons.add(tab.getButtonFromTabCoords(pressedButton.row, pressedButton.col - 1)); // left
    surroundingButtons.add(tab.getButtonFromTabCoords(pressedButton.row, pressedButton.col + 1)); // right

    activeSteps = 10;

    animations.add(this);
  }

  void step() {
    activeSteps--;
    for (Enumeration e = surroundingButtons.elements(); e.hasMoreElements(); ) {
      DrawableButton b = (DrawableButton) e.nextElement();
      if (b != null) {
        b.activeAlpha = 3 * activeSteps;
      }
    }

    if (activeSteps <= 0) {
      animations.remove(this);
    }
  }
}




/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Animation
 */

/**
 * The Animation class represents an animation.
 */
abstract class Animation {
  boolean active;
  abstract void step();
}

class ButtonPressAnimation extends Animation {
  DrawableTab tab;
  DrawableButton pressedButton;
  DrawableButton[] surroundingButtons;
  int activeSteps;

  ButtonPressAnimation(DrawableTab _tab, DrawableButton _pressedButton) {
    super();
    active = true;
    tab = _tab;
    pressedButton = _pressedButton;

    surroundingButtons = new DrawableButton[4];
    surroundingButtons[0] = tab.getButtonFromTabCoords(pressedButton.row - 1, pressedButton.col); // up
    surroundingButtons[1] = tab.getButtonFromTabCoords(pressedButton.row + 1, pressedButton.col); // down
    surroundingButtons[2] = tab.getButtonFromTabCoords(pressedButton.row, pressedButton.col - 1); // left
    surroundingButtons[3] = tab.getButtonFromTabCoords(pressedButton.row, pressedButton.col + 1); // right

    activeSteps = 10;

    animations.add(this);
  }

  void step() {
    activeSteps--;
    for (int i = 0; i < 4; i++) {
      DrawableButton b = surroundingButtons[i];
      if (b != null) {
        b.activeAlpha = 3 * activeSteps;
      }
    }

    if (activeSteps <= 0) {
      active = false;
    }
  }
}




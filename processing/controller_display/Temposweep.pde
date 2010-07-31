/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Temposweep
 */
class Temposweep implements Drawable {
  int step=6;
  int startingX;
  float buttonSize, buttonSpacing;
  int buttonMargin;
  int maxDark = 40;

  Temposweep(float _buttonSize,  float _buttonSpacing) {
    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;
    startingX = int(_buttonSpacing);  // org
    buttonMargin = round((buttonSpacing-buttonSize));
  }

  void draw() {
    noStroke();
    for (int i = 0; i < 16; i++) {
      int follow = step - i;
      if (follow < 0) {
        follow += 16;
      }

      if (follow < 8) {
        fill(0, follow * (maxDark/8) + 10);
      } else {
        fill(0, maxDark + 10);
      }
  
      if (i == 15) {  // special parms for last column so it doesn't draw on the right frame - lots of fucking tweaks
        rect(5 + buttonMargin + (startingX)*i, 2 + buttonMargin, buttonSize - 6, 9* (buttonSpacing) + buttonSize); // lot of tweaks (ints) to make temposweep fit in the frame.
      }
      else {
      if (step != i) {  // alll the rest of the columns
//        rect((startingX)*i, 2, buttonSpacing, height);  -- orig
        rect(5 + buttonMargin + (startingX)*i, 2 + buttonMargin, buttonSize, 9* (buttonSpacing) + buttonSize); // lot of tweaks (ints) to make temposweep fit in the frame.
      }
    }
    }
  }


  void setValue(int _value) {
    step = _value;

    DrawableTab selectedTab = (DrawableTab) selectedPanel.selectedTab;
    int lastStep = step - 1 < 0 ? selectedTab.gridWidth - 1 : step - 1;
    for (int j = 0; j < selectedTab.gridHeight; j++) {
      DrawableButton thisStepButton = (DrawableButton) selectedTab.getButtonFromTabCoords(j, step);
      DrawableButton lastStepButton = (DrawableButton) selectedTab.getButtonFromTabCoords(j, lastStep);
      thisStepButton.isSweep = true;
      lastStepButton.isSweep = false;
    }
  }
}

























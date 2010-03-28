/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
/**
 * Tab
 */

class Tab {
  int id;
  Panel parent;
  int buttonSize, buttonSpacing;
  int buttonCount;
  Button[] buttons;

  Tab(int _id, Panel _parent, int _buttonSize, int _buttonSpacing) {
    id = _id;
    parent = _parent;

    buttonSize = _buttonSize;
    buttonSpacing = _buttonSpacing;
    buttons = new Button[parent.width * parent.height];
    buttonCount = 0;
  }
}
/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

/**
 * The SequencerButton class tracks pattern state required by the
 * sequencer, and sends notifications when the state of a button is
 * updated.
 */
class SequencerButton extends ToggleButton {
  SequencerButton(int _col, int _row, SequencerPatternTab _tab) {
    super(_col, _row, _tab);
    oscP5.plug(this, "setValue", getOscAddress());
  }

  /**
   * setValue turns the button on or off, and broadcasts a message
   * indicating the state change.  This method is intended to be
   * hooked up via osc.plug.
   *
   * @param value one of the constants Button.ON or Button.OFF
   */
  void setValue(float value) {
    OscMessage m = new OscMessage(getOscAddress());

    if (value != OFF) {
      isOn = true;
      m.add(ON);
    } else {
      isOn = false;
      m.add(OFF);
    }

    oscP5.send(m, globalClients);
  }
}

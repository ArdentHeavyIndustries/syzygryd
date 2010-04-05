/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

/**
 * The SequencerPatternTab class tracks pattern state required by the
 * sequencer.
 */
class SequencerPatternTab extends GridPatternTab {
  SequencerPatternTab(int _id, Panel _panel, int _gridWidth, int _gridHeight) {
    super(_id, _panel, _gridWidth, _gridHeight);

    for (int i = 0; i < gridWidth; i++) {
      for (int j = 0; j < gridHeight; j++) {
        SequencerButton b = new SequencerButton(i, j, this);
        buttons[i][j] = b;
      }
    }
  }
}

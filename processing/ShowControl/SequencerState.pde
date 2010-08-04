// The SequencerState object is used to store the total sequencer state, including timing statistics, for reference by lighting programs.

public class SequencerState {
  // modify these definitions to change number or dimensions of panels
  private final static int PANELS = 3;
  private final static int TABS = 4;
  private final static int STEPS = 16;
  private final static int PITCHES = 10;
  
  //timing information
  int curStep; // Number of current sequencer step.
  float stepPosition; // precise position within sequence
  double bpm;  // beats per minute
  double ppqPosition; // number of quarter notes since sequencer start
    
  // array to keep track of on/off notes
  public boolean[][][][] notes = new boolean[PANELS][TABS][STEPS][PITCHES];
    
  void SequencerState (){
    for (int panel = 1; panel <= PANELS; panel++) {
      for (int tab = 0; tab < TABS; tab++) {
        for (int step = 0; step < STEPS; step++) {
          for (int pitch = 0; pitch < PITCHES; pitch++) {
            notes[panel][tab][step][pitch] = false;
          }
        }
      }
    } 
  }
  
    
  /*
   * Returns time in milliseconds between beats at current BPM
   */ 
  public int beatInterval(){
    return int(round(60000/(float)bpm));
  }
  
 
  /*
   * Returns remaining time in milliseconds until next step will trigger
   */
  public int timeToStep(int step){
    int beatsPerStep = 4;
    float msPerBeat = 60000 / (float)bpm;
    float msPerStep = beatsPerStep * msPerBeat;
    float stepOffset = 0;
    if (step < curStep) {
      stepOffset = (STEPS - curStep) + step;
    } else {
      stepOffset = step - curStep;
    }
    return int(stepOffset * msPerStep);
  }
}

// The SequencerState object is used to store the total sequencer state, including timing statistics, for reference by lighting programs.

public class SequencerState {
  // modify these definitions to change number or dimensions of panels
  private final static int PANELS = 3;
  private final static int TABS = 4;
  private final static int STEPS = 16;
  private final static int PITCHES = 10;
  
  //timing information
  int nextStep; // Number of next sequencer step to be triggered (integer from 0 to 15). Add 1 to get controller's step numbering.
  int timeOfLastStep; // timestamp (in milliseconds since beginning of sketch) of last step
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
   * Returns absolute time (in milliseconds since beginning of sketch) when next step will trigger, based on current BPM
   */
  public int timeOfNextStep(){
    return timeOfLastStep + int(beatInterval()/4);
  }
  
  
  /*
   * Returns remaining time in milliseconds until next step will trigger
   */
  public int timeToNextStep(){
    return timeOfNextStep() - millis();
  }
}

// The SequencerState object is used to store the total sequencer state, including timing statistics, for reference by lighting programs.

public class SequencerState {
  // modify these definitions to change number or dimensions of panels
  private final static int PANELS = 3;
  private final static int TABS = 4;
  private final static int STEPS = 16;
  private final static int PITCHES = 10;
  
  // This will be used to calculate a rolling average of the OSC tick interval
  private Queue tickTimestamps;
    
  // array to keep track of on/off notes
  public boolean[][][][] notes = new boolean[PANELS][TABS][STEPS][PITCHES];
  
  // current tempo in BPS
  float tempoBPS;
  
  //current tick interval in ms
  float tickInterval;
  
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
}

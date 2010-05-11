/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
class NoteOffTask extends java.util.TimerTask {
  MidiBus midiBus;
  int channel;
  Vector notes;

  NoteOffTask(MidiBus _bus, int _channel, Vector _notes) {
    midiBus = _bus;
    channel = _channel;
    notes = _notes;
  }

  void run() {
    for (Enumeration e = notes.elements(); e.hasMoreElements(); ) {
      Integer note = (Integer)e.nextElement();
      //println("Killing note "+note+" on channel "+channel);
      midiBus.sendNoteOff(channel, note.intValue(), 128);
    }
  }
}

class MusicMaker implements StandardMidiListener {
  int clock, sixteenthNote, quarterNote, measure, pulseCompare, timeA, timeB;
  Sequencer sequencer;
  Timer noteOffTimer;
  MidiBus midiBus;
  long noteDuration;
  long masterbpm=120;

  MusicMaker(Sequencer _sequencer, MidiBus _bus) {
    sequencer = _sequencer;
    midiBus = _bus;
    resetCounters();
    noteOffTimer = new Timer();
    noteDuration = 125; //initial setting for 1/16 length on 120bpm
  }

  void playNotes(int channel, Vector notes) {
    NoteOffTask t = new NoteOffTask(midiBus, channel, notes);
    for (Enumeration e = notes.elements(); e.hasMoreElements(); ) {
      Integer note = (Integer)e.nextElement();
      //println("Playing note "+note+" on channel "+channel);
      midiBus.sendNoteOn(channel, note.intValue(), 128);
    }
    //change ms length of a 1/16 note dependent on calculated tempo
    noteOffTimer.schedule(t, 15000/masterbpm);
  }

  String songPosition() {
    return measure+"."+quarterNote+"."+sixteenthNote+"."+clock+" ";
  }

  int currentSixteenthNoteIndex() {
    return (quarterNote - 1) * 4 + (sixteenthNote - 1);
  }

  void handleClockPulse() {
    //calculating the beats per minute
    //24 pulses equals one beat in 4/4
    if (pulseCompare == 1) {
       timeA = millis();   
       // bpm to ms formula based off 1/32...  y=240000(1/32)/x
       masterbpm = 7500/(timeA-timeB);
       timeB = millis();
    }
    if (++pulseCompare > 3) {
     pulseCompare = 1;
    }
    
    //handling the sixteenth note index for sequencer
    if (clock == 1) {
      sequencer.gotBeat(currentSixteenthNoteIndex());
    }
    if (++clock > 6) {
      clock = 1;
      if (++sixteenthNote > 4) {
        sixteenthNote = 1;
        if (++quarterNote > 4) {
          quarterNote = 1;
          measure += 1;
        }
      }
    }
  }

  void resetCounters() {
    clock = 0;
    sixteenthNote = 1;
    quarterNote = 1;
    measure = 1;
  }

  void midiMessage(javax.sound.midi.MidiMessage message) {
    switch(message.getStatus()) {
    case 0xF8:
      // Timing Clock Message. Sent 24 times per quarter note when synchronization is required.
      handleClockPulse();
      break;

    case 0xFA:
      // Start. Starts the current sequence playing.
      resetCounters();
      println("Live started");
      break;

    case 0xFC:
      // looks like the incoming quarterNote is stopping
      println("Live stopped");
      break;

    case 0xF2:
      // Song position pointer. Data contains current song position.
      break;

    case 0x80: // Note off message, channel 0
    case 0x81: // Note off message, channel 1
    case 0x82: // Note off message, channel 2
      
    case 0x90: // Note on message, channel 0
    case 0x91: // Note on message, channel 1
    case 0x92: // Note on message, channel 2
      break;
    
    default:
      println("Unprocessed MIDI message, status = " + message.getStatus());
      break;
    }
  }
}

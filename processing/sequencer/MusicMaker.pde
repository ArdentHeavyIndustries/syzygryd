/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */
class NoteOffTask extends java.util.TimerTask {
  MidiBus midiBus;
  int channel;
  Vector notes;

  NoteOffTask(MidiBus aBus, int aChannel, Vector someNotes) {
    midiBus = aBus;
    channel = aChannel;
    notes = someNotes;
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
  int clock = 0, sixteenthNote = 1, quarterNote = 1, measure = 1;
  OscP5 oscP5 = null;
  Sequencer owner = null;
  Timer noteOffTimer = new Timer();
  MidiBus midiBus = null;
  long noteDuration = 200;

  MusicMaker(Sequencer anOwner, MidiBus aBus) {
    owner = anOwner;
    midiBus = aBus;
  }

  void playNotes(int channel, Vector notes) {
    NoteOffTask t = new NoteOffTask(midiBus, channel, notes);
    for (Enumeration e = notes.elements(); e.hasMoreElements(); ) {
      Integer note = (Integer)e.nextElement();
      //println("Playing note "+note+" on channel "+channel);
      midiBus.sendNoteOn(channel, note.intValue(), 128);
    }
    noteOffTimer.schedule(t, noteDuration);
  }

  String songPosition() {
    return measure+"."+quarterNote+"."+sixteenthNote+"."+clock+" ";
  }

  int currentSixteenthNoteIndex() {
    return (quarterNote - 1) * 4 + (sixteenthNote - 1);
  }

  void handleClockPulse() {
    if (clock == 1) {
      owner.gotBeat(currentSixteenthNoteIndex());
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





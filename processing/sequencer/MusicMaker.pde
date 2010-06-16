/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

class MusicMaker implements StandardMidiListener {
  int clock, sixteenthNote, quarterNote, measure, pulseCompare;
  int timeCur = 0;
  int timePrev = 0;
  Sequencer sequencer;
  MidiBus midiBus;
  //long noteDuration; // XXX not used?
  long masterbpm=120;

  // http://www.midi.org/techspecs/midimessages.php
  // Below is only the subset of MIDI messages that we expect to receive from Live.
  //
  // (For note off an on messages, the actual MIDI channel number is one
  // higher than the value used internally and in the control message.)
  // This message is sent when a note is released (ended).  
  private static final int NOTE_OFF_0            = 0x80;
  private static final int NOTE_OFF_1            = 0x81;
  private static final int NOTE_OFF_2            = 0x82;
  // This message is sent when a note is depressed (started).  
  private static final int NOTE_ON_0             = 0x90;
  private static final int NOTE_ON_1             = 0x91;
  private static final int NOTE_ON_2             = 0x92;
  //
  // This is an internal 14 bit register that holds the number of MIDI beats
  // (1 beat = six MIDI clocks) since the start of the song.
  private static final int SONG_POSITION_POINTER = 0xF2;
  // Sent 24 times per quarter note when synchronization is required.
  private static final int TIMING_CLOCK          = 0xF8;
  // Starts the current sequence playing.
  private static final int START                 = 0xFA;
  // Stop the current sequence
  private static final int STOP                  = 0xFC;
  //
  // These are for sending messages to Live (see allNotesOff())
  private static final int CHANNEL_MODE_MSG_0    = 0xB0;
  private static final int CHANNEL_MODE_MSG_1    = 0xB1;
  private static final int CHANNEL_MODE_MSG_2    = 0xB2;
  private static final int ALL_NOTES_OFF_DATA1   = 0x7B;
  private static final int ALL_NOTES_OFF_DATA2   = 0x00;

  MusicMaker(Sequencer _sequencer, MidiBus _bus) {
    sequencer = _sequencer;
    midiBus = _bus;
    resetCounters();
    //noteDuration = 125; //initial setting for 1/16 length on 120bpm
  }

  void playNotes(int channel, int[] notesOff, int[] notesOn) {
    for (int i = 0; i < notesOff.length; i++) {
      if (notesOff[i] == -1) {
        break;
      }
      midiBus.sendNoteOff(channel, notesOff[i], /* velocity */ 128);
    }

    for (int i = 0; i < notesOn.length; i++) {
      if (notesOn[i] == -1) {
        break;
      }
      midiBus.sendNoteOn(channel, notesOn[i], /* velocity */ 128);
    }
  }

  void allNotesOff() {
    // afaict, MidiBus has no way to send a channel mode message (which is not the same as a control change message)
    ShortMessage message = new ShortMessage();
    try {
      // it seems redundant specifying the channel both implicitly as part of the command, and explicit in the method
      message.setMessage(CHANNEL_MODE_MSG_0, /* channel */ 0, ALL_NOTES_OFF_DATA1, ALL_NOTES_OFF_DATA2);
      message.setMessage(CHANNEL_MODE_MSG_1, /* channel */ 1, ALL_NOTES_OFF_DATA1, ALL_NOTES_OFF_DATA2);
      message.setMessage(CHANNEL_MODE_MSG_2, /* channel */ 2, ALL_NOTES_OFF_DATA1, ALL_NOTES_OFF_DATA2);
    } catch (InvalidMidiDataException imde) {
      System.err.println("The status byte or all data bytes belonging to the message do not specify a valid MIDI message in allNotesOff(): " + imde);
    }
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
      timePrev = timeCur;
      timeCur = millis();
      // the first time this will be large, since timePrev is 0.
      // but since we're already placing an upper bound on the diff, we don't need to special case that.
      int timeDiff = timeCur - timePrev;
       if (timeDiff <= 7500) {
         // bug:25 - avoid divide by zero
         if (timeDiff > 0) {
           // bpm to ms formula based off 1/32...  y=240000(1/32)/x
           masterbpm = 7500/timeDiff;
           //println("setting masterbpm to " + masterbpm);
         } else {
           System.err.println("WARNING: non-positive time between clock pulses: " + timeDiff);
         }
       }
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

  void midiMessage(MidiMessage message) {
    switch(message.getStatus()) {
    case TIMING_CLOCK:
      handleClockPulse();
      break;

    case START:
      println("Live started");
      resetCounters();
      break;

    case STOP:
      println("Live stopped");
      sequencer.stopAllNotes();
      break;

    case SONG_POSITION_POINTER:
      break;

    case NOTE_OFF_0:
    case NOTE_OFF_1:
    case NOTE_OFF_2:
    case NOTE_ON_0:
    case NOTE_ON_1:
    case NOTE_ON_2:
      break;
    
    default:
      System.err.println("WARNING: Unexpected MIDI message: " + Integer.toHexString(message.getStatus()));
      break;
    }
  }
}

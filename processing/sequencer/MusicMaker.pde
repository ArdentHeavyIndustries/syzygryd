/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

class MusicMaker implements StandardMidiListener {
  int clock, sixteenthNote, quarterNote, measure, pulseCompare;
  int timeCur = 0;
  int timePrev = 0;
  Sequencer sequencer;
  MidiBus midiBus;
  long noteDuration;
  long masterbpm=120;

  MusicMaker(Sequencer _sequencer, MidiBus _bus) {
    sequencer = _sequencer;
    midiBus = _bus;
    resetCounters();
    noteDuration = 125; //initial setting for 1/16 length on 120bpm
  }

  void playNotes(int channel, int[] notesOff, int[] notesOn) {
    for (int i = 0; i < notesOff.length; i++) {
      if (notesOff[i] == -1) {
        break;
      }
      midiBus.sendNoteOff(channel, notesOff[i], 128);
    }

    for (int i = 0; i < notesOn.length; i++) {
      if (notesOn[i] == -1) {
        break;
      }
      midiBus.sendNoteOn(channel, notesOn[i], 128);
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

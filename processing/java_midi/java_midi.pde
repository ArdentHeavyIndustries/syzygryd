/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

// http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/package-summary.html

import javax.sound.midi.*;

void setup() {
  try {
    MidiDevice.Info[] deviceInfos = MidiSystem.getMidiDeviceInfo();
    println("there are " + deviceInfos.length + " available MIDI devices");
    for (int i = 0; i < deviceInfos.length; i++) {
      MidiDevice.Info deviceInfo = deviceInfos[i];
      println(i + ": " + deviceInfo.toString());
    }

    // we want In From MIDI Yoke: 2, which is empirically for me device 1, in the range [0-19]
    // XXX i suppose we could output the list then ask you to choose
    final int nDevice = 1;
    MidiDevice.Info deviceInfo = deviceInfos[nDevice];
    MidiDevice device = MidiSystem.getMidiDevice(deviceInfo);

    // XXX how to hook things up ???
    // XXX this doesn't work
    //Receiver receiver = device.getReceiver();
    // XXX this i think would allow us to transmit by hand to the MIDI In, which isn't what we want
    Transmitter transmitter = device.getTransmitter();
    device.open();
    println("device is open: " + device.isOpen());
    // XXX this device is not a sequencer
    println("device is a sequencer: " + (device instanceof Sequencer));
    // XXX this device is also not any of these
    println("device is a synthesizer: " + (device instanceof Synthesizer));
    println("device is a transmitter: " + (device instanceof Transmitter));
    println("device is a receiver: " + (device instanceof Receiver));
    // XXX the transmitter from the device is also not a sequencer
    // println("transmitter is a sequencer: " + (transmitter instanceof Sequencer));
    Sequencer sequencer = MidiSystem.getSequencer();
    // XXX this isn't what i want, it's "Real Time Sequencer", which is 18 for me.  how do i control this?
    println("sequencer is " + sequencer.getDeviceInfo().toString());
    Receiver receiver  = sequencer.getReceiver();
    transmitter.setReceiver(receiver);
    // http://java.sun.com/docs/books/tutorial/sound/MIDI-messages.html
    // XXX okay, maybe i finally have the chain
    // - the MIDI input sends to the transmitter
    // - the tramsitter delivers its messages to the receiver of the sequencer
    // XXX but it still doesn't work
    sequencer.open();
    println("sequencer is open: " + sequencer.isOpen());

    MyControllerEventListener listener = new MyControllerEventListener();
    // these are all of the possible ShortMessage codes:
    // int[] controllers = new int[] { ShortMessage.ACTIVE_SENSING,
    //                                 ShortMessage.CHANNEL_PRESSURE,
    //                                 ShortMessage.CONTINUE,
    //                                 ShortMessage.CONTROL_CHANGE,
    //                                 ShortMessage.END_OF_EXCLUSIVE,
    //                                 ShortMessage.MIDI_TIME_CODE,
    //                                 ShortMessage.NOTE_OFF,
    //                                 ShortMessage.NOTE_ON,
    //                                 ShortMessage.PITCH_BEND,
    //                                 ShortMessage.POLY_PRESSURE,
    //                                 ShortMessage.PROGRAM_CHANGE,
    //                                 ShortMessage.SONG_POSITION_POINTER,
    //                                 ShortMessage.SONG_SELECT,
    //                                 ShortMessage.START,
    //                                 ShortMessage.STOP,
    //                                 ShortMessage.SYSTEM_RESET,
    //                                 ShortMessage.TIMING_CLOCK,
    //                                 ShortMessage.TUNE_REQUEST };
    // XXX or does it mean midi channel numbers?
    int[] controllers = new int[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 };
    //int[] controllers = new int[] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 };

    int[] retVal = sequencer.addControllerEventListener(listener, controllers);
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < retVal.length; i++) {
      sb.append(" " + retVal[i]);
    }
    println(retVal.length + " controllers added:" + sb.toString());
    //sequencer.start();
  } catch (MidiUnavailableException mue) {
    System.err.println("WARNING: MIDI Unavailable: " + mue);
  }
  println("done setup()");
}


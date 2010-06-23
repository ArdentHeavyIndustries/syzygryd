/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

// http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/package-summary.html
// http://java.sun.com/docs/books/tutorial/sound/MIDI-messages.html
// http://www.midi.org/techspecs/midimessages.php

import javax.sound.midi.*;

void setup() {
  try {
    MidiDevice.Info[] deviceInfos = MidiSystem.getMidiDeviceInfo();
    println("there are " + deviceInfos.length + " available MIDI devices");
    for (int i = 0; i < deviceInfos.length; i++) {
      MidiDevice.Info deviceInfo = deviceInfos[i];
      println(i + ": " + deviceInfo.toString());
    }

    // in my (winxp) setup, we want "In From MIDI Yoke: 2", which is empirically for me device 1, in the range [0-19]
    // XXX i suppose we could output the list then ask you to choose
    final int nDevice = 1;
    MidiDevice.Info deviceInfo = deviceInfos[nDevice];
    println("opening device " + nDevice + ": " + deviceInfo.toString());
    MidiDevice device = MidiSystem.getMidiDevice(deviceInfo);

    // inspired by looking at themidibus source
    device.open();
    println("device is open: " + device.isOpen());
    MyReceiver receiver = new MyReceiver();
    Transmitter transmitter = device.getTransmitter();
    transmitter.setReceiver(receiver);

  } catch (MidiUnavailableException mue) {
    System.err.println("WARNING: MIDI Unavailable: " + mue);
  }
  println("done setup()");
}


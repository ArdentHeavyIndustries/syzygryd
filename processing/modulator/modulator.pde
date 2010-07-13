/* -*- mode: java; c-basic-offset: 3; indent-tabs-mode: nil -*- */

import syzygryd.*;

import guicomponents.*;
import oscP5.*;
import netP5.*;
import themidibus.*;
import javax.sound.midi.*;

class Modulator
   implements OscEventListener,	/* oscP5 */
              SimpleMidiListener	/* themidibus */
{
   OscP5 oscP5_;
   MidiBus[] midiBuses_;

   /* listeningPort is the port the server is listening for incoming messages */
   static final int listeningPort_ = 8001;
   
   /* the broadcast port is the port the clients should listen for
    * incoming messages from the server */
   static final int broadcastPort_ = 9001;

   Modulator(PApplet parent, int numPanels, String midiInputs[], String[] midiOutputs) {
      oscP5_ = new OscP5(/* parent */ this, listeningPort_);
      oscP5_.addListener(/* OscEventListener */ this);

      midiBuses_ = new MidiBus[numPanels];
      for (int i = 0; i < numPanels; i++) {
         println("Creating MidiBus[" + i + "]: IN:\"" + midiInputs[i] + "\" OUT:\"" + midiOutputs[i] + "\"");
         midiBuses_[i] = new MidiBus(/* PApplet */ parent, midiInputs[i], midiOutputs[i]);
         midiBuses_[i].addMidiListener(/* SimpleMidiListener */ this);
      }
   }
   
   /* OscEventListener */
   void oscEvent(OscMessage message) {
      println("oscEvent(): " + message.addrPattern() + " " + message.typetag() + " " + message.toString());
   }
           
   /* OscEventListener */
   void oscStatus(OscStatus status) {
      println("oscStatus(): " + status.id());
   }

   /* SimpleMidiListener */
   void controllerChange(int channel, int number, int value) {
      println("controllerChange(): channel=" + channel + " number=" + number + " value=" + value);
   }

   /* SimpleMidiListener */
   void noteOff(int channel, int pitch, int velocity) {
      println("noteOff(): channel=" + channel + " pitch=" + pitch + " velocity=" + velocity);
   }

   /* SimpleMidiListener */
   void noteOn(int channel, int pitch, int velocity) {
      println("noteOn(): channel=" + channel + " pitch=" + pitch + " velocity=" + velocity);
   }

}

Modulator m_;
//GCombo cboMidiInput_, cboMidiOutput_;
//GLabel labelMidiInput_, labelMidiOutput_;

void setup() {
   final int numPanels = 3;

   String[] availableIns = MidiBus.availableInputs();
   String[] availableOuts = MidiBus.availableOutputs();

   println("availableIns:");
   for (int i = 0; i < availableIns.length; i++) {
      println(availableIns[i]);
   }
   println("availableOuts:");
   for (int i = 0; i < availableOuts.length; i++) {
      println(availableOuts[i]);
   }

   // XXX for now i'm just going to hardcode this, but ultimately we need some way to select
   // XXX this could also be done (maybe more cleanly?) through device numbers, not names
   String[] midiInputs  = {"In From MIDI Yoke:  1",
                           "In From MIDI Yoke:  2",
                           "In From MIDI Yoke:  3"};
   String[] midiOutputs = {"Out To MIDI Yoke:  1",
                           "Out To MIDI Yoke:  2",
                           "Out To MIDI Yoke:  3"};

   // labelMidiInput_ = new GLabel(this, "Midi Input:", 0, 0, 65);
   // cboMidiInput_ = new GCombo(this, availableIns, 4, 65, 0, 130);
   // labelMidiOutput_ = new GLabel(this, "Midi Output:", 195, 0, 75);
   // cboMidiOutput_ = new GCombo(this, availableOuts, 4, 270, 0, 130);

   // // XXX presumably "GridSequencer" below needs to change ?
   
   // for (int i = 0; i < availableIns.length; i++) {
   //    if (availableIns[i].matches(".*GridSequencer.*") ||
   //        availableIns[i].matches("In From MIDI Yoke:  2")) {
   //       cboMidiInput_.setSelected(availableIns[i]);
   //       break;
   //    }
   // }
   
   // for (int i = 0; i < availableOuts.length; i++) {
   //    if (availableOuts[i].matches("GridSequencer") ||
   //        availableOuts[i].matches("Out To MIDI Yoke:  1")) {
   //       cboMidiOutput_.setSelected(availableOuts[i]);
   //       break;
   //    }
   // }
   
   m_ = new Modulator(this,
                      numPanels,
                      midiInputs,
                      midiOutputs);
}

void draw() {
   // XXX is there really nothing to do here? 
}


/* -*- mode: java; c-basic-offset: 3; indent-tabs-mode: nil -*- */

import syzygryd.*;

import guicomponents.*;
import oscP5.*;
import netP5.*;
import themidibus.*;

//import javax.sound.midi.*;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

class Modulator
   implements
      //OscEventListener,	/* oscP5 */
      SimpleMidiListener	/* themidibus */
{
   OscP5 oscP5_;
   MidiBus[] midiBuses_;

   /* listeningPort is the port the server is listening for incoming messages */
   static final int listeningPort_ = 8001;
   
   /* the broadcast port is the port the clients should listen for
    * incoming messages from the server */
   static final int broadcastPort_ = 9001;

   Pattern oscModulatorPattern_ =
      Pattern.compile("/(\\d+)_modulator/modulation(\\d+)");

   Modulator(PApplet parent, int numPanels, String midiInputs[], String[] midiOutputs) {
      oscP5_ = new OscP5(/* parent */ this, listeningPort_);
      //oscP5_.addListener(/* OscEventListener */ this);

      midiBuses_ = new MidiBus[numPanels];
      for (int i = 0; i < numPanels; i++) {
         println("Creating MidiBus[" + i + "]: IN:\"" + midiInputs[i] + "\" OUT:\"" + midiOutputs[i] + "\"");
         midiBuses_[i] = new MidiBus(/* PApplet */ parent, midiInputs[i], midiOutputs[i]);
         midiBuses_[i].addMidiListener(/* SimpleMidiListener */ this);
      }
   }
   
   /* (OscEventListener) */
   void oscEvent(OscMessage message) {
      System.out.println("oscEvent(): " + message.addrPattern() + " " + message.typetag() + " " + message.toString());

      // (unfortunately there are two not entirely consistent forms of documentation)
      // http://wiki.interpretivearson.com/index.php?title=Syzygryd:Teams:Musicians:OSCMIDISpecs
      // http://wiki.interpretivearson.com/index.php?title=Syzygryd:Teams:Sequencer:OSC_Messages
      // 
      // input OSC messages should all be of the form:
      //   /P_modulator/modulationM value
      // where P is in the range 1..numPanels
      // and M is in the range 1..10
      // the input value is in the range [0.0 .. 1.0]
      // we translate this to a MIDI control message
      //   the MIDI channel is the same as the panel number
      //   the controller number is in the range [0x2C .. 0x35], which is [44 .. 53]
      //   the value is in the range [0 .. 127]

      String oscAddr = message.addrPattern();
      Matcher matcher = oscModulatorPattern_.matcher(oscAddr);
      if (matcher.matches()) {
         try {
            int oscPanel = Integer.parseInt(matcher.group(1));
            int oscModulator = Integer.parseInt(matcher.group(2));
            if (message.checkTypetag("f")) {
               float oscValue = message.get(0).floatValue();
               System.out.println("received OSC: panel=" + oscPanel + " modulator=" + oscModulator + " value=" + oscValue);
               int midiChannel = oscPanel;
               int midiNumber = oscToMidiModulator(oscModulator);
               int midiValue = oscToMidiValue(oscValue);
               System.out.println("sending MIDI: channel=" + midiChannel + " number=" + midiNumber + " value=" + midiValue);
               midiBuses_[midiChannel - 1].sendControllerChange(midiChannel, midiNumber, midiValue);
            } else {
               System.err.println("WARNING: Unexpectd type tag (" + message.typetag()+ ") in OSC message: " + oscAddr);
            }
         } catch (NumberFormatException nfe) {
            System.err.println("WARNING: Unable to parse OSC message pattern: " + oscAddr);
         }
      } else {
         System.err.println("WARNING: Unexpected OSC message pattern: " + oscAddr);
      }
   }

   // /* OscEventListener */
   // void oscStatus(OscStatus status) {
   //    println("oscStatus(): " + status.id());
   // }

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

   int oscToMidiValue(float value) {
      return (int)(value * 127.0f);
   }

   float midiToOscValue(int value) {
      return (float)value / 127.0f;
   }

   int oscToMidiModulator(int modulator) {
      return modulator + 43;
   }

   int midiToOscModulator(int number) {
      return number - 43;
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


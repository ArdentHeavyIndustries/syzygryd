import syzygryd.*;

import guicomponents.*;
import oscP5.*;
import netP5.*;
import themidibus.*;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

class Modulator
   implements
      //OscEventListener,	/* oscP5 */
      SimpleMidiListener	/* themidibus */
{
   OscP5 oscP5_;					// for incoming OSC messages
   NetAddress oscBroadcast_;	// for outgoing OSC messages

   /* listeningPort is the port the server is listening for incoming messages */
   static final int listeningPort_ = 8001;
   
   /* broadcast outgoing messages to the entire subnet */
   static final String broadcastAddr_ = "255.255.255.255";
   /* the broadcast port is the port the clients should listen for
    * incoming messages from the server */
   static final int broadcastPort_ = 9001;

   Pattern oscSinglePattern_ =
      Pattern.compile("/(\\d+)_modulator/modulation(\\d+)");
   Pattern oscDoublePattern_ =
      Pattern.compile("/(\\d+)_modulator_xy/xy(\\d+)");

   MidiBus midiBus_;

   Set<String> pendingControllerChanges_;

   int directMidiControllerChannel_;	// bug:44

   Modulator(PApplet parent, String midiInput, String midiOutput, int channel) {
      // HashSet is *not* synchronized by default
      pendingControllerChanges_ = Collections.synchronizedSet(new HashSet<String>());

      setChannel(channel);
      
      // this takes care of calling oscEvent() regardless, so we don't need to
      // add a listener and implement the full interface in this case (unlike
      // for SimpleMidiListener)
      oscP5_ = new OscP5(/* parent */ this, listeningPort_);
      //oscP5_.addListener(/* OscEventListener */ this);

      oscBroadcast_ = new NetAddress(broadcastAddr_, broadcastPort_);

      System.out.println("Creating MidiBus: IN:\"" + midiInput + "\" OUT:\"" + midiOutput + "\"");
      midiBus_ = new MidiBus(/* PApplet */ parent, midiInput, midiOutput);
      midiBus_.addMidiListener(/* SimpleMidiListener */ this);
   }

   void setInput(String midiInput) {
      midiBus_.clearInputs();
      midiBus_.addInput(midiInput);
   }
   
   void setOutput(String midiOutput) {
      midiBus_.clearOutputs();
      midiBus_.addOutput(midiOutput);
   }
   
   void setChannel(int selected) {
      directMidiControllerChannel_ = selected + 1;
   }

   /* (OscEventListener) */
   void oscEvent(OscMessage message) {
      try {
         System.out.println("received (and rebroadcasting) oscEvent(): " + message.addrPattern() + " " + message.typetag() + " " + message.toString());

         // bug:64
         // immediately echo the message back out, don't rely on MIDI send/receive
         oscP5_.send(message, oscBroadcast_);

         // in general, input OSC messages should all be of the form:
         //   /C_modulator/modulationM value
         // or:
         //   /C_modulator_xy/xyM value1 value
         // where C is in the range 1..numController
         // and M is in the range 1..10
         // the input value(s) is in the range [0.0 .. 1.0]
         //
         // we translate this to a MIDI control message
         //   the MIDI channel is often (but not always) the same as the controller number
         //   - but note that themidibus starts counting at 0, not 1
         //   for controllers 1 through 4, the control number is in the range [0x2C .. 0x35], which is [44 .. 53]
         //   for controller 5, the MIDI control number is in the range [0x36 .. 0x39], which is [54 .. 57]
         //   the MIDI value is in the range [0 .. 127]
         //
         // for more complete details, see:
         // http://wiki.interpretivearson.com/index.php?title=Syzygryd:Teams:Musicians:OSCMIDISpecs

         String oscAddr = message.addrPattern();
         Matcher matcherSingle = oscSinglePattern_.matcher(oscAddr);
         if (matcherSingle.matches()) {
            try {
               int oscController = Integer.parseInt(matcherSingle.group(1));
               if (oscController >= 1 && oscController <= numControllers_) {
                  int oscModulator = Integer.parseInt(matcherSingle.group(2));
                  if (message.checkTypetag("f")) {
                     float oscValue = message.get(0).floatValue();
                     System.out.println("received OSC: controller=" + oscController + " modulator=" + oscModulator + " value=" + oscValue);
                     oscToMidiSendSingle(oscController, oscModulator, oscValue);
                  } else {
                     System.err.println("WARNING: Unexpected type tag (" + message.typetag() + ") in OSC message: " + oscAddr);
                  }
               } else {
                  System.err.println("WARNING: Unexpected controller number (" + oscController + ") in OSC message: " + oscAddr);
               }
            } catch (NumberFormatException nfe) {
               System.err.println("WARNING: Unable to parse OSC message pattern: " + oscAddr);
            }
         } else {
            // need to special case xy pad
            Matcher matcherDouble = oscDoublePattern_.matcher(oscAddr);
            if (matcherDouble.matches()) {
               try {
                  int oscController = Integer.parseInt(matcherDouble.group(1));
                  if (oscController >= 1 && oscController <= numControllers_ - 1) {	// the mixer does not have an xy pad
                     int oscModulator = Integer.parseInt(matcherDouble.group(2));
                     if (message.checkTypetag("ff")) {
                        float oscValueX = message.get(0).floatValue();
                        float oscValueY = message.get(1).floatValue();
                        // save values for later use by return path
                        x[oscController-1] = oscValueX;
                        y[oscController-1] = oscValueY;
                        System.out.println("received OSC: controller=" + oscController + " modulator=" + oscModulator + " valueX=" + oscValueX + " valueY=" + oscValueY);
                        int midiChannelX = oscControllerToMidiChannel(oscController, 9);
                        int midiChannelY = oscControllerToMidiChannel(oscController, 10);
                        int midiNumberX = oscToMidiModulator(oscController, 9);
                        int midiNumberY = oscToMidiModulator(oscController, 10);
                        int midiValueX = oscToMidiValue(oscValueX);
                        int midiValueY = oscToMidiValue(oscValueY);
                        System.out.println("sending MIDI: channel=" + midiChannelX + " number=" + midiNumberX + " value=" + midiValueX);
                        doSendControllerChange(midiChannelX, midiNumberX, midiValueX);
                        System.out.println("sending MIDI: channel=" + midiChannelY + " number=" + midiNumberY + " value=" + midiValueY);
                        doSendControllerChange(midiChannelY, midiNumberY, midiValueY);
                     } else {
                        System.err.println("WARNING: Unexpected type tag (" + message.typetag() + ") in OSC message: " + oscAddr);
                     }
                  } else {
                     System.err.println("WARNING: Unexpected controller number (" + oscController + ") in OSC message: " + oscAddr);
                  }
               } catch (NumberFormatException nfe) {
                  System.err.println("WARNING: Unable to parse OSC message pattern: " + oscAddr);
               }
            } else {
               System.err.println("WARNING: Unexpected OSC message pattern: " + oscAddr);
            }
         }
      } catch (Exception e) {
         System.err.println("WARNING: Caught exception " + e);
         e.printStackTrace();
      }
   }

   // broken out separately, b/c also used by keyPressed()
   void oscToMidiSendSingle(int oscController, int oscModulator, float oscValue) {
      int midiChannel = oscControllerToMidiChannel(oscController, oscModulator);
      int midiNumber = oscToMidiModulator(oscController, oscModulator);
      int midiValue = oscToMidiValue(oscValue);
      System.out.println("sending MIDI: channel=" + midiChannel + " number=" + midiNumber + " value=" + midiValue);
      doSendControllerChange(midiChannel, midiNumber, midiValue);
   }

   // /* OscEventListener */
   // not actually required b/c we're not implementing the full interface
   // void oscStatus(OscStatus status) {
   //    println("oscStatus(): " + status.id());
   // }

   String canonicalizeControllerChange(int channel, int number) {
      return channel + "-" + number;
   }

   void doSendControllerChange(int channel, int number, int value) {
      // bug:64
      // we're already rebroadcasting this back on OSC, and we don't trust the value received back from the MIDI send/receive loop.
      // so note that this has been sent, and we will ignore the next received MIDI controller change message for this channel/number pair.
      String id = canonicalizeControllerChange(channel, number);
      // each item in a set can only be present once
      System.out.println("Will ignore next MIDI controller change received from " + id);
      pendingControllerChanges_.add(id);
      midiBus_.sendControllerChange(channel, number, value);
   }

   /* SimpleMidiListener */
   void controllerChange(int channel, int number, int value) {
      System.out.println("received MIDI: channel=" + channel + " number=" + number + " value=" + value);

      // bug:64
      String id = canonicalizeControllerChange(channel, number);
      if (pendingControllerChanges_.contains(id)) {
         System.out.println("Ignoring MIDI controller change received from " + id);
         pendingControllerChanges_.remove(id);
         return;
      }

      if (channel >= 0 && channel < numControllers_) {
         if (number == 52 || number == 53) {
            // need to special case xy pad
            if (channel == numControllers_ - 1) {
               System.err.println("WARNING: MIDI controller number " + number + " corresponding to xy pad not expected on MIDI channel " + channel);
            } else {
               int oscController = midiChannelToOscController(channel, number);
               String oscAddr = "/" + oscController + "_modulator_xy/xy1";
               float oscValue = midiToOscValue(value);
               float oscValue1, oscValue2;
               if (number == 52) {
                  // X
                  oscValue1 = oscValue;
                  oscValue2 = y[oscController-1];	// send previous Y value
                  x[oscController-1] = oscValue1;	// save for next time
               } else {
                  // Y
                  oscValue1 = x[oscController-1];	// send previous X value
                  oscValue2 = oscValue;
                  y[oscController-1] = oscValue2;	// save for next time
               }
               System.out.println("sending OSC: address=" + oscAddr + " value1=" + oscValue1 + " value2=" + oscValue2);
               OscMessage message = new OscMessage(oscAddr);
               message.add(oscValue1);
               message.add(oscValue2);
               oscP5_.send(message, oscBroadcast_);
            }
         } else {
            int oscController = midiChannelToOscController(channel, number);
            int oscModulator = midiToOscModulator(channel, number);
            String oscAddr = "/" + oscController + "_modulator/modulation" + oscModulator;
            float oscValue = midiToOscValue(value);
            System.out.println("sending OSC: address=" + oscAddr + " value=" + oscValue);
            OscMessage message = new OscMessage(oscAddr);
            message.add(oscValue);
            oscP5_.send(message, oscBroadcast_);
         }
      } else {
         System.err.println("WARNING: Unexpected MIDI channel received: " + channel);
      }
   }

   /* SimpleMidiListener */
   // required to implement the interface, but we're not using
   void noteOff(int channel, int pitch, int velocity) {
      //println("noteOff(): channel=" + channel + " pitch=" + pitch + " velocity=" + velocity);
   }

   /* SimpleMidiListener */
   // required to implement the interface, but we're not using
   void noteOn(int channel, int pitch, int velocity) {
      //println("noteOn(): channel=" + channel + " pitch=" + pitch + " velocity=" + velocity);
   }

   // we start counting controllers at 1
   // it appears empirically that midi channels for themidibus start counting at 0
   int oscControllerToMidiChannel(int controller, int modulator) {
      if (controller != 5) {
         return controller - 1;
      } else {
         // the mixer is a special case
         if (modulator > 8) {
            return 4;	// really MIDI channel 5
         } else {
            return (modulator - 1) % 4;	// really MIDI channels 1 through 4, then repeat
         }
      }
   }
   int midiChannelToOscController(int channel, int number) {
      if (number < 54) {
         return channel + 1;
      } else {
         // the mixer is a special case
         return 5;
      }
   }

   int oscToMidiModulator(int controller, int modulator) {
      if (controller != 5) {
         return modulator + 43;
      } else {
         // the mixer is a special case
         if (modulator >= 9) {
            return modulator + 47;
         } else {
            return ((modulator - 1) / 4) + 54;
         }
      }
   }
   int midiToOscModulator(int channel, int number) {
      if (channel != 4 &&	// really MIDI channel 5
          number < 54) {
         return number - 43;
      } else {
         // the mixer is a special case
         if (number >= 56) {
            return number - 47;
         } else {
            return channel + 1 + ((number - 54) * 4);
         }
      }
   }

   int oscToMidiValue(float value) {
      return (int)(value * 127.0f);
   }
   float midiToOscValue(int value) {
      return (float)value / 127.0f;
   }

}

// (ugh) global variables

// 3 real controllers, plus backing tracks (4) and mixer (5)
final int numControllers_ = 5;
// xy pad not on mixer
float[] x = new float [numControllers_-1];
float[] y = new float [numControllers_-1];

Modulator m_;
GCombo comboIn_;
GCombo comboOut_;
GCombo comboChannel_;
boolean redraw = false;

void setup() {
   System.out.println("begin setup()");

   // just in case we have a return path for an xy pad value before we have
   // the corresponding (x or y) forward path, initialize to the middle of the
   // range
   for (int i = 0; i < numControllers_ - 2; i++) {
      x[i] = 0.5f;
      y[i] = 0.5f;
   }

   System.out.println("list:");
   MidiBus.list();
   System.out.println("\n");

   String[] availableIns = MidiBus.availableInputs();
   String[] availableOuts = MidiBus.availableOutputs();
   System.out.println("availableIns:");
   for (int i = 0; i < availableIns.length; i++) {
      System.out.println(availableIns[i]);
   }
   System.out.println("\n");
   System.out.println("availableOuts:");
   for (int i = 0; i < availableOuts.length; i++) {
      System.out.println(availableOuts[i]);
   }
   System.out.println("\n");

   String[] availableChannels = new String[numControllers_];
   for (int i = 0; i < numControllers_; i++) {
      availableChannels[i] = "" + (i+1);
   }

   int maxChoices = Math.max(Math.max(availableIns.length, availableOuts.length), availableChannels.length);
   // gui
   int dySmall = 20;
   int dyLarge = dySmall * maxChoices;
   int dxSmall = 10;
   int dxLarge = 200;

   size(4*dxSmall + 3*dxLarge, 2*dySmall + dyLarge);
   frameRate(10);
   redraw = true;

   // set default midi in/out
   // should be complements of whatever Ableton Live is set to
   // XXX should probably change these defaults for the mac to be different from each other, but i'm not sure what they should be
   String s_defaultMacMidiInput1 = "GridSequencer";
   String s_defaultMacMidiInput2  = "IAC Driver - Bus 1";
   String s_defaultMacMidiOutput1 = "GridSequencer";
   String s_defaultMacMidiOutput2 = "IAC Driver - Bus 1";
   String s_defaultWinMidiInput  = "In From MIDI Yoke:  2";
   String s_defaultWinMidiOutput = "Out To MIDI Yoke:  1";
   // if all else fails, just take the first choices
   int i_defaultMidiInput = 0;
   int i_defaultMidiOutput = 0;
   for (int i = 0; i < availableIns.length; i++) {
      if (availableIns[i].equals(s_defaultMacMidiInput1) ||
          availableIns[i].equals(s_defaultMacMidiInput2) ||
          availableIns[i].equals(s_defaultWinMidiInput)) {
         i_defaultMidiInput = i;
         System.out.println("Setting default input for to " + i + ": " + availableIns[i]);
         break;
      }
   }

   for (int i = 0; i < availableOuts.length; i++) {
      if (availableOuts[i].equals(s_defaultMacMidiOutput1) ||
          availableOuts[i].equals(s_defaultMacMidiOutput2) ||
          availableOuts[i].equals(s_defaultWinMidiOutput)) {
         System.out.println("Setting default output to " + i + ": " + availableOuts[i]);
         i_defaultMidiOutput = i;
         break;
      }
   }

   GLabel labelIn  = new GLabel(this, "MIDI Input", dxSmall, dySmall, dxLarge);
   GLabel labelOut = new GLabel(this, "MIDI Output", 2*dxSmall + dxLarge, dySmall, dxLarge);
   GLabel labelChannel = new GLabel(this, "Controller Channel", 3*dxSmall + 2*dxLarge, dySmall, dxLarge);
   comboIn_ = new GCombo(this, availableIns, maxChoices, dxSmall, 2*dySmall, dxLarge);
   comboOut_ = new GCombo(this, availableOuts, maxChoices, 2*dxSmall + dxLarge, 2*dySmall, dxLarge);
   comboChannel_ = new GCombo(this, availableChannels, maxChoices, 3*dxSmall + 2*dxLarge, 2*dySmall, dxLarge);
   comboIn_.setSelected(i_defaultMidiInput);
   comboOut_.setSelected(i_defaultMidiOutput);
   comboChannel_.setSelected(0);	// this is actually channel "1"

   m_ = new Modulator(this,
                      comboIn_.selectedText(),
                      comboOut_.selectedText(),
                      comboChannel_.selectedIndex());

   // for testing only, see comments below
   //testMidiToOsc(m_);

   System.out.println("end setup()");
}

void draw() {
   if (redraw) {
      background(0, 255, 255); // cyan
      redraw = false;
   }
}

void handleComboEvents(GCombo combo) {
   if (combo == comboIn_) {
      System.out.println("Selected combo in with index " + combo.selectedIndex() + " and text \"" + combo.selectedText() + "\"");
      m_.setInput(combo.selectedText());
   } else if (combo == comboOut_) {
      System.out.println("Selected combo out with index " + combo.selectedIndex() + " and text \"" + combo.selectedText() + "\"");
      m_.setOutput(combo.selectedText());
   } else if (combo == comboChannel_) {
      System.out.println("Selected direct MIDI controller channel " + combo.selectedIndex());
      m_.setChannel(combo.selectedIndex());
   } else {
      System.err.println("WARNING: Received unexpected combo in callback");
   }
   combo.shrink();
   redraw = true;
}

// these aren't used, but without then processing spews a bit on initialization

void handleOptionEvents(GOption selected, GOption deselected) {
}

void handleSliderEvents(GSlider slider) {
}

// bug:44
void keyPressed() {
   int oscController = m_.directMidiControllerChannel_;

   int oscModulator = -1;
   if (key == '1') {
      oscModulator = 1;
   } else if (key == '2') {
      oscModulator = 2;
   } else if (key == '3') {
      oscModulator = 3;
   } else if (key == '4') {
      oscModulator = 4;
   } else if (key == '5') {
      oscModulator = 5;
   } else if (key == '6') {
      oscModulator = 6;
   } else if (key == '7') {
      oscModulator = 7;
   } else if (key == '8') {
      oscModulator = 8;
   } else if (key == '9') {
      oscModulator = 9;
   } else if (key == '0') {
      oscModulator = 10;
   }

   if (oscModulator == -1) {
      // some other key pressed
      return;
   }

   // the value is arbitrary, so pick in the middle
   float oscValue = 0.5f;
   
   System.out.println("Sending MIDI controller change for controller=" + oscController + " (based on pulldown), modulator=" + oscModulator + " (based on keypress), value=" + oscValue + " (arbitrary)");
   m_.oscToMidiSendSingle(oscController, oscModulator, oscValue);
}


// for testing osc to midi, see oscToMidi.notes
// send with SendOSC, and look at output on processing console
// XXX i suppose this wouldn't be necessary if i had a set of command line tools for SendMIDI and DumpMIDI
// void testMidiToOsc(Modulator m) {
//    for (int channel = 0; channel <=3; channel++) {
//       for (int number = 44; number <= 53; number++) {
//          m.controllerChange(channel, number, 32);
//       }
//    }
//    m.controllerChange(0, 54, 13);
//    m.controllerChange(1, 54, 26);
//    m.controllerChange(2, 54, 38);
//    m.controllerChange(3, 54, 51);
//    m.controllerChange(0, 55, 64);
//    m.controllerChange(1, 55, 77);
//    m.controllerChange(2, 55, 90);
//    m.controllerChange(3, 55, 102);
//    m.controllerChange(4, 56, 115);
//    m.controllerChange(4, 57, 128);
// }

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 3
**   tab-width: 3
**   indent-tabs-mode: nil
** End:
**
** vim: softtabstop=3 tabstop=3 expandtab cindent shiftwidth=3
**
*/

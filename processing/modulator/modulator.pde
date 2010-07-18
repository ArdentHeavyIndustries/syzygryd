/* -*- mode: java; c-basic-offset: 3; indent-tabs-mode: nil -*- */

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

   Pattern oscModulatorPattern_ =
      Pattern.compile("/(\\d+)_modulator/modulation(\\d+)");

   MidiBus[] midiBuses_;

   Modulator(PApplet parent, String midiInputs[], String[] midiOutputs) {
      // this takes care of calling oscEvent() regardless, so we don't need to
      // add a listener and implement the full interface in this case (unlike
      // for SimpleMidiListener)
      oscP5_ = new OscP5(/* parent */ this, listeningPort_);
      //oscP5_.addListener(/* OscEventListener */ this);

      oscBroadcast_ = new NetAddress(broadcastAddr_, broadcastPort_);

      midiBuses_ = new MidiBus[numPanels_];
      for (int i = 0; i < numPanels_; i++) {
         println("Creating MidiBus[" + i + "]: IN:\"" + midiInputs[i] + "\" OUT:\"" + midiOutputs[i] + "\"");
         midiBuses_[i] = new MidiBus(/* PApplet */ parent, midiInputs[i], midiOutputs[i]);
         midiBuses_[i].addMidiListener(/* SimpleMidiListener */ this);
      }
   }

   void setInput(int panel, String midiInput) {
      midiBuses_[panel].clearInputs();
      midiBuses_[panel].addInput(midiInput);
   }
   
   void setOutput(int panel, String midiOutput) {
      midiBuses_[panel].clearOutputs();
      midiBuses_[panel].addOutput(midiOutput);
   }
   
   /* (OscEventListener) */
   void oscEvent(OscMessage message) {
      try {
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
         //   the MIDI channel is the same as the panel number (XXX see below, i think themidibus uses one less)
         //   the controller number is in the range [0x2C .. 0x35], which is [44 .. 53]
         //   the value is in the range [0 .. 127]

         String oscAddr = message.addrPattern();
         Matcher matcher = oscModulatorPattern_.matcher(oscAddr);
         if (matcher.matches()) {
            try {
               int oscPanel = Integer.parseInt(matcher.group(1));
               if (oscPanel >= 1 && oscPanel <= numPanels_) {
                  int oscModulator = Integer.parseInt(matcher.group(2));
                  if (message.checkTypetag("f")) {
                     float oscValue = message.get(0).floatValue();
                     System.out.println("received OSC: panel=" + oscPanel + " modulator=" + oscModulator + " value=" + oscValue);
                     int midiChannel = oscPanelToMidiChannel(oscPanel);
                     int midiNumber = oscToMidiModulator(oscModulator);
                     int midiValue = oscToMidiValue(oscValue);
                     System.out.println("sending MIDI: channel=" + midiChannel + " number=" + midiNumber + " value=" + midiValue);
                     // array index out of bounds exception: -1
                     midiBuses_[midiChannel - 1].sendControllerChange(midiChannel, midiNumber, midiValue);
                  } else {
                     System.err.println("WARNING: Unexpectd type tag (" + message.typetag() + ") in OSC message: " + oscAddr);
                  }
               } else {
                  System.err.println("WARNING: Unexpected panel number (" + oscPanel + ") in OSC message: " + oscAddr);
               }
            } catch (NumberFormatException nfe) {
               System.err.println("WARNING: Unable to parse OSC message pattern: " + oscAddr);
            }
         } else {
            System.err.println("WARNING: Unexpected OSC message pattern: " + oscAddr);
         }
      } catch (Exception e) {
         System.err.println("WARNING: Caught exception " + e);
         e.printStackTrace();
      }
   }

   // /* OscEventListener */
   // not actually required b/c we're not implementing the full interface
   // void oscStatus(OscStatus status) {
   //    println("oscStatus(): " + status.id());
   // }

   /* SimpleMidiListener */
   void controllerChange(int channel, int number, int value) {
      System.out.println("received MIDI: channel=" + channel + " number=" + number + " value=" + value);
      if (channel >= 1 && channel <= numPanels_) {
         int oscPanel = midiChannelToOscPanel(channel);
         int oscModulator = midiToOscModulator(number);
         String oscAddr = "/" + oscPanel + "_modulator/modulation" + oscModulator;
         float oscValue = midiToOscValue(value);
         System.out.println("sending OSC: address=" + oscAddr + " value=" + oscValue);
         OscMessage message = new OscMessage(oscAddr);
         message.add(oscValue);
         oscP5_.send(message, oscBroadcast_);
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

   // we start counting panels at 1
   // it appears empirically that midi channels for themidibus start counting at 0
   int oscPanelToMidiChannel(int panel) {
      return panel - 1;
   }
   int midiChannelToOscPanel(int channel) {
      return channel + 1;
   }

   int oscToMidiModulator(int modulator) {
      return modulator + 43;
   }
   int midiToOscModulator(int number) {
      return number - 43;
   }

   int oscToMidiValue(float value) {
      return (int)(value * 127.0f);
   }
   float midiToOscValue(int value) {
      return (float)value / 127.0f;
   }

}

// (ugh) global variables
final int numPanels_ = 3;
Modulator m_;
GCombo[] combosIn_;
GCombo[] combosOut_;

void setup() {
   System.out.println("begin setup()");

   // gui
   int maxChoices = 10;
   int dySmall = 20;
   int dyLarge = dySmall * maxChoices;
   int dxSmall = 10;
   int dxLarge = 200;
   
   size(3*dxSmall + 2*dxLarge, 5*dySmall + 3*dyLarge);

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

   // set default midi in/out
   // (we could also hardcode this to whatever the mac wants)
   String[] s_defaultMidiInputs  = new String[numPanels_];
   String[] s_defaultMidiOutputs = new String[numPanels_];
   int[] i_defaultMidiInputs = new int[numPanels_];
   int[] i_defaultMidiOutputs = new int[numPanels_];
   for (int i = 0; i < numPanels_; i++) {
      s_defaultMidiInputs[i] = new String("In From MIDI Yoke:  " + (i+1));
      s_defaultMidiOutputs[i] = new String("Out To MIDI Yoke:  " + (i+1));
      //IN:
      for (int j = 0; j < availableIns.length; j++) {
         if (s_defaultMidiInputs[i].equals(availableIns[j])) {
            i_defaultMidiInputs[i] = j;
            System.out.println("Setting default input for panel " + i + " to " + j + ": " + availableIns[j]);
            //break IN;
            j = availableIns.length;
         }
      }
      //OUT:
      for (int j = 0; j < availableOuts.length; j++) {
         if (s_defaultMidiOutputs[i].equals(availableOuts[j])) {
            System.out.println("Setting default output for panel " + i + " to " + j + ": " + availableOuts[j]);
            i_defaultMidiOutputs[i] = j;
            //break OUT;
            j = availableOuts.length;
         }
      }
   }

   GLabel[] labelsIn  = new GLabel[numPanels_];
   GLabel[] labelsOut = new GLabel[numPanels_];
   combosIn_  = new GCombo[numPanels_];
   combosOut_ = new GCombo[numPanels_];

   for (int i = 0; i < numPanels_; i++) {
      labelsIn[i]  = new GLabel(this, "Panel " + (i+1) + " MIDI Input", dxSmall, dySmall + i*(dySmall+dyLarge), dxLarge);
      labelsOut[i]  = new GLabel(this, "Panel " + (i+1) + " MIDI Output", 2*dxSmall + dxLarge, dySmall + i*(dySmall+dyLarge), dxLarge);
      combosIn_[i] = new GCombo(this, availableIns, maxChoices, dxSmall, 2*dySmall + i*(dySmall+dyLarge), dxLarge);
      combosOut_[i] = new GCombo(this, availableOuts, maxChoices, 2*dxSmall + dxLarge, 2*dySmall + i*(dySmall+dyLarge), dxLarge);
      combosIn_[i].setSelected(i_defaultMidiInputs[i]);
      combosOut_[i].setSelected(i_defaultMidiOutputs[i]);
   }

   m_ = new Modulator(this,
                      s_defaultMidiInputs,
                      s_defaultMidiOutputs);

   System.out.println("end setup()");
}

void draw() {
   background(0, 255, 255); // cyan
}

void handleComboEvents(GCombo combo) {
   for (int i = 0; i < numPanels_; i++) {
      if (combo == combosIn_[i]) {
         System.out.println("Selected combo in " + i + " with index " + combo.selectedIndex() + " and text \"" + combo.selectedText() + "\"");
         m_.setInput(i, combo.selectedText());
         break;
      } else if (combo == combosOut_[i]) {
         System.out.println("Selected combo out " + i + " with index " + combo.selectedIndex() + " and text \"" + combo.selectedText() + "\"");
         m_.setOutput(i, combo.selectedText());
         break;
      }
   }
}

// these aren't used, but without then processing spews a bit on initialization

void handleOptionEvents(GOption selected, GOption deselected) {
}

void handleSliderEvents(GSlider slider) {
}

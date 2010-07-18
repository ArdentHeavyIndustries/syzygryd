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

   MidiBus midiBus_;

   Modulator(PApplet parent, String midiInput, String midiOutput) {
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
                     midiBus_.sendControllerChange(midiChannel, midiNumber, midiValue);
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
      if (channel >= 0 && channel < numPanels_) {
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

// 3 real controllers, plus backing tracks (4) and mixer (5)
final int numPanels_ = 5;
Modulator m_;
GCombo comboIn_;
GCombo comboOut_;
boolean redraw = false;

void setup() {
   System.out.println("begin setup()");

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

   int maxChoices = Math.max(availableIns.length, availableOuts.length);
   // gui
   int dySmall = 20;
   int dyLarge = dySmall * maxChoices;
   int dxSmall = 10;
   int dxLarge = 200;
   
   size(3*dxSmall + 2*dxLarge, 2*dySmall + dyLarge);
   redraw = true;

   // set default midi in/out
   // should be complements of whatever Ableton Live is set to
   String s_defaultWinMidiInput  = "In From MIDI Yoke:  2";
   String s_defaultWinMidiOutput = "Out To MIDI Yoke:  1";
   // XXX this needs to be verified
   String s_defaultMacMidiInput  = "IAC Driver Bus 1";
   String s_defaultMacMidiOutput = "IAC Driver Bus 1";
   // if all else fails, just take the first choices
   int i_defaultMidiInput = 1;
   int i_defaultMidiOutput = 1;
   for (int i = 0; i < availableIns.length; i++) {
      if (availableIns[i].equals(s_defaultMacMidiInput) ||
          availableIns[i].equals(s_defaultWinMidiInput)) {
         i_defaultMidiInput = i;
         System.out.println("Setting default input for to " + i + ": " + availableIns[i]);
         break;
      }
   }

   for (int i = 0; i < availableOuts.length; i++) {
      if (availableOuts[i].equals(s_defaultMacMidiOutput) ||
          availableOuts[i].equals(s_defaultWinMidiOutput)) {
         System.out.println("Setting default output to " + i + ": " + availableOuts[i]);
         i_defaultMidiOutput = i;
         break;
      }
   }

   GLabel labelIn  = new GLabel(this, "MIDI Input", dxSmall, dySmall, dxLarge);
   GLabel labelOut = new GLabel(this, "MIDI Output", 2*dxSmall + dxLarge, dySmall, dxLarge);
   comboIn_ = new GCombo(this, availableIns, maxChoices, dxSmall, 2*dySmall, dxLarge);
   comboOut_ = new GCombo(this, availableOuts, maxChoices, 2*dxSmall + dxLarge, 2*dySmall, dxLarge);
   comboIn_.setSelected(i_defaultMidiInput);
   comboOut_.setSelected(i_defaultMidiOutput);

   m_ = new Modulator(this,
                      comboIn_.selectedText(),
                      comboOut_.selectedText());

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

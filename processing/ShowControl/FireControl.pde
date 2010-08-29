// FireControl
// Processes OSC messsages, runs manual fire control

// Global state
int fcPooferOnTime;
boolean fcPooferOn = false;
int fcFanOnTime;

// UI state mirrors
float fcUIPooferDuration = 0.5;  // seconds
boolean fcUITornadoFan = false;
boolean fcUITornadoReady = false;
boolean fcUITornadoFuel = false;
int fcUIArm = 0;
boolean fcUIEffects[] = {false, false, false, false, false, false, false, false};

// Initialize just puts the touchOSC in a coherent state
// globals, above, need to start with poofer, ready, fan, tornado all off
void fireControlInitialize() {
  sendTouchOSCMsg("/fireControl/poofer", false);
  sendTouchOSCMsg("/fireControl/pooferDuration", fcUIPooferDuration);
  sendTouchOSCMsg("/fireControl/pooferDurationLabel", "duration " + roundTo2Places(fcUIPooferDuration) + " seconds");  
  sendTouchOSCMsg("/fireControl/tornadoFan", fcUITornadoFan);
  sendTouchOSCMsg("/fireControl/tornadoReady", false);
  sendTouchOSCMsg("/fireControl/tornadoFuel", false);
  updateArmRadioButtons();    
  for (int i=0; i<8; i++)
    sendTouchOSCMsg("/fireControl/effect" + i, false);
}

// Constants
float FAN_WARMUP_TIME = 5000;  // ms after fan on before fuel can go on

int POOFER_DMX_ADDR = 144;
int TORNADO_FAN_DMX_ADDR = 145;
int TORNADO_FUEL_DMX_ADDR = 146;

int FIRE_DMX_MAGIC = 85;     // fire control board closes relays only when it sees this DMX value

int flameEffectDMXAddr(int arm, int effect) {
  return 117 + arm*8 + effect;
} 

float roundTo2Places(float v) {
  return floor(v*10 + 0.5) / 10.0;
}

void processOSCFireEvent(OscMessage m) {

 println("FC OSC: " + m.addrPattern());
  
  println("ok!");
  
  for (int i=0; i<8; i++) {
    println("testing: " + "/fireControl/effect" + i);
    if (m.addrPattern().startsWith("/fireControl/effect" + i)) {
      fcUIEffects[i] = m.get(0).floatValue() != 0;
      println("fcUIEffects[i]: " + fcUIEffects[i]);
      fireDMX(flameEffectDMXAddr(fcUIArm, i), fcUIEffects[i]);       
    }
  }  

  if (m.addrPattern().startsWith("/fireControl/pooferButton")) {
    events.fire("poofer");
  } 
  
  else if (m.addrPattern().startsWith("/fireControl/pooferDuration")) {
    fcUIPooferDuration = m.get(0).floatValue();
    sendTouchOSCMsg("/fireControl/pooferDurationLabel", "duration " + roundTo2Places(fcUIPooferDuration) + " seconds");  
  } 
 
  else if (m.addrPattern().startsWith("/fireControl/tornadoFan")) {
    // when the fan turns on, note the time
    boolean newFanOn = m.get(0).floatValue() != 0;
    
    if (newFanOn && !fcUITornadoFan) {
      fcFanOnTime = now();                                   // fan going on, note time
//     println("turning on fan");
    } else if (!newFanOn && fcUITornadoReady) {
      fcUITornadoReady = false;
      fcUITornadoFuel = false;      
      sendTouchOSCMsg("/fireControl/tornadoReady", false);   // fan went off, turn off ready light and poofer
      sendTouchOSCMsg("/fireControl/tornadoFuel", false);
    }
    
    fcUITornadoFan = newFanOn;
  } 

  else if (m.addrPattern().startsWith("/fireControl/tornadoFuel")) {
   boolean newFuelOn = m.get(0).floatValue() != 0;
   
   // don't let the fuel come on without the ready light
   if (newFuelOn) {
     if (!fcUITornadoReady) {
       newFuelOn = false;
       sendTouchOSCMsg("/fireControl/tornadoFuel", false);
 //      println("fan not ready");
     }
   }
   fcUITornadoFuel = newFuelOn;
  } 
  
  else if (m.addrPattern().startsWith("/fireControl/armA")) {
    fcUIArm = 0;
    updateArmRadioButtons();    
  }
  
  else if (m.addrPattern().startsWith("/fireControl/armB")) {
    fcUIArm = 1;
    updateArmRadioButtons();    
  }

  else if (m.addrPattern().startsWith("/fireControl/armC")) {
    fcUIArm = 2;
    updateArmRadioButtons();    
  }

}

void updateArmRadioButtons() {
   sendTouchOSCMsg("/fireControl/armA", fcUIArm == 0);
   sendTouchOSCMsg("/fireControl/armB", fcUIArm == 1);
   sendTouchOSCMsg("/fireControl/armC", fcUIArm == 2);  
}

// Sets a fire control relay to specified state
void fireDMX(int addr, boolean onOff) {
  if (onOff) {
   sendDMX(addr, FIRE_DMX_MAGIC);
  } else {
   sendDMX(addr, 0);
  }
}

// Advance runs the various timers, and sends DMX
void fireControlAdvance(float steps) {

  int curTime = now();
 
  // fire the poofer if we got an OSC message
  if (events.fired("poofer")) {
    fcPooferOnTime = curTime;
    fcPooferOn = true;
//    println("firing poofer");
  }
 
  // Turn the poofer off if it's been on long enough
  if (fcPooferOn && ((curTime - fcPooferOnTime) > fcUIPooferDuration*1000)) {
    fcPooferOn = false;
//    println("poofer off!");
  }
 
  // Turn on the ready light if the fan's been on for the warmup time
  if (fcUITornadoFan && !fcUITornadoReady && ((curTime - fcFanOnTime) > FAN_WARMUP_TIME)) {
    fcUITornadoReady = true;
    sendTouchOSCMsg("/fireControl/tornadoReady", true);
//    println("ready!");
  }
 
  // Send DMX to control relays
  fireDMX(POOFER_DMX_ADDR, fcPooferOn);
  fireDMX(TORNADO_FAN_DMX_ADDR, fcUITornadoFan);
  fireDMX(TORNADO_FUEL_DMX_ADDR, fcUITornadoFuel);
}



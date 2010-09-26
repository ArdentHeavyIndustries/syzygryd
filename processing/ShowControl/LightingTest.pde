// ------------------------------------------------- LightingTest  --------------------------------------
// Steps through every single DMX channel on the given arm. Does not use sync.
  
int TEST_STEP_TIME = 250; // ms
int FIRST_TEST_CHANNEL=0;
int LAST_TEST_CHANNEL= 117;
int TEST_VAL = 255;
boolean MULTIPLE_ARMS = false;

void sendDMX2(int addr, int val)
{
  sendDMX(addr, val);
  if (MULTIPLE_ARMS) {
    sendDMX(addr+8, val);
    sendDMX(addr+16, val);
  }  
}

class LightingTest extends LightingProgram {
 
  float lastTime;
  int lastChannel;
 
  LightingTest() {
   lastTime = now();
   lastChannel = FIRST_TEST_CHANNEL;
   sendDMX2(FIRST_TEST_CHANNEL,TEST_VAL);
   
    // Uncomment to open the high pressure valves on each arm
    //fireDMX(141, true); 
    //fireDMX(142, true); 
    //fireDMX(143, true); 
  }
    
  // ignore steps in case we are not getting sync; use internal timer
  void advance(float steps) {
 
     int curTime = now();
 
     if (curTime > lastTime + TEST_STEP_TIME) {
       sendDMX2(lastChannel, 0);
       lastChannel++;
       if (lastChannel > LAST_TEST_CHANNEL)
         lastChannel = FIRST_TEST_CHANNEL;
       sendDMX2(lastChannel, TEST_VAL);      
       println("channel " + lastChannel + " on.");
       lastTime = curTime;
     }
   }
 
}

 

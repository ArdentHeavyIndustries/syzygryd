// ------------------------------------------------- LightingTest  --------------------------------------
// Steps through every single DMX channel on the given arm. Does not use sync.
  
int TEST_STEP_TIME = 250; // ms

// http://wiki.interpretivearson.com/index.php?title=Syzygryd:Teams:Lighting_Control#DMX_Addresses
// Each DMX universe (of which there are three, for three arms) is addressed as follows:
//     * 1-108 are cubes 1-36 R,G,B interleaved (108)
//     * 109-117 are control cubes (9)
//     * 118-141 are flame effects 1-8 on arms A, B, C (24)
//     * 142-144 are hi-pressure valves on arms A,B,C (3)
//     * 145 is the central poofer (1)
//     * 146 is the tornado fan (1)
//     * 147 is the tornado fuel (wired so that it cannot open the valve if the fan is not running) (1) 
// XXX i'm assuming that the wiki docs start counting at 1 and the code starts counting at 0, but could someone else confirm that?
int FIRST_TEST_CHANNEL=0;
int LAST_TEST_CHANNEL=107;

int TEST_VAL = 255;
boolean MULTIPLE_ARMS = true;

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
       info("channel " + lastChannel + " on.");
       lastTime = curTime;
     }
   }
 
}

/*
** Local Variables:
**   mode: java
**   c-basic-offset: 2
**   tab-width: 2
**   indent-tabs-mode: nil
** End:
**
** vim: softtabstop=2 tabstop=2 expandtab cindent shiftwidth=2
**
*/

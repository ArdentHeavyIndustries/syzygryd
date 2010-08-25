// ------------------------------------------------- LightingTest  --------------------------------------
// Steps through every single DMX channel on the given arm. Does not use sync.

int TEST_STEP_TIME = 1000; // ms
int FIRST_TEST_CHANNEL=0;
int LAST_TEST_CHANNEL= 47;
class LightingTest extends LightingProgram {
 
  float lastTime;
  int lastChannel;
 
  LightingTest() {
   lastTime = now();
   lastChannel = FIRST_TEST_CHANNEL;
   sendDMX(FIRST_TEST_CHANNEL,255);
  }
 
 void sendDMX(int channel, int value) {
   DMXManager.setChannel(0, channel, (byte)value);    // $$ universe 0, replace for multi-arm tests
 }
   
  // ignore steps in case we are not getting sync; use internal timer
  void advance(float steps) {
 
     int curTime = now();
 
     if (curTime > lastTime + TEST_STEP_TIME) {
       sendDMX(lastChannel, 0);
       lastChannel++;
       if (lastChannel > LAST_TEST_CHANNEL)
         lastChannel = FIRST_TEST_CHANNEL;
       sendDMX(lastChannel, 255);      
       println("channel " + lastChannel + " on.");
       lastTime = curTime;
     }
   }
 
}

 

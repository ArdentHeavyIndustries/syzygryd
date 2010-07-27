import oscP5.*;
import netP5.*;

// /cygdrive/c/Program\ Files/Java/jdk1.6.0_20/bin/javac.exe -cp ../../processing/libraries/oscP5/library/oscP5.jar SendOSC.java
// java -cp `cygpath -wp .:processing/core:../../processing/libraries/oscP5/library/oscP5.jar` SendOSC localhost 8001 /2_modulator/modulation6 0.5


/* For inspiration (but a complete clone is not necessarily a goal), see:
 *   http://archive.cnmat.berkeley.edu/OpenSoundControl/clients/sendOSC.html
 */
public class SendOSC
{
   NetAddress oscSender_;
   OscP5 oscP5_;

   public SendOSC(String host, int port) {
      System.out.println("Creating new OSC sender to " + host + ":" + port);
      oscSender_ = new NetAddress(host, port);
      // XXX really we're just sending, not listening
      // but it makes us specify a listening port
      // if we give the same port, it complains as follows:
      //    ### [2010/7/14 23:37:10] ERROR @ UdpServer.start()  IOException, couldnt create new DatagramSocket @ port 9001 java.net.BindException: Address already in use: Cannot bind
      // which really isn't a big deal, but avoid it by just going one higher
      oscP5_ = new OscP5(this, port + 1);
   }

   // XXX for now assume only floats

   public void send(String address, Float value1) {
      send(address, value1, null);
   }

   public void send(String address, Float value1, Float value2) {
      System.out.println("Sending OSC: " + address + " " + value1 + " " + value2);
      OscMessage message = new OscMessage(address);
      message.add(value1);
      if (value2 != null) {
         message.add(value2);
      }
      oscP5_.send(message, oscSender_);
   }

   // XXX not literal, given java classpath crap
   private static void usage() {
      System.err.println("usage: SendOSC <host> <port> <address> <value1> [<value2>]");
      System.exit(1);
   }

   public static void main(String[] args) {
      if (args.length == 4 || args.length == 5) {
         try {
            String host = args[0];
            int port = Integer.parseInt(args[1]);
            String address = args[2];
            SendOSC sendOSC = new SendOSC(host, port);
            Float value1 = Float.parseFloat(args[3]);
            if (args.length == 4) {
               sendOSC.send(address, value1);
            } else {
               Float value2 = Float.parseFloat(args[4]);
               sendOSC.send(address, value1, value2);
            }
         } catch (NumberFormatException nfe) {
            usage();
         }
      } else {
         usage();
      }

      System.exit(0);
   }
}

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

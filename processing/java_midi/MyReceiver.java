/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

import javax.sound.midi.*;

class MyReceiver implements Receiver {
				
  public void close() {
    System.out.println("close() called");
  }
		
  public void send(MidiMessage message, long timeStamp) {
    if (message instanceof ShortMessage) {
      ShortMessage shortMessage = (ShortMessage) message;
      System.out.println(timeStamp + " ShortMessage"
                         + " channel=" + shortMessage.getChannel()
                         + " command=" + shortMessage.getCommand()
                         + " data1=" + shortMessage.getData1()
                         + " data2=" + shortMessage.getData2());
    } else if (message instanceof SysexMessage) {
      SysexMessage sysexMessage = (SysexMessage) message;
      System.out.println(timeStamp + " SysexMessage"
                         + " data=" + sysexMessage.getData().length + "bytes");
    } else if (message instanceof MetaMessage) {
      MetaMessage metaMessage = (MetaMessage) message;
      System.out.println(timeStamp + " MetaMessage"
                         + " type=" + metaMessage.getType()
                         + " data=" + metaMessage.getData().length + "bytes");
    } else {
      System.err.println("WARNING: message is of an unexpected type: " + message);
    }
  }
}

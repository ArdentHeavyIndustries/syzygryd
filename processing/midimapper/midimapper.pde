import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JButton;
import javax.swing.ButtonGroup;
import javax.swing.JRadioButton;
import java.awt.*;
import java.awt.event.*;
import themidibus.*;

MidiBus mapperBus;
JFrame frame;
JPanel mastaPanel, firstRowPanel, secondRowPanel, thirdRowPanel;
JRadioButton channel1, channel2, channel3;
JButton ccButton1, ccButton2, ccButton3, ccButton4, ccButton5, ccButton6, ccButton7, ccButton8, ccButton9, ccButton10, ccButton11, ccButton12;
ButtonGroup channelRadio;

int selectedChannel, selectedControllerChange;
boolean buttonAction;

void setup()
{
  selectedChannel=0;
  buttonAction=false;
  size(32,32);
  
//Creating midiBus
  mapperBus = new MidiBus(this,"GridSequencer","GridSequencer");
  
  frame=new JFrame("MIDI Mapper");
  mastaPanel=new JPanel(new BorderLayout());
  firstRowPanel=new JPanel();
  secondRowPanel=new JPanel();
  thirdRowPanel=new JPanel();
  
//Describing radio buttons for channelization
  channel1=new JRadioButton("Channel 1", true);
  channel2=new JRadioButton("Channel 2");
  channel3=new JRadioButton("Channel 3");
  channelRadio = new ButtonGroup();
  channelRadio.add(channel1);
  channelRadio.add(channel2);
  channelRadio.add(channel3);
  
//Describing buttons to send CC data
  ccButton1=new JButton("Mod 1");
  ccButton2=new JButton("Mod 2");
  ccButton3=new JButton("Mod 3");
  ccButton4=new JButton("Mod 4");
  ccButton5=new JButton("Mod 5");
  ccButton6=new JButton("Mod 6");
  ccButton7=new JButton("Mod 7");
  ccButton8=new JButton("Mod 8");
  ccButton9=new JButton("XY1 X");
  ccButton10=new JButton("XY1 Y");
  ccButton11=new JButton("XY2 X");
  ccButton12=new JButton("XY2 Y");
  
  
//Adding "hooks" for buttons to do stuff
  guilistener listener = new guilistener();
  channel1.addActionListener(listener);
  channel2.addActionListener(listener);
  channel3.addActionListener(listener);
  ccButton1.addActionListener(listener);
  ccButton2.addActionListener(listener);
  ccButton3.addActionListener(listener);
  ccButton4.addActionListener(listener);
  ccButton5.addActionListener(listener);
  ccButton6.addActionListener(listener);
  ccButton7.addActionListener(listener);
  ccButton8.addActionListener(listener);
  ccButton9.addActionListener(listener);
  ccButton10.addActionListener(listener);
  ccButton11.addActionListener(listener);
  ccButton12.addActionListener(listener);

//Adding items to interface
  firstRowPanel.add(channel1);
  firstRowPanel.add(channel2);
  firstRowPanel.add(channel3);
  secondRowPanel.add(ccButton1);
  secondRowPanel.add(ccButton2);
  secondRowPanel.add(ccButton3);
  secondRowPanel.add(ccButton4);
  secondRowPanel.add(ccButton5);
  secondRowPanel.add(ccButton6);
  secondRowPanel.add(ccButton7);
  secondRowPanel.add(ccButton8);
  thirdRowPanel.add(ccButton9);
  thirdRowPanel.add(ccButton10);
  thirdRowPanel.add(ccButton11);
  thirdRowPanel.add(ccButton12);
  
  mastaPanel.add(firstRowPanel, BorderLayout.NORTH);
  mastaPanel.add(secondRowPanel, BorderLayout.CENTER);
  mastaPanel.add(thirdRowPanel, BorderLayout.SOUTH);
  
  frame.setResizable(false);
  frame.getContentPane().add(mastaPanel);
  frame.pack();
  frame.setVisible(true);
  
}
 
void draw() {
    while (buttonAction==true) {
    mapperBus.sendControllerChange(selectedChannel,selectedControllerChange,127);
    buttonAction=false;
    //print(selectedChannel);
    //print(selectedControllerChange);
  }
}
 
class guilistener implements ActionListener
{
   public void actionPerformed(ActionEvent event) //for radio buttons
   {
	  Object source = event.getSource();
  
	    if (source==channel1) selectedChannel=0;
	    else if (source==channel2) selectedChannel=1;
	    else if (source==channel3) selectedChannel=2;
	    else if (source==ccButton1) {
              selectedControllerChange=44;
              buttonAction=true;
            }
            else if (source==ccButton2) {
              selectedControllerChange=45;
              buttonAction=true;
            }
            else if (source==ccButton3) {
              selectedControllerChange=46;
              buttonAction=true;
            }
            else if (source==ccButton4) {
              selectedControllerChange=47;
              buttonAction=true;
            }
            else if (source==ccButton5) {
              selectedControllerChange=48;
              buttonAction=true;
            }
            else if (source==ccButton6) {
              selectedControllerChange=49;
              buttonAction=true;
            }
            else if (source==ccButton7) {
              selectedControllerChange=50;
              buttonAction=true;
            }
            else if (source==ccButton8) {
              selectedControllerChange=51;
              buttonAction=true;
	    }
            else if (source==ccButton9) {
              selectedControllerChange=52;
              buttonAction=true;
            }
            else if (source==ccButton10) {
              selectedControllerChange=53;
              buttonAction=true;
            }
            else if (source==ccButton11) {
              selectedControllerChange=54;
              buttonAction=true;
            }
            else if (source==ccButton12) {
              selectedControllerChange=55;
              buttonAction=true;
            }
}
}

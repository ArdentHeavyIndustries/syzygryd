import processing.core.*; 
import processing.xml.*; 

import nanohttpd.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class syzydiagnostic extends PApplet {



public void setup() {
 try {
  NanoHTTPD nh = new NanoHTTPD(51230); 
 }
 catch( IOException ioe) {
   println("IOException: " + ioe);
 }
 println("Server running on port 51230");
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#FFFFFF", "syzydiagnostic" });
  }
}

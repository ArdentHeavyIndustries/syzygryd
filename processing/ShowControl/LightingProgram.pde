//this is the class to override if you want to write a lighting program

class LightingProgram {

  //this should generally be the same as the list of fixtures in the controller.  We'll pass a ref to the constructor.
  ArrayList fixtures; 
  
  //provide 4 groups: arm1, arm2, arm3, fire;
  
  LightingProgram() {
  }
  
  //something to track current time?
  void setupLighting() {
    
  }
  
  //override this method to do stuff!
  void drawFrame() {
   
  }
  
  
}


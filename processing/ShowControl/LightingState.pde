// Syzygryd lighting and effect strate representaiton
// Used both for communication of the final state to the DMX, and for representation of each effect layer

class LightingState {
  color[][] armColor = new color[3][CUBES_PER_ARM];
  boolean[][] armEffect = new boolean[3][EFFECTS_PER_ARM];
  boolean[] armHiPressure = new boolean[3];
  boolean poofer;
  boolean tornado;  
  
  // Turns off all lights, shuts off all fire
  void clear() {
    for (int a=0; a<3; a++) {   
      for (int i=0; i<CUBES_PER_ARM; i++) {
        armColor[a][i] = color(0,0,0);
      }
      for (int i=0; i<EFFECTS_PER_ARM; i++) {
        armEffect[a][i] = false;
      }
      armHiPressure[a] = false;
    }
    poofer = false;
    tornado = false;
  }

  // blend self over dest
  void blendOverSelf(LightingState o, int blendMode) {
    for (int a=0; a<3; a++) {   
      for (int i=0; i<CUBES_PER_ARM; i++) {
        armColor[a][i] = blendColor(o.armColor[a][i], armColor[a][i], blendMode);
      }
    }
  }
  
  // Set an entire arm to a solid color
  void fillArm(int arm, color c) {
    for (int i=0; i<CUBES_PER_ARM; i++) {
      armColor[arm][i] = c;
    }
  }
  
  // Mirror ourself to current fixture state
  void output() {
    for (int i=0; i<3; i++) {   
      for (int j=0; j<CUBES_PER_ARM; j++) {
        Fixture f = arm[i].members.get(j);
        if (f.traits.containsKey("RGBColorMixing")){
          ((RGBColorMixingTrait)f.trait("RGBColorMixing")).setColorRGB(armColor[i][j]);
        } else
        if (f.traits.containsKey("Fire")){
          ((FireTrait)f.trait("Fire")).color2Fire(armColor[i][j]);
        }
      }
      for (int j=0; j<EFFECTS_PER_ARM; j++) {
        armEffect[i][j] = false;
      }
      armHiPressure[i] = false;  
    }
    poofer = false;
    tornado = false;
  }
    
}


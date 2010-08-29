// Syzygryd lighting and effect strate representaiton
// Used both for communication of the final state to the DMX, and for representation of each effect layer

// Utility functions to deal with the abstraction of effects as three more "arms"
int armResolution(int arm) {
  if (arm < 3)
    return CUBES_PER_ARM;
  else
    return EFFECTS_PER_ARM;
}

int panelToArmLights(int panel) {
  return panel;
}

int panelToArmFire(int panel) {
  return panel+3;
}

// LightOrFire? -- the closest thing we have to an enum
int LIGHT = 1;
int FIRE = 2;

int panelToArm(int panel, int lightOrFire) {
  if (lightOrFire == FIRE)
    return panelToArmFire(panel);
  else
    return panelToArmLights(panel);
}

class LightingState {
  color[][] armColor;    // 0-2 are lights, 3-5 are flame effects
//  color[3][2] groundColor;  // 2 ground effects per light
  
  boolean[] armHiPressure = new boolean[3];
  boolean poofer;
  boolean tornado;  
    
  LightingState() {
    armColor = new color[6][];
    armColor[0] = new color[CUBES_PER_ARM];
    armColor[1] = new color[CUBES_PER_ARM];
    armColor[2] = new color[CUBES_PER_ARM];
    armColor[3] = new color[EFFECTS_PER_ARM];
    armColor[4] = new color[EFFECTS_PER_ARM];
    armColor[5] = new color[EFFECTS_PER_ARM];
  }
  
  // Turns off all lights, shuts off all fire
  void clear() {
    for (int a=0; a<6; a++) {   
//      println(a + ", " + armResolution(a) + ", " + armColor[a].length);
      for (int i=0; i<armResolution(a); i++) {
        armColor[a][i] = color(0,0,0);
      }
      if (a<3)
        armHiPressure[a] = false;
    }
    poofer = false;
    tornado = false;
  }

  // blend self over dest
  void blendOverSelf(LightingState o, int blendMode, float opacity) {
    for (int a=0; a<6; a++) {   
      for (int i=0; i<armResolution(a); i++) {
        color blendC = blendColor(o.armColor[a][i], armColor[a][i], blendMode);
        armColor[a][i] = lerpColor(armColor[a][i], blendC, opacity);
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
    for (int i=0; i<arm.length; i++) {   
      for (int j=0; j<armResolution(i); j++) {
        Fixture f = arm[i].members.get(j);
        if (f.type.equals("cube")){
          ((RGBColorMixingTrait)f.trait("RGBColorMixing")).setColorRGB(armColor[i][j]);
        } else
        if (f.type.equals("fire")){
          ((FireTrait)f.trait("Fire")).color2Fire(armColor[i][j]);
        }
      }
    }
    // $$ output arm pressure, poofer, tornado
  }    
}


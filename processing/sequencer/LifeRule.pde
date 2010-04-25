/* -*- mode: java; c-basic-offset: 2; indent-tabs-mode: nil -*- */

class LifeRule {
  boolean[] births;
  boolean[] survivals;
  LifeRule(boolean survivals[], boolean births[]) {
    this.births = births;
    this.survivals = survivals;
  }
  /*
  static boolean[] s23 =  {false, false, true,  true, false, false, false, false, false};
  static boolean[] b3 = {false, false, false, true, false, false, false, false, false};
  public static LifeRule CONWAY_S23B3 =
    new LifeRule(s23, b3);
*/

  /**
   * @return -1 if the cell should die
   *          0 if the cell remains the same
   *          1 if the cell should be born
   */
  int liveOrDie(int currentValue, int numNeighborsOn) {
    if (numNeighborsOn < 0 || numNeighborsOn > 8) {
      return -1; // bad caller! bad. bad.
    }
    int fate = 0;
    if (currentValue > 0) {
      // if already on. kill it unless it should survive. 
      fate = (survivals[numNeighborsOn] ? 0 : -1);
    } else {
      // if not on, then it will change if a birth is indicated.
      fate = (births[numNeighborsOn] ? 1 : 0);
    }
    //println("        lr(" + currentValue + ", " + numNeighborsOn + ") -> " + fate);
    return fate;
  }
}

LifeRule CONWAY_S23B3 =
    new LifeRule(new boolean[]{false, false, true,  true, false, false, false, false, false},
                 new boolean[]{false, false, false, true, false, false, false, false, false});

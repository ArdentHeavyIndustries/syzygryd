void loadProgram(int programNumber){
  if (programNumber >= 0 && programNumber < programList.size()){
    program = programList.get(programNumber);
    flushBehaviors(); // Clear any uncompleted behaviors
    program.initialize();
    activeProgram = programNumber;
    print("Loaded program: " + activeProgram + "\n");
  }
}

void nextProgram(){
  activeProgram++;
  activeProgram %= programList.size();
  loadProgram(activeProgram);
}

void prevProgram(){
  activeProgram--;
  if (activeProgram < 0) {
    activeProgram = programList.size() - 1;
  }
  loadProgram(activeProgram);  
}

void flushBehaviors(){
  for (FixtureGroup group : fixtureGroups) {
    group.clearBehaviorList();
  } 
  for (Fixture fixture : fixtures) {
    fixture.clearBehaviorList();
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

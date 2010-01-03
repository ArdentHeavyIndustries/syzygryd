// An ArrayList is used to manage the list of Particles 

class ParticleSystemSimple {

  ArrayList particles;    // An arraylist for all the particles
  PVector origin;        // An origin point for where particles are birthed

  ParticleSystemSimple(int num, PVector v) {
    particles = new ArrayList();              // Initialize the arraylist
    origin = v.get();                        // Store the origin point
    for (int i = 0; i < num; i++) {
      // We have a 50% chance of adding each kind of particle
      //if (random(1) < 0.5) {
      //  particles.add(new CrazyParticle(origin)); 
      //} else {
        particles.add(new ParticleSimple(origin)); 
      //}
    }
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    /*for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = (ParticleSimple) particles.get(i);
      p.run();
      if (p.dead()) {
        particles.remove(i);
      }
    }
  }*/

 /* void addParticle() {
    particles.add(new ParticleSimple(origin));
  }

  void addParticle(ParticleSimple p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    if (particles.isEmpty()) {
      return true;
    } 
    else {
      return false;
    }*/
  }

}


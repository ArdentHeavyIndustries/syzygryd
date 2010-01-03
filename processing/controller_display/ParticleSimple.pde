// A simple Particle class

class ParticleSimple {
  PVector loc;
  PVector vel;
  PVector acc;
  float r;
  float timer;

  // One constructor
  ParticleSimple(PVector a, PVector v, PVector l, float r_) {
    acc = a.get();
    vel = v.get();
    loc = l.get();
    r = r_;
    timer = 50.0;
  }
  
  // Another constructor (the one we are using here)
  ParticleSimple(PVector l) {
    
    // the idea here is to give the particles a high-ish initial velocity, so they don't feel slow
    float velX = random(-3,3);
    if(velX < 0) {
      velX -= 2;
    } else {
      velX += 2;
    }
    
    acc = new PVector(random(-1,1),random(-.3,.3),0);
    vel = new PVector(velX,random(-1,1),0);
    loc = l.get();
    
    // set a random offset for the initial button position
    PVector offset = new PVector(random(-30,30), random(-30,30), 0);
    loc.add(offset);
    
    r = 5.0;
    timer = 50.0;
  }


  void run() {
    update();
    render();
  }

  // Method to update location
  void update() {
    vel.add(acc);
    loc.add(vel);
    timer -= 1.0;
  }

  // Method to display
  void render() {
    ellipseMode(CENTER);
    stroke(255,timer);
    fill(100,timer);
    ellipse(loc.x,loc.y,r,r);
  }
  
  // Is the particle still useful?
  boolean dead() {
    if (timer <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}

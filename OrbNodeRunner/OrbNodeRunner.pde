int NUM_ORBS = 5; // Fewer balls
int MIN_SIZE = 10;
int MAX_SIZE = 60;
float MIN_MASS = 10;
float MAX_MASS = 100;
float G_CONSTANT = 0.5;
float D_COEF = 0.1;
int SPRING_LENGTH = 100;
float SPRING_K = 0.005;

// Only four modes
final int GRAVITY = 0;
final int DRAG = 1;
final int SPRINGFORCE = 2;
final int MOVE = 3;

boolean[] toggles = new boolean[4];
String[] modes = {"Gravity", "Drag", "SpringForce", "Move"};
int currentMode = GRAVITY;  // Default to gravity mode

// Simulation elements
ArrayList<Orb> orbs;
FixedOrb centerMass;  // For gravity simulation

void setup() {
  size(600, 600);
  
  // All toggles off by default
  for (int i = 0; i < toggles.length; i++) {
    toggles[i] = false;
  }
  toggles[GRAVITY] = true; // Start with gravity on
  
  // Initialize simulations
  orbs = new ArrayList<Orb>();
  centerMass = new FixedOrb(width/2, height/2, 40, 5000);
 
  // Initialize orbs
  resetSimulation();
}

void draw() {
  background(255);
  displayMode();
 
  // Apply forces based on active toggles
  for (Orb orb : orbs) {
    // Apply gravity if gravity toggle is on
    if (toggles[GRAVITY]) {
      PVector gravForce = orb.getGravity(centerMass, G_CONSTANT);
      orb.applyForce(gravForce);
    }
    
    // Apply drag if drag toggle is on
    if (toggles[DRAG]) {
      PVector dragForce = orb.getDragForce(D_COEF);
      orb.applyForce(dragForce);
    }
    
    // Apply spring forces between orbs if springforce toggle is on
    if (toggles[SPRINGFORCE]) {
      for (Orb other : orbs) {
        if (orb != other) {
          PVector springForce = orb.getSpring(other, SPRING_LENGTH, SPRING_K);
          orb.applyForce(springForce);
        }
      }
    }
    
    // Move orbs if move toggle is on
    if (toggles[MOVE]) {
      orb.move(true);  // Always bounce
    }
    
    // Always display
    orb.display();
  }
  
  // Always display center mass
  centerMass.display();
}

void resetSimulation() {
  orbs.clear();
 
  // Create orbs
  for (int i = 0; i < NUM_ORBS; i++) {
    float size = random(MIN_SIZE, MAX_SIZE);
    float mass = map(size, MIN_SIZE, MAX_SIZE, MIN_MASS, MAX_MASS);
    float x = random(size/2, width - size/2);
    float y = random(size/2, height - size/2);
   
    Orb newOrb = new Orb(x, y, size, mass);
   
    // Give initial velocity
    PVector toCenter = new PVector(centerMass.center.x - x, centerMass.center.y - y);
    PVector perpendicular = new PVector(-toCenter.y, toCenter.x);
    perpendicular.normalize();
   
    // Velocity magnitude based on distance
    float dist = toCenter.mag();
    float speed = map(dist, 0, width/2, 0.5, 3);
   
    // Set initial velocity
    perpendicular.mult(speed);
    newOrb.velocity = perpendicular;
    
    orbs.add(newOrb);
  }
}

void keyPressed() {
  if (key == 'r') {
    resetSimulation();
  }
  
  // Toggle modes
  if (key == '1') {
    toggles[GRAVITY] = !toggles[GRAVITY];
  }
  if (key == '2') {
    toggles[DRAG] = !toggles[DRAG];
  }
  if (key == '3') {
    toggles[SPRINGFORCE] = !toggles[SPRINGFORCE];
  }
  if (key == '4') {
    toggles[MOVE] = !toggles[MOVE];
  }
}

void displayMode() {
  textAlign(LEFT, TOP);
  textSize(20);
  noStroke();
  int x = 0;
 
  // Display toggles
  for (int m = 0; m < toggles.length; m++) {
    // Set box color
    if (toggles[m]) {
      fill(0, 255, 0);
    } else {
      fill(255, 0, 0);
    }
    float w = textWidth(modes[m]);
    rect(x, 0, w+5, 20);
    fill(0);
    text(modes[m], x+2, 2);
    x += w+10;  // More spacing
  }
}

class Orb {
  //instance variables
  PVector center;
  PVector velocity;
  PVector acceleration;
  float bsize;
  float mass;
  color c;
  
  Orb() {
     bsize = random(10, MAX_SIZE);
     float x = random(bsize/2, width-bsize/2);
     float y = random(bsize/2, height-bsize/2);
     center = new PVector(x, y);
     mass = random(10, 100);
     velocity = new PVector();
     acceleration = new PVector();
     setColor();
  }
  
  Orb(float x, float y, float s, float m) {
     bsize = s;
     mass = m;
     center = new PVector(x, y);
     velocity = new PVector();
     acceleration = new PVector();
     setColor();
   }
   
  //movement behavior
  void move(boolean bounce) {
    if (bounce) {
      xBounce();
      yBounce();
    }
    velocity.add(acceleration);
    center.add(velocity);
    acceleration.mult(0);
  }//move
  
  void applyForce(PVector force) {
    PVector scaleForce = force.copy();
    scaleForce.div(mass);
    acceleration.add(scaleForce);
  }
  
  PVector getDragForce(float cd) {
    float dragMag = velocity.mag();
    dragMag = -0.5 * dragMag * dragMag * cd;
    PVector dragForce = velocity.copy();
    dragForce.normalize();
    dragForce.mult(dragMag);
    return dragForce;
  }
  
  PVector getGravity(Orb other, float G) {
    float strength = G * mass*other.mass;
    //dont want to divide by 0!
    float r = max(center.dist(other.center), MIN_SIZE);
    strength = strength/ pow(r, 2);
    PVector force = other.center.copy();
    force.sub(center);
    force.mult(strength);
    return force;
  }
  
  //spring force between calling orb and other
  PVector getSpring(Orb other, int springLength, float springK) {
    PVector direction = PVector.sub(other.center, this.center);
    direction.normalize();
    float displacement = this.center.dist(other.center) - springLength;
    float mag = springK * displacement;
    direction.mult(mag);
    return direction;
  }//getSpring
  
  boolean yBounce(){
    if (center.y > height - bsize/2) {
      velocity.y *= -1;
      center.y = height - bsize/2;
      return true;
    }//bottom bounce
    else if (center.y < bsize/2) {
      velocity.y*= -1;
      center.y = bsize/2;
      return true;
    }
    return false;
  }//yBounce
  
  boolean xBounce() {
    if (center.x > width - bsize/2) {
      center.x = width - bsize/2;
      velocity.x *= -1;
      return true;
    }
    else if (center.x < bsize/2) {
      center.x = bsize/2;
      velocity.x *= -1;
      return true;
    }
    return false;
  }//xbounce
  
  boolean collisionCheck(Orb other) {
    return ( this.center.dist(other.center)
             <= (this.bsize/2 + other.bsize/2) );
  }//collisionCheck
  
  void setColor() {
    color c0 = color(0, 255, 255);
    color c1 = color(0);
    c = lerpColor(c0, c1, (mass-MIN_MASS)/(MAX_MASS-MIN_MASS));
  }//setColor
  
  //visual behavior
  void display() {
    noStroke();
    fill(c);
    circle(center.x, center.y, bsize);
    fill(0);
    //text(mass, center.x, center.y);
  }//display
}//Ball

class FixedOrb extends Orb {
  FixedOrb(float x, float y, float s, float m) {
    super(x, y, s, m);
    c = color(255, 0, 0);
  }
 
  FixedOrb() {
    super();
    c = color(255, 0, 0);
  }
 
  void move(boolean bounce) {
    //do nothing - fixed orb doesn't move
  }
}

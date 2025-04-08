// Constants for all simulations
int NUM_ORBS = 5;
int NUM_CHARGES = 16;
int MIN_SIZE = 10;
int MAX_SIZE = 60;
float MIN_MASS = 10;
float MAX_MASS = 50;

// Force constants
float G_CONSTANT = 0.05;   // Gravity
float SPRING_K = 0.01;     // Spring
float SPRING_LENGTH = 100;
float AIR_DRAG = 0.01;     // Drag
float WATER_DRAG = 1;
float COUL = 500;          // Coulomb constant 
float GRAVITY = 0.1;       // Downward gravity

// Simulation modes
final int GRAVITY_SIM = 0;
final int SPRING_SIM = 1;
final int DRAG_SIM = 2;
final int ELECTRIC_SIM = 3;
final int COMBO_SIM = 4;   

// Toggle states
boolean movementOn = true;
boolean bouncingOn = true;

// Force toggles for combo simulation
boolean gravityOn = false;
boolean springOn = false;
boolean dragOn = false;
boolean electricOn = false;
boolean downGravityOn = false;

// Current active simulation
int currentSimulation = GRAVITY_SIM;

// UI elements
ArrayList<Button> buttons = new ArrayList<Button>();
float waterLevel;

// Simulation elements
ArrayList<Orb> orbs;
ArrayList<ChargeOrb> charges;
FixedOrb centerMass;

void setup() {
  size(600, 600);
 
  // Set water level at 60% of screen height
  waterLevel = height * 0.6;
 
  // Create toggle buttons for combo mode
  createButtons();
 
  // Initialize simulation lists
  orbs = new ArrayList<Orb>();
  charges = new ArrayList<ChargeOrb>();
  centerMass = new FixedOrb(width/2, height/2, 40, 5000);
 
  // Initialize orbs for current simulation
  resetSimulation();
}

void createButtons() {
  int buttonWidth = 100;
  int buttonHeight = 30;
  int spacing = 10;
  int startX = 50;
  int startY = 50;
 
  buttons.add(new Button("Gravity", startX, startY, buttonWidth, buttonHeight, color(200, 100, 100)));
  buttons.add(new Button("Spring", startX + buttonWidth + spacing, startY, buttonWidth, buttonHeight, color(100, 200, 100)));
  buttons.add(new Button("Drag", startX + 2 * (buttonWidth + spacing), startY, buttonWidth, buttonHeight, color(100, 100, 200)));
  buttons.add(new Button("Electric", startX + 3 * (buttonWidth + spacing), startY, buttonWidth, buttonHeight, color(200, 200, 100)));
  buttons.add(new Button("Gravity Down", startX, startY + buttonHeight + spacing, buttonWidth, buttonHeight, color(200, 100, 200)));
}

void draw() {
  background(255);
 
  // Draw environment based on active forces
  drawEnvironment();
 
  // Process simulation
  runSimulation();
 
  // Display menu and buttons
  displayMenu();
 
  // Only show force toggle buttons in combo mode
  if (currentSimulation == COMBO_SIM) {
    for (Button button : buttons) {
      button.display();
    }
  }
}

void runSimulation() {
  if (currentSimulation == COMBO_SIM) {
    // Run combo simulation with multiple forces
    runComboSimulation();
  }
  else if (currentSimulation == ELECTRIC_SIM) {
    // Electric simulation with charge orbs
    runElectricSimulation();
  }
  else {
    // Run other individual simulations
    runStandardSimulation();
  }
}

void runComboSimulation() {
  // Apply all active forces to each orb
  for (int i = 0; i < orbs.size(); i++) {
    Orb orb = orbs.get(i);
   
    // Apply center gravity if enabled
    if (gravityOn) {
      PVector gravForce = orb.getGravity(centerMass, G_CONSTANT * 2);
      orb.applyForce(gravForce);
    }
   
    // Apply spring forces if enabled
    if (springOn) {
      for (Orb other : orbs) {
        if (orb != other) {
          PVector springForce = orb.getSpring(other, SPRING_LENGTH, SPRING_K);
          orb.applyForce(springForce);
         
          // Draw spring lines
          visualizeSpring(orb, other);
        }
      }
    }
   
    // Apply drag if enabled
    if (dragOn) {
      boolean inWater = orb.center.y > waterLevel;
      float dragCoef = inWater ? WATER_DRAG : AIR_DRAG;
      PVector dragForce = orb.getDragForce(dragCoef);
      orb.applyForce(dragForce);
    }
   
    // Apply downward gravity if enabled
    if (downGravityOn) {
      PVector gravityForce = new PVector(0, GRAVITY * orb.mass);
      orb.applyForce(gravityForce);
    }
   
    // Move orbs if movement is enabled
    if (movementOn) {
      orb.move(bouncingOn);
    }
   
    // Display orbs
    orb.display();
  }
 
  // Handle electric forces separately if enabled
  if (electricOn) {
    // Process charges
    for (int i = 0; i < charges.size(); i++) {
      ChargeOrb charge = charges.get(i);
     
      // Apply electric forces between charges
      for (ChargeOrb other : charges) {
        if (charge != other) {
          PVector electricForce = getElectricForce(charge, other);
          charge.applyForce(electricForce);
        }
      }
     
      // Move charges if movement is enabled
      if (movementOn) {
        charge.move();
      }
     
      // Display charges
      charge.display();
    }
  }
 
  // Draw center mass if gravity is enabled
  if (gravityOn) {
    centerMass.display();
  }
}

void runElectricSimulation() {
  // Electric simulation with charge orbs
  for (ChargeOrb charge : charges) {
    // Apply electric forces between charges
    for (ChargeOrb other : charges) {
      if (charge != other) {
        PVector electricForce = getElectricForce(charge, other);
        charge.applyForce(electricForce);
      }
    }
   
    // Move charges if movement is enabled
    if (movementOn) {
      charge.move();
    }
   
    // Display charges
    charge.display();
  }
}

void runStandardSimulation() {
  // Handle standard simulations (gravity, spring, drag)
  for (Orb orb : orbs) {
    if (currentSimulation == GRAVITY_SIM) {
      // Gravity simulation
      PVector gravForce = orb.getGravity(centerMass, G_CONSTANT * 5);
      orb.applyForce(gravForce);
    }
    else if (currentSimulation == SPRING_SIM) {
      // Spring simulation
      for (Orb other : orbs) {
        if (orb != other) {
          PVector springForce = orb.getSpring(other, SPRING_LENGTH, SPRING_K);
          orb.applyForce(springForce);
          visualizeSpring(orb, other);
        }
      }
    }
    else if (currentSimulation == DRAG_SIM) {
      // Drag simulation
      PVector gravityForce = new PVector(0, GRAVITY * orb.mass);
      orb.applyForce(gravityForce);
     
      boolean inWater = orb.center.y > waterLevel;
      float dragCoef = inWater ? WATER_DRAG : AIR_DRAG;
     
      PVector dragForce = orb.getDragForce(dragCoef);
      orb.applyForce(dragForce);
    }
   
    // Move orbs if movement is enabled
    if (movementOn) {
      orb.move(bouncingOn);
    }
   
    // Display orbs
    orb.display();
  }
 
  // Show center mass for gravity simulation
  if (currentSimulation == GRAVITY_SIM) {
    centerMass.display();
  }
}

// Properly implemented Coulomb's Law for electric forces
PVector getElectricForce(ChargeOrb a, ChargeOrb b) {
  // Get vector pointing from charge a to charge b
  PVector direction = PVector.sub(b.position, a.position);
  
  // Calculate distance between charges (with minimum to avoid extreme forces)
  float distance = max(direction.mag(), a.size/2 + b.size/2);
  
  // Calculate force magnitude using Coulomb's Law
  // F = k * (q1 * q2) / r²
  float forceMagnitude = COUL * (abs(a.charge) * abs(b.charge)) / (distance * distance);
  
  // Normalize the direction vector
  direction.normalize();
  
  // Apply force magnitude to direction
  // The sign of the product of charges determines attraction or repulsion:
  // - If a.charge * b.charge > 0 (both positive or both negative), charges repel (force away)
  // - If a.charge * b.charge < 0 (one positive, one negative), charges attract (force toward)
  float chargeSign = (a.charge * b.charge > 0) ? -1 : 1;
  direction.mult(chargeSign * forceMagnitude);
  
  return direction;
}

void drawEnvironment() {
  // Draw water environment if drag is enabled in combo mode
  if ((currentSimulation == DRAG_SIM) || (currentSimulation == COMBO_SIM && dragOn)) {
    // Water background
    noStroke();
    fill(0, 0, 200, 50);
    rect(0, waterLevel, width, height - waterLevel);
   
    // Water surface line
    stroke(0, 0, 200, 150);
    strokeWeight(2);
    line(0, waterLevel, width, waterLevel);
  }
  
  // No grid for electric simulation - blank background as requested
}

void visualizeSpring(Orb o1, Orb o2) {
  float distance = o1.center.dist(o2.center);
  float stretch = distance - SPRING_LENGTH;
 
  // Determine color based on stretch
  if (stretch > 1) {
    stroke(255, 0, 0, 180);  // Stretched (red)
  } else if (stretch < -1) {
    stroke(0, 255, 0, 180);  // Compressed (green)
  } else {
    stroke(0, 0, 0, 180);    // Normal (black)
  }
 
  strokeWeight(1.5);
  line(o1.center.x, o1.center.y, o2.center.x, o2.center.y);
}

void resetSimulation() {
  // Clear existing orbs and charges
  orbs.clear();
  charges.clear();
 
  // Reset toggle states for combo mode
  if (currentSimulation == COMBO_SIM) {
    gravityOn = false;
    springOn = false;
    dragOn = false;
    electricOn = false;
    downGravityOn = false;
   
    // Reset button states
    for (Button button : buttons) {
      button.active = false;
    }
  }
 
  if (currentSimulation == ELECTRIC_SIM) {
    // Initialize electric charges
    createCharges();
  }
  else if (currentSimulation == COMBO_SIM) {
    // Create orbs for combo simulation
    createOrbs();
    // Also create charges (they'll be shown when electric toggle is on)
    createCharges();
  }
  else {
    // Create orbs for standard simulations
    createOrbs();
  }
}

void createOrbs() {
  // Create standard orbs for gravity, spring, drag simulations
  for (int i = 0; i < NUM_ORBS; i++) {
    float size = random(MIN_SIZE, MAX_SIZE);
    float mass = map(size, MIN_SIZE, MAX_SIZE, MIN_MASS, MAX_MASS);
    float x = random(size/2, width - size/2);
    float y = random(size/2, height - size/2);
   
    // For drag simulation, place orbs at the top
    if (currentSimulation == DRAG_SIM) {
      y = random(50, waterLevel - 50);
    }
   
    Orb newOrb = new Orb(x, y, size, mass);
   
    // Set initial velocity based on simulation type
    if (currentSimulation == GRAVITY_SIM) {
      // Create orbital velocity
      PVector toCenter = new PVector(centerMass.center.x - x, centerMass.center.y - y);
      PVector perpendicular = new PVector(-toCenter.y, toCenter.x);
      perpendicular.normalize();
     
      float dist = toCenter.mag();
      float speed = sqrt(G_CONSTANT * 5 * centerMass.mass / dist) * 0.6;
      perpendicular.mult(speed);
      newOrb.velocity = perpendicular;
    }
    else if (currentSimulation == SPRING_SIM || currentSimulation == COMBO_SIM) {
      // Random gentle velocity for spring/combo
      newOrb.velocity = new PVector(random(-0.5, 0.5), random(-0.5, 0.5));
    }
    else if (currentSimulation == DRAG_SIM) {
      // Initial downward velocity for drag
      newOrb.velocity = new PVector(random(-1, 1), random(0, 1));
    }
   
    orbs.add(newOrb);
  }
}

void createCharges() {
  // Create electric charge orbs with a balanced mix of positive and negative charges
  int numToCreate = (currentSimulation == COMBO_SIM) ? NUM_CHARGES/2 : NUM_CHARGES;
 
  for (int i = 0; i < numToCreate; i++) {
    float size = random(MIN_SIZE, MAX_SIZE);
    // Create more balanced mix of positive and negative charges
    float charge = (i % 2 == 0) ? random(30, 100) : random(-100, -30);
   
    float padding = MAX_SIZE;
    float x = random(padding, width - padding);
    float y = random(padding, height - padding);
   
    // Make sure orbs don't start overlapping
    boolean validPosition = true;
    for (ChargeOrb other : charges) {
      float minDist = (size + other.size) / 2;
      if (dist(x, y, other.position.x, other.position.y) < minDist) {
        validPosition = false;
        break;
      }
    }
   
    if (validPosition) {
      charges.add(new ChargeOrb(x, y, size, charge));
    } else {
      i--; // Try again
    }
  }
}

void mousePressed() {
  // Only handle button clicks in combo mode
  if (currentSimulation == COMBO_SIM) {
    for (int i = 0; i < buttons.size(); i++) {
      Button button = buttons.get(i);
     
      if (button.contains(mouseX, mouseY)) {
        button.active = !button.active;
       
        // Update force toggles based on button states
        switch(i) {
          case 0: gravityOn = button.active; break;
          case 1: springOn = button.active; break;
          case 2: dragOn = button.active; break;
          case 3: electricOn = button.active; break;
          case 4: downGravityOn = button.active; break;
        }
      }
    }
  }
}

void keyPressed() {
  if (key == 'r') {
    resetSimulation();
  }
 
  // Switch between simulations
  if (key == '1') {
    currentSimulation = GRAVITY_SIM;
    resetSimulation();
  }
  else if (key == '2') {
    currentSimulation = SPRING_SIM;
    resetSimulation();
  }
  else if (key == '3') {
    currentSimulation = DRAG_SIM;
    resetSimulation();
  }
  else if (key == '4') {
    currentSimulation = ELECTRIC_SIM;
    resetSimulation();
  }
  else if (key == '5') {
    currentSimulation = COMBO_SIM;
    resetSimulation();
  }
 
  // Toggle movement and bouncing
  if (key == 'm') {
    movementOn = !movementOn;
  }
  if (key == 'b') {
    bouncingOn = !bouncingOn;
  }
 
  // Adjust water level in drag simulation
  if (key == 'w' && (currentSimulation == DRAG_SIM || (currentSimulation == COMBO_SIM && dragOn))) {
    waterLevel = max(50, waterLevel - 20);
  }
  if (key == 's' && (currentSimulation == DRAG_SIM || (currentSimulation == COMBO_SIM && dragOn))) {
    waterLevel = min(height - 50, waterLevel + 20);
  }
}

void displayMenu() {
  // Background for menu
  fill(0, 150);
  noStroke();
  rect(0, 0, width, 40);
 
  // Simulation name
  textAlign(CENTER, CENTER);
  textSize(16);
  fill(255);
  String simName = "";
 
  switch(currentSimulation) {
    case GRAVITY_SIM: simName = "GRAVITY"; break;
    case SPRING_SIM: simName = "SPRING FORCE"; break;
    case DRAG_SIM: simName = "AIR-WATER DRAG"; break;
    case ELECTRIC_SIM: simName = "ELECTRIC FORCE"; break;
    case COMBO_SIM: simName = "COMBO FORCES"; break;
  }
 
  text("Simulation: " + simName, width/2, 20);
 
  // Movement status indicators
  textAlign(LEFT, CENTER);
  int leftOffset = 20;
 
  // Movement indicator
  if (movementOn) fill(0, 255, 0);
  else fill(255, 0, 0);
  rect(leftOffset, 12, 16, 16);
  fill(0);
  text("M", leftOffset + 4, 20);
 
  // Bouncing indicator
  if (bouncingOn) fill(0, 255, 0);
  else fill(255, 0, 0);
  rect(leftOffset + 60, 12, 16, 16);
  fill(0);
  text("B", leftOffset + 64, 20);
 
  // Help text at bottom - changed to black color as requested
  textAlign(LEFT, BOTTOM);
  textSize(12);
  fill(0);  // BLACK text color
  String controls = "Keys: 1-5=Change Simulation, r=Reset, m=Toggle Movement, b=Toggle Bouncing";
 
  if (currentSimulation == DRAG_SIM || (currentSimulation == COMBO_SIM && dragOn)) {
    controls += ", w/s=Adjust Water Level";
  }
 
  if (currentSimulation == COMBO_SIM) {
    controls += " | Click buttons to toggle forces";
  }
 
  text(controls, 10, height - 10);
}

class Button {
  String label;
  float x, y, w, h;
  color c;
  boolean active;
 
  Button(String label, float x, float y, float w, float h, color c) {
    this.label = label;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.c = c;
    this.active = false;
  }
 
  void display() {
    // Draw button
    stroke(0);
    strokeWeight(1);
   
    if (active) {
      fill(c);
    } else {
      fill(200);
    }
   
    rect(x, y, w, h, 5);
   
    // Draw label
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(label, x + w/2, y + h/2);
  }
 
  boolean contains(float px, float py) {
    return (px >= x && px <= x + w && py >= y && py <= y + h);
  }
}

class Orb {
  PVector center;
  PVector velocity;
  PVector acceleration;
  float size;
  float mass;
  color c;
 
  Orb(float x, float y, float s, float m) {
    center = new PVector(x, y);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    size = s;
    mass = m;
    c = color(random(100, 200), random(100, 200), random(100, 200));
  }
 
  void display() {
    noStroke();
    fill(c);
    circle(center.x, center.y, size);
  }
 
  // Calculate spring force between two orbs
  PVector getSpring(Orb other, float springLength, float springK) {
    PVector force = PVector.sub(other.center, center);
    float distance = force.mag();
    float displacement = distance - springLength;
   
    force.normalize();
    float magnitude = springK * displacement;
    force.mult(magnitude);
   
    return force;
  }
 
  // Calculate gravity force between two orbs
  PVector getGravity(Orb other, float G) {
    PVector force = PVector.sub(other.center, center);
    float distance = force.mag();
    distance = constrain(distance, 50, 1000);
   
    float magnitude = G * (mass * other.mass) / (distance * distance);
    force.normalize();
    force.mult(magnitude);
   
    return force;
  }
 
  void move(boolean bounce) {
    // Update velocity and position
    velocity.add(acceleration);
    center.add(velocity);
   
    // Handle bouncing if enabled
    if (bounce) {
      if (center.x < size/2) {
        center.x = size/2;
        velocity.x *= -0.9;
      } else if (center.x > width - size/2) {
        center.x = width - size/2;
        velocity.x *= -0.9;
      }
     
      if (center.y < size/2) {
        center.y = size/2;
        velocity.y *= -0.9;
      } else if (center.y > height - size/2) {
        center.y = height - size/2;
        velocity.y *= -0.9;
      }
    }
   
    // Reset acceleration
    acceleration.mult(0);
  }
 
  void applyForce(PVector force) {
    PVector scaleForce = force.copy();
    scaleForce.div(mass);
    acceleration.add(scaleForce);
  }
 
  PVector getDragForce(float cd) {
    float speed = velocity.mag();
    if (speed < 0.01) return new PVector(0, 0);
    
    float dragMag = cd * speed * speed;
    PVector dragForce = velocity.copy();
    dragForce.normalize();
    dragForce.mult(-dragMag);
    return dragForce;
  }
}

class FixedOrb extends Orb {
  FixedOrb(float x, float y, float s, float m) {
    super(x, y, s, m);
    c = color(255, 200, 0); // Sun-like color
  }
  
  void move(boolean bounce) {
    // Do nothing - fixed orb doesn't move
  }
}

class ChargeOrb {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float size;
  float charge;
  color c;
  
  ChargeOrb(float x, float y, float s, float q) {
    position = new PVector(x, y);
    velocity = new PVector(random(-1, 1), random(-1, 1));
    velocity.normalize();
    velocity.mult(random(0.5, 1.5));
    acceleration = new PVector(0, 0);
    size = s;
    charge = q;
    setColor();
  }
  
  void setColor() {
    // Red for positive charge, blue for negative charge
    // Using more vibrant colors with intensity based on charge magnitude
    float intensity = map(abs(charge), 30, 100, 150, 255);
    if (charge > 0) {
      c = color(intensity, 50, 50); // Red for positive
    } else {
      c = color(50, 50, intensity); // Blue for negative
    }
  }
  
  void applyForce(PVector force) {
    // F = ma, so a = F/m (using charge magnitude as mass)
    PVector a = PVector.div(force, abs(charge));
    acceleration.add(a);
  }
  
  void move() {
    // Add damping
    velocity.mult(0.98);
    
    // Update velocity and position
    velocity.add(acceleration);
    
    // Limit velocity to keep simulation stable
    float maxSpeed = 5;
    if (velocity.mag() > maxSpeed) {
      velocity.normalize();
      velocity.mult(maxSpeed);
    }
    
    position.add(velocity);
    
    // Bounce off walls
    if (position.x < size/2) {
      position.x = size/2;
      velocity.x *= -1;
    } else if (position.x > width - size/2) {
      position.x = width - size/2;
      velocity.x *= -1;
    }
    
    if (position.y < size/2) {
      position.y = size/2;
      velocity.y *= -1;
    } else if (position.y > height - size/2) {
      position.y = height - size/2;
      velocity.y *= -1;
    }
    
    // Reset acceleration
    acceleration.mult(0);
  }
  
  void display() {
    noStroke();
    fill(c);
    circle(position.x, position.y, size);
    
    // Display charge value
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(min(size/3, 14));
    int chargeValue = round(charge);
    String chargeText = (chargeValue > 0 ? "+" : "") + chargeValue;
    text(chargeText, position.x, position.y);
  }
}

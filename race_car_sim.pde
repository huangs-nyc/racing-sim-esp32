/*
  Serial Joystick
 Takes in X,Y,Z serial input from a joystick
 */

import processing.serial.*;

Serial myPort;  // Create object from Serial class

float carX = 100, carY = 100;
float carAngle = 0;
float speed = 0;
String val;      // Data received from the serial port

boolean raceFinished = false;
int startTime;
int finishTime;
PFont font;

int canvasSize = 100;
int analogMax = 4095;

void setup()
{
  size(1440, 780);
  
  font = createFont("Arial", 20, true);
  textFont(font);
  
  printArray(Serial.list());
  String portName = Serial.list()[1];
  println(portName);
  myPort = new Serial(this, portName, 9600); // ensure baudrate is consistent with arduino sketch
  restartRace();
}

void draw()
{
  println(raceFinished);
  background(0);
  // display the time
  if (!raceFinished) {
    int currentTime = millis() - startTime;
    fill(255);
    textAlign(RIGHT, TOP);
    text("Current race time: " + nf(currentTime / 1000.0, 0, 2) + " seconds", width - 20, 20);
  }
  
  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
    if (val != null) {
      val = trim(val);
      String[] values = split(val, ',');
      if (values.length == 4) {
        int joystickX = int(values[0]);
        int joystickY = int(values[1]);
        int potValue = int(values[2]);
        int buttonState = int(values[3]);
        
        updateCar(joystickX, joystickY, potValue, buttonState);
      }
    }
  }
  renderTrack();
  renderCar();
  checkRaceCompletion();
  
  if(raceFinished) {
    displayRaceFinished();
  }
}

void restartRace() {
  carX = 100;
  carY = 100;
  carAngle = 0;
  speed = 0;
  raceFinished = false;
  startTime = millis();
}

void checkRaceCompletion() {
  if (carX >= 1000 && carY >= 150 && !raceFinished) {
    raceFinished = true;
    finishTime = millis();
  }
}

void displayRaceFinished() {
  fill(0, 150);
  rect(0, 0, width, height);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("You finished the time trial!", width/2, height/2 - 50);
  
  textSize(30);
  float raceTime = (finishTime - startTime) / 1000.0;
  text("Your time: " + nf(raceTime, 0, 2) + " seconds", width/2, height/2 + 20);
  
  textSize(20);
  text("Press the button to restart the time trial.", width/2, height/2 + 80);
}

void renderTrack() {
  // make grass
  background(50, 200, 50);
  noFill();
  stroke(100, 100, 100);
  strokeWeight(50);
  
  // draw track
  beginShape();
  vertex(100, 100);
  bezierVertex(200, 500, 300, 200, 400, 150);
  bezierVertex(500, 100, 600, 300, 700, 250);
  bezierVertex(800, 200, 900, 100, 1000, 150);
  endShape();
  
  // lane markers
  stroke(255);
  strokeWeight(2);
  beginShape();
  vertex(100, 110);
  bezierVertex(200, 110, 300, 210, 400, 160);
  bezierVertex(500, 110, 600, 310, 700, 260);
  bezierVertex(800, 210, 900, 110, 1000, 160);
  endShape();
}

void renderCar() {
  pushMatrix();
  translate(carX, carY);
  rotate(radians(carAngle));
  fill(255, 0, 0);
  rect(-15, -10, 30, 20);
  popMatrix();
}

void updateCar(int joystickX, int joystickY, int potValue, int buttonState) {
  if (buttonState == 0) {
    restartRace();
    return;
  }
  if (buttonState == 0 && raceFinished) {
    restartRace();
    return;
  }
  
  float turnAngle = map(joystickX, 0, 4095, -45, 45);
  println(turnAngle);
    if (abs(turnAngle) < 4.8) {
    carAngle = 0; // fix this, TODO
  } else {
    carAngle += turnAngle * 0.05;
  }
  
  
  float throttle = map(potValue, 0, 4095, 0, 5);
  float moveDirection = map(joystickY, 0, 4095, -1, 1);
  
  if (abs(moveDirection) < 0.2) {
    speed = 0;
  } else {
    speed = throttle * moveDirection;
  }
  
  carX += cos(radians(carAngle)) * speed;
  carY += sin(radians(carAngle)) * speed;
  
  // check if within bounds
  if (carX < 0) {carX = 0;}
  if (carX > width) {carX = width;}
  if (carY < 0) {carY = 0;}
  if (carY > height) {carY = height;}
}

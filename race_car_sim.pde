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

PImage carImage;

int canvasSize = 100;
int analogMax = 4095;

boolean gameStarted = false;

void setup() {
  size(1440, 780);
  carImage = loadImage("car.png");
  
  font = createFont("Arial", 20, true);
  textFont(font);
  
  printArray(Serial.list());
  String portName = Serial.list()[1];
  println(portName);
  myPort = new Serial(this, portName, 9600); // ensure baudrate is consistent with arduino sketch
  restartRace();
}

void draw() {
  println(raceFinished);
  background(0);
  
  if (!gameStarted) {
    displayStartScreen();
    if (myPort.available() > 0) {  // If data is available,
      val = myPort.readStringUntil('\n');         // read it and store it in val
      if (val != null) {
        val = trim(val);
        String[] values = split(val, ',');
        if (values.length == 4) {
          int buttonState = int(values[3]);
          if (buttonState == 0) {
            gameStarted = true;
            restartRace();
          }
        }
      }
    }
    return;
  }
  
  displayStartScreen();
  // display the time
  if (!raceFinished) {
    int currentTime = millis() - startTime;
    fill(255);
    textAlign(RIGHT, TOP);
    text("Current race time: " + nf(currentTime / 1000.0, 0, 2) + " seconds", width - 20, 20);
  }
  
  if (myPort.available() > 0) {  // If data is available,
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
  
  if (raceFinished) {
    displayRaceFinished();
  }
}

void displayStartScreen() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Press the button to start the race!", width / 2, height / 2);
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
  // Make grass
  background(50, 200, 50);
  noFill();
  stroke(100, 100, 100);
  strokeWeight(90);
  
  // Draw the track using multiple bezier curves
  beginShape();
  vertex(50, 600);
  bezierVertex(200, 580, 300, 420, 400, 500);
  bezierVertex(500, 600, 600, 400, 700, 460);
  bezierVertex(800, 520, 900, 300, 1000, 380);
  bezierVertex(1100, 460, 1200, 500, 1300, 400);
  endShape();
}

void renderCar() {
  pushMatrix();
  translate(carX, carY);
  rotate(radians(carAngle));
  imageMode(CENTER);
  image(carImage, 0, 0, 40, 20);
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
  
  float turnAngle = map(joystickY, 0, 4095, -45, 45);
  if (abs(turnAngle) < 4.8) {
    carAngle = carAngle * 1;
  } else {
    carAngle += turnAngle * 0.05;
  }
  
  float throttle = map(potValue, 0, 4095, 0, 5);
  float moveDirection = map(joystickX, 0, 4095, 1, -1);
  
  speed = throttle * moveDirection * 5;
  
  carX += cos(radians(carAngle)) * speed;
  carY += sin(radians(carAngle)) * speed;

  // Check if the car is within the bezier track
  if (!isWithinTrack(carX, carY)) {
    speed = 0;  // Stop the car if it's outside the track
  }

  // Check if within bounds
  if (carX < 0) { carX = 0; }
  if (carX > width) { carX = width; }
  if (carY < 0) { carY = 0; }
  if (carY > height) { carY = height; }
}

// Check if the car is within the bounds of the track
boolean isWithinTrack(float x, float y) {
  // You can implement more sophisticated collision detection here
  // For simplicity, we will use the distance to the track edge
  float minDistanceToTrack = 50; // Example distance to define "within track"
  
  // Add logic to calculate the actual distance from the car to the track edges
  // For simplicity, this is a rough check; you might want to sample points along the track
  float distanceToTrack = dist(x, y, 700, 500); // Replace with actual track edge positions
  
  return distanceToTrack < minDistanceToTrack; // Adjust condition as needed
}


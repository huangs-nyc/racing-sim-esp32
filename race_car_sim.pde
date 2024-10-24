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
PShape track;  // Define a shape for the track

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
  
  track = createTrack(); // Create a PShape object for the track
}

void draw() {
  background(0);

  if (!gameStarted) {
    displayStartScreen();
    return;
  }

  // Check for new serial data
  if (myPort.available() > 0) {
    val = myPort.readStringUntil('\n');
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

  renderTrack();  // Draw the track

  if (!raceFinished) {
    int currentTime = millis() - startTime;
    fill(255);
    textAlign(RIGHT, TOP);
    text("Current race time: " + nf(currentTime / 1000.0, 0, 2) + " seconds", width - 20, 20);
  }

  renderCar();
  checkRaceCompletion();
  
  if (raceFinished) {
    displayRaceFinished();
  }

  // Display speed at bottom left
  fill(255);
  textAlign(LEFT, BOTTOM);
  text("Speed: " + nf(speed, 0, 2), 20, height - 20);
}

// Function to create the track shape
PShape createTrack() {
  PShape s = createShape();
  s.beginShape();
  
  float trackWidth = 120;
  float waveHeight = 350;
  float segmentWidth = width / 4;

  // Create the outer edge of the track (bezier curve)
  s.vertex(0, height / 2);
  s.bezierVertex(segmentWidth / 3, height / 2 - waveHeight, 
                 segmentWidth * 2 / 3, height / 2 - waveHeight, 
                 segmentWidth, height / 2);
  s.bezierVertex(segmentWidth * 4 / 3, height / 2 + waveHeight, 
                 segmentWidth * 5 / 3, height / 2 + waveHeight, 
                 segmentWidth * 2, height / 2);
  s.bezierVertex(segmentWidth * 7 / 3, height / 2 - waveHeight, 
                 segmentWidth * 8 / 3, height / 2 - waveHeight, 
                 segmentWidth * 3, height / 2);
  s.bezierVertex(segmentWidth * 10 / 3, height / 2 + waveHeight, 
                 segmentWidth * 11 / 3, height / 2 + waveHeight, 
                 segmentWidth * 4, height / 2);
  
  s.endShape();
  return s;
}

void renderTrack() {
  shape(track);
}

void renderCar() {
  pushMatrix();
  translate(carX, carY);
  rotate(radians(carAngle));
  imageMode(CENTER);
  image(carImage, 0, 0, 40, 20);
  popMatrix();
}

// Adjust car to stay within the Bézier track
void updateCar(int joystickX, int joystickY, int potValue, int buttonState) {
  if (buttonState == 0) {
    restartRace();
    return;
  }

  float turnAngle = map(joystickY, 0, 4095, -40, 40); // Sharper turns
  carAngle += turnAngle * 0.05;

  float throttle = map(potValue, 0, 4095, 0, 5);
  float moveDirection = map(joystickX, 0, 4095, 1, -1);

  speed = throttle * moveDirection * 8;

  carX += cos(radians(carAngle)) * speed;
  carY += sin(radians(carAngle)) * speed;

  // Restrict car's position within the track's outer and inner bounds
  float trackLeft = 0;
  float trackRight = width;
  float trackTop = (height / 2) - 350;
  float trackBottom = (height / 2) + 350;

  if (carX < trackLeft) carX = trackLeft;
  if (carX > trackRight) carX = trackRight;
  if (carY < trackTop) carY = trackTop;
  if (carY > trackBottom) carY = trackBottom;
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
  if (carX > 1440 && !raceFinished) {
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
  text("You finished the time trial!", width / 2, height / 2 - 50);
  
  textSize(30);
  float raceTime = (finishTime - startTime) / 1000.0;
  text("Your time: " + nf(raceTime, 0, 2) + " seconds", width / 2, height / 2 + 20);
  
  textSize(20);
  text("Press the button to restart the time trial.", width / 2, height / 2 + 80);
}

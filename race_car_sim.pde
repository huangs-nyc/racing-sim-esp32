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
boolean offTrack = false;  // New flag for off-track detection
int startTime;
int finishTime;
PFont font;

PImage carImage;

int canvasSize = 100;
int analogMax = 4095;

boolean gameStarted = false;

void setup()
{
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

void draw()
{
  background(0);
  
  if (!gameStarted) {
    displayStartScreen();
    if ( myPort.available() > 0) {  // If data is available,
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
  
  // Off-track state handling
  if (offTrack) {
    displayOffTrackScreen();
    if ( myPort.available() > 0) {  // Check button press to restart
      val = myPort.readStringUntil('\n');         
      if (val != null) {
        val = trim(val);
        String[] values = split(val, ',');
        if (values.length == 4) {
          int buttonState = int(values[3]);
          if (buttonState == 0) {
            restartRace();
          }
        }
      }
    }
    return;  // Skip the rest of the game loop while off-track
  }

  // Main game logic
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
  
  // Check if car is off the track (touching the green background)
  if (!raceFinished && checkOffTrack()) {
    offTrack = true;
  }
  
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

void displayStartScreen() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Press the button to start the race!", width / 2, height / 2);
}

void displayOffTrackScreen() {
  fill(0, 150);
  rect(0, 0, width, height);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("You went off track!", width / 2, height / 2 - 50);
  
  textSize(30);
  text("Press the button to restart.", width / 2, height / 2 + 20);
}

void restartRace() {
  carX = 100;
  carY = 100;
  carAngle = 0;
  speed = 0;
  raceFinished = false;
  offTrack = false;  // Reset off-track flag
  startTime = millis();
}

void checkRaceCompletion() {
  if (carX >= width && !raceFinished) {  // Finish point is at the far right
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
  // Track parameters
  float trackWidth = 120;
  
  background(50, 200, 50);  // Green background
  noFill();
  
  // Draw outer and inner track borders
  strokeWeight(trackWidth);
  strokeCap(ROUND);
  strokeJoin(ROUND);
  
  // Asphalt color
  stroke(69, 69, 69);
  
  // Main track path using bezier curves to create waves
  beginShape();
  vertex(0, height / 2);
  
  // Create a series of bezier curves that form a wave pattern
  float waveHeight = 350;
  float segmentWidth = width / 4;
  
  // Wave 1
  bezierVertex(segmentWidth / 3, height / 2 - waveHeight, 
               segmentWidth * 2 / 3, height / 2 - waveHeight,
               segmentWidth, height / 2);
               
  bezierVertex(segmentWidth * 4 / 3, height / 2 + waveHeight,
               segmentWidth * 5 / 3, height / 2 + waveHeight,
               segmentWidth * 2, height / 2);
               
  // Wave 2
  bezierVertex(segmentWidth * 7 / 3, height / 2 - waveHeight,
               segmentWidth * 8 / 3, height / 2 - waveHeight,
               segmentWidth * 3, height / 2);
               
  bezierVertex(segmentWidth * 10 / 3, height / 2 + waveHeight,
               segmentWidth * 11 / 3, height / 2 + waveHeight,
               segmentWidth * 4, height / 2);
  
  endShape();
}

void renderCar() {
  pushMatrix();
  translate(carX, carY);
  rotate(radians(carAngle));
  imageMode(CENTER);
  image(carImage, 10, 40, 40, 20);
  popMatrix();
}

void updateCar(int joystickX, int joystickY, int potValue, int buttonState) {
  if (buttonState == 0) {
    restartRace();
    return;
  }
  
  float turnAngle = map(joystickY, 0, 4095, -40, 40);  // Sharper turns
  carAngle += turnAngle * 0.05;  // Increased rotation for sharper turning
  
  float throttle = map(potValue, 0, 4095, 0, 5);
  float moveDirection = map(joystickX, 0, 4095, 1, -1);
  
  speed = throttle * moveDirection * 8;
  
  carX += cos(radians(carAngle)) * speed;
  carY += sin(radians(carAngle)) * speed;
  
  // Stay within track borders (simple boundary check)
  float trackLeft = 0;
  float trackRight = width;
  float trackTop = (height / 2) - 350;
  float trackBottom = (height / 2) + 350;
  
  if (carX < trackLeft) carX = trackLeft;
  if (carX > trackRight) carX = trackRight;
  if (carY < trackTop) carY = trackTop;
  if (carY > trackBottom) carY = trackBottom;
}

boolean checkOffTrack() {
  // Get the car's corners for better off-track detection
  int carWidth = 40;  // Width of the car image
  int carHeight = 20; // Height of the car image
  
  // Define the positions of four corners
  float[] carCornersX = {
    carX + cos(radians(carAngle)) * (carWidth / 2),
    carX - cos(radians(carAngle)) * (carWidth / 2),
    carX + cos(radians(carAngle + 90)) * (carHeight / 2),
    carX - cos(radians(carAngle + 90)) * (carHeight / 2)
  };
  
  float[] carCornersY = {
    carY + sin(radians(carAngle)) * (carWidth / 2),
    carY - sin(radians(carAngle)) * (carWidth / 2),
    carY + sin(radians(carAngle + 90)) * (carHeight / 2),
    carY - sin(radians(carAngle + 90)) * (carHeight / 2)
  };
  
  // Check the color under each corner of the car
  color greenColor = color(50, 200, 50);
  
  for (int i = 0; i < 4; i++) {
    int x = int(carCornersX[i]);
    int y = int(carCornersY[i]);
    
    // Ensure the position is within the canvas bounds
    if (x >= 0 && x < width && y >= 0 && y < height) {
      color currentColor = get(x, y);
      // If any corner is off the track (on the green background), return true
      if (currentColor == greenColor) {
        return true;
      }
    }
  }
  
  return false;  // All corners are within the track
}

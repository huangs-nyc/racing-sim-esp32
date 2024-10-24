PShape track;  // Define a shape for the track

void setup() {
  size(1440, 780);
  carImage = loadImage("car.png");
  font = createFont("Arial", 20, true);
  textFont(font);
  
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600); // Ensure baudrate matches your Arduino
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

void renderCar()

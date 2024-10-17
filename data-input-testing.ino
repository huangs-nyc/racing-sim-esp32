int joystickXPin = 34; // Pin connected to joystick X-axis
int joystickYPin = 35; // Pin connected to joystick Y-axis
int potPin = 32;       // Pin connected to potentiometer
int buttonPin = 25;    // Pin connected to button

void setup() {
  Serial.begin(115200); // Initialize serial communication
  pinMode(buttonPin, INPUT_PULLUP); // Button
}

void loop() {
  // Read joystick and potentiometer values
  int joystickX = analogRead(joystickXPin);  // 0 to 4095 range
  int joystickY = analogRead(joystickYPin);  // 0 to 4095 range
  int potValue = analogRead(potPin);         // 0 to 4095 range
  int buttonState = digitalRead(buttonPin);  // HIGH when not pressed, LOW when pressed

  // Send the data over Serial in a format the laptop can read
  Serial.print(joystickX);
  Serial.print(",");
  Serial.print(joystickY);
  Serial.print(",");
  Serial.print(potValue);
  Serial.print(",");
  Serial.println(buttonState);

  delay(50);  // Send data every 50ms
}

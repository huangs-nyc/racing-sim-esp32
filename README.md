# About

This project focuses on using ESP32 LILYGO TTGO boards, a joystick, a button, and a potentiometer in order to
create an interactive game, displayed on a laptop screen. This project utilizes Arduino IDE for sensory input
setup and testing, and Processing (file in Java) for running the game.

This game spawns a car on a track, and you must try to keep on the right lane of the track, and
get to the end as fast as possible. There is a speed tracker and a race time tracker on screen as well.

Demo URL: https://youtu.be/L3pJh7pFlN4
Blog Post URL: https://steven-ces-blog.notion.site/Race-Car-Simulator-11b4dc2df41c808ba29cd394c15fe13f?pvs=4

# Breadboard Setup

Materials needed:
<ul>
  <li>Breadboard</li>
  <li>Joystick</li>
  <li>Button</li>
  <li>Potentiometer</li>
  <li>Accompanying wires</li>
  <li>ESP32 LILYGO TTGO</li>
  <li>USB-C data transfer cable</li>
</ul>

The code in this repo works with a specific breadboard setup. Here is the breadboard setup that you should follow: [insert image here]

# Software Setup

Sensory input and testing:

Make sure that you have the Arduino IDE software and your ESP32 software installed. If you do not
have Arduino IDE or tehe ESP32 LILYGO TTGO software, follow these instructions to install them: https://coms3930.notion.site/Lab-1-TFT-Display-a53b9c10137a4d95b22d301ec6009a94.

Once you have this installed, connect your board to the Arduino IDE, and upload and run the code from the data-input-testing.ino file. Open your
serial monitor, and if your breadboard connections are correct, you will see four values, separated by commas. The first is the x-acis input, which
defaults to the axis perpendicular to the extruding wires. The y-axis is parallel to it, and it is the second value. The third is the value
of the potentiometer, and the fourth is the button state. Adjust your components and check if the values are changing in the monitor
accordingly.

Running the game:

Make sure that you have Processing installed. Open Processing and upload the code in car-racing-sim.pde, then hit play. A screen should come up on 
the starting screen prompting you to hit the button and start the game. From there, you can use the button to restart anytime in the game, including 
when prompted when you veer too far off of the right lane of the track, as well as when you finish the game.You can use the potentiometer to
adjust the base speed of the car, and the joystick for turning, as well as extra acceleration in the direction the car is moving.

Something to note about this setup is that I switched the axes in terms of input in order to make it work with my enclosure. The default would be using the
y-axis to move forward and backward and x-axis to turn. However, since my enclosure forced my wires sideways, I switched them. To adjust which access you want to use,
go to the updateCar() function and change the first paramter for carAngle and moveDirection to fit your needs.

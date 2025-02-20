# Advanced Movement Script for Godot 4

Movement script is for Godot 4's `CharacterBody3D` node, fully customizable. Uses static typing for improved performance and maintainability.
All the features can be toggled on/off in editor

## Features

- **Statically Typed GDScript**  
  For better performance

- **State Machine Based Movement**  
  This makes it easier if you want to add more states for your needs

- **Full Control of Movement Dynamics**  
  - **Ground Movement:** Customizable walking, sprinting, acceleration speeds and ground friction.
  - **Air Control:** Tune maximum air speed, acceleration, and an air strafe multiplier for better aerial maneuverability.
  - **Crouch Functionality:** Configurable height, transition speed and crouch movement speed.
  - **Uses raycast to check for collisions above the player to automatically stay crouched in tight spaces**
  - **No jittering on object edges when using high refresh monitors (tested on 280hz monitor).**
  
- **Camera Effects**  
  - **Head Bobbing:** Adjustable camera bobbing strenght and frequency when moving.
  - **Field-of-View (FOV) Changes:** Adjustable dynamic FOV adjustments while sprinting.
  - **Camera Tilt:** Adjustable tilt effect when strafing.

- **Customizable Mouse Sensitivity**  
  Slider for mouse sensitivity

- **Inertia**  
  Inertia for slightly more realistic acceleration

## Installation to your current project

1. Simply put **player** folder in your project folder
2. Add input map in your project settings: **left, right, up, down, jump, sprint, crouch**
3. **Alternatively just use my preset project and start building from there**


## Configuration

All the parameters are exposed as export variables for tweaking directly from the Godot editor.
Feel free to adjust and expand upon the script to better fit your project

## License

This project is released into the public domain via the Unlicense. Anyone is free to use, modify, publish, and distribute this software without any restrictions, including the need for credit or attribution.

For more details, see the [Unlicense](http://unlicense.org/).

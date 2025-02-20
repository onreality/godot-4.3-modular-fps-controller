# Advanced Movement Script for Godot 4

Movement script is for Godot 4's `CharacterBody3D` node, fully customizable. Uses static typing for improved performance and maintainability.

## Features

- **Statically Typed GDScript**  
  For better performance

- **State Machine Based Movement**  
  This makes it easier if you want to add more states for your needs

- **Full Control of Movement Dynamics**  
  - **Ground Movement:** Customizable walking and sprinting speeds.
  - **Air Control:** Fine-tune maximum air speed, acceleration, and an air strafe multiplier for precise aerial maneuverability.
  - **Crouch Functionality:** Smooth transition between standing and crouching with configurable heights and speeds.
  
- **Camera Effects**  
  - **Head Bobbing:** Realistic camera bobbing when moving.
  - **Field-of-View (FOV) Changes:** Dynamic FOV adjustments while sprinting.
  - **Camera Tilt:** adjustable tilt effect when strafing.

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

# Mario & Luigi Engine

A fan-made 2D engine inspired by the **Mario & Luigi RPG** series (like Superstar Saga and Bowser's Inside Story), built in Godot.  
It focuses on **turn-based battles**, **overworld exploration**, and **interactive NPCs**.

---

## Features

### Overworld
- **Free Movement**: Smooth 8-directional walking with jump mechanics. (Use Dpad for DS-style movement and Analog for Dream Team style)
- **Character Interaction**: Talk to NPCs, trigger cutscenes, and activate objects.
- **Collision & Y-Sorting**: Walk behind/around objects and NPCs realistically.
- **Block System**: Breakable or interactive blocks that give items or trigger events.
- **Room System**: Easily define different maps/rooms with automatic global setup.

### Battle System
- **Turn-Based Combat**: Modeled after Mario & Luigi's timing-based system.
- **Action Commands**: Time button presses to increase damage or avoid enemy attacks.
- **Target Selection**: Choose specific enemies or allies.

### UI & Misc
- **Dialogue System**: RichTextLabel-based, supports colors, and formatting.
- **Menu Navigation**: Smooth menu transitions and selection sounds.
- **Sound Integration**: Feedback sounds for selecting targets, opening menus, etc.
- **DiscordRPC Integration**: Shows room names and status in Discord.

---

## To-Do

### Overworld
- [ ] Overworld Bros abilities (e.g., Spin jump, Mario hammer smash).
- [ ] Puzzle object interactions (bridges, switches, destructibles).
- [ ] Cutscene scripting tools for events and story sequences.
- [ ] Overworld enemy encounters that trigger battles.

### Battle System
- [ ] Enemy AI patterns with unique attack timing.
- [ ] Enemy targeting logic (single, multi-hit, random).
- [ ] Player badge/gear system for custom abilities & stat boosts.
- [ ] Status effects (poison, sleep, dizzy, etc.).
- [ ] EXP and level-up system with stat allocation.

### UI & Experience
- [ ] In-battle health/BP indicators.
- [ ] Fully functional pause & settings menu.
- [ ] More polished dialogue effects (text speed, sound per letter).
- [ ] Battle intro animations.

---

## How to Use
1. **Open in Godot**: Clone/download this repo and open the project in Godot.
2. **Run a Scene**: Start with the main overworld scene (`Overworld Test.tscn`) to test movement and interaction.
3. **Battle Testing**: Open the battle test scene to try turn-based combat features.
4. **Add Content**: Create your own maps, NPCs, and battles using provided templates.

---

## Disclaimer
This project is a **fan work** and is not affiliated with or endorsed by Nintendo.  
All Mario & Luigi characters, settings, and related trademarks belong to their respective owners. This engine is for educational and non-commercial purposes only.

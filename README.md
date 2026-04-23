## Overview

Welcome to Tallin is a game for international students that just got here and dont know what to do.
    Play Here: https://levartar.itch.io/new-to-tallinn

## Working with this Project:
Get git if you dont already have it. Download this project using:

```bash
git clone https://github.com/Levartar/oil-driver.git
```

Open Godot and import the created folder. Get Godot 4.6.1 here: https://godotengine.org/download/. Do **NOT** get the .NET version


    oil-driver/
    ├── project.godot
    ├── README.md
    ├── .gitignore
    ├── assets/                 <- ART
    │   ├── Models/
    │   ├── Textures/
    │   └── Environments/
    ├── audio/
    │   ├── music/
    │   └── soundfx/
    ├── game/                   
    │   ├── autoload/
    │   ├── cars/               
    │   │   ├── car.tscn        <- CAR CHARACTER
    │   │   └── car.gd
    │   ├── levels/
    │   │   └── Level.tscn      <- LEVEL/WORLD
    │   ├── obstacles/
    │   └── ui/
    ├── planning/
    └── translation/
 
### Car 
Can be edited with godot and tweaked under properties:
![alt text](planning/car-editor.png)
### Level
Detailed instruction will follow soon sorry.
Basically 
1. copy level
2. edit level using GridMap

![alt text](planning/world-editor.png)

**Before implementing a new feature create a new branch!** Name them `feature/your-feature-name`.

```bash
git branch feature/your-feature-name
```

## Current Tasks

- [X] **Reset Button** - Add in-game reset functionality
- [X] **Testing Toggles** - Developer testing options in settings
    - [X] Auto acceleration
- [X] **Freeflow Camera** - Implement dynamic camera system
- [ ] **Add Licenses** - HDM Licenses Button
- [ ] **Add Sounds** - Music, Environments
- [ ] **Particle Effects** - Movement Dust, Speed stripes, Scene Dust, Fog
- [X] **3D Character** - Character for first scenes
- [X] **Questlog** - Bar that shows all completed and upcoming quests
- [X] **Dialog System** - Landmark Message Broadcast 
- [ ] **Gyms and Zoos** - Create test Levels for Designers

## Known Problems
If assets on itch are missing the pipeline is missing imports. Run `git add -f .godot/imported/*`

## Stack

The project utilizes a variety of specialized development and management tools:

    Engine: Godot.
    Art & Modeling: Blender, Crocotile3d, Picocad, and Canva.
    Management & Version Control: Jira, Git, Google Workspace, and lettucemeet.
    Communication: Discord and WhatsApp.

## Team

The project is being developed by Team 3, consisting of the following members:

    Producer: Asjad 
    Game Designer: Sunny 
    Programmer: Jakob 
    Artist: Alicja

To play dialogue in your Godot project using DialogueQuest, you need to set up a specific scene hierarchy and then trigger the dialogue through code.

### 1. Scene Setup
[cite_start]Before playing dialogue, you must instantiate the following components (as scenes, not just scripts) in your Godot scene[cite: 67, 77, 78]:

* [cite_start]**CanvasLayer**: Used as the parent node[cite: 68].
* [cite_start]**DQDialoguePlayer**: The core node that manages the dialogue state[cite: 71].
* [cite_start]**DQDialogueBox**: The UI component that displays text[cite: 72].
* [cite_start]**DQChoiceMenu**: The UI component for player choices[cite: 73].

**Configuration Steps:**
* [cite_start]Select the **DQDialoguePlayer** node in your editor[cite: 74].
* [cite_start]Assign the **DQDialogueBox** and **DQChoiceMenu** nodes to their respective slots in the inspector[cite: 74].
* [cite_start]Create and assign a **DQDialoguePlayerSettings** resource to the player node[cite: 75].

### 2. File Organization
[cite_start]For the system to find your dialogue files easily, ensure they are in the **Data Directory**[cite: 62]:
* [cite_start]Check your Data Directory path under **Project -> Project Settings -> General -> Dialogue Quest**[cite: 30].
* [cite_start]The default path is `res://dialogue_quest/`[cite: 31].
* [cite_start]Dialogue files should be saved with the **.dqd** extension[cite: 61].

### 3. Starting the Dialogue
[cite_start]To trigger the dialogue from a script, call the `.play()` method on the **DQDialoguePlayer** node[cite: 82]. [cite_start]You can reference the file in three ways[cite: 83, 85, 87]:

| Method | Example Code |
| :--- | :--- |
| **By Name Only** | `dialogue_player.play("my_dialogue_name")` |
| **By Filename** | `dialogue_player.play("my_dialogue_name.dqd")` |
| **By Full Path** | `dialogue_player.play("res://dialogue_quest/my_dialogue_name.dqd")` |

> [cite_start]**Note:** If your `.dqd` file is **not** located in the designated Data Directory, you must provide the full file path to the `.play()` method[cite: 88, 89].

### 4. Stopping the Dialogue
[cite_start]If you need to end the dialogue session before it finishes naturally, use the following method[cite: 91]:
```gdscript
dialogue_player.stop()
```
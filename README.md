# StateManager

A [Godot](https://godotengine.org/) plugin that adds different states for nodes.

## Installation

1. Download the `addons` folder from this repository.
2. Place it into your project's root folder.
3. Go to `Project > Project Settings > Plugins` and enable StateManager plugin

## Usage

### StateManager
It is the node that will manage the states that have been assigned to it. Add a `StateManager` on any node where you want to have states.

- *autostart*: If `true` then the state loop begins automatically at the start.
- *one_loop*: If `true` then the state loop stops indefinitely when it ends.

- **start()**:  Starts the state loop.
- **stop()**: Pauses the state loop.
- **get_current_state_tag()**: Returns the current state tag.

### State
Is the base class of all the states. To use a state simply add it as a child of a `StateManager` and configure it (Depending on the type of state). This class is not intended to be added directly to the scene tree.

- *tag*: The tag with which the state will be identified.

### StateCondition
This state will be active until the assigned property becomes `false` (`true` if *negative_condition* is activated).

- *node_path*: The node where the property is located.
- *property_name*: The property name. It can be both a variable or a method, as long as they return boolean values.

### StateTimer
This state will be active until the specified seconds have passed.

- *wait_time*: The seconds in which the state will be active.

### StateRandTimer
Similar to StateTimer only the timeout will be a random value from a range specified in `from` and `to`.

## Assets
The sprites of the example project were made by [ZeggyGames](https://zegley.itch.io/).

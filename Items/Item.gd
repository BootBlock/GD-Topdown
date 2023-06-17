class_name Item extends Node2D

## If true, debug information relating to the Item will be printed to the output if debug() is used.
@export var debug_output := false

## Determines the stance the item places the player into.
@export var stance: Player.stances

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Prints debugging information to the output if debug_output is set to true; otherwise, output is suppressed.
func debug(data) -> void:
	if self.debug_output:
		print(str(data))

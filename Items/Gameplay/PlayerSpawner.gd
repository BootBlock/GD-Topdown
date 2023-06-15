# PlayerSpawner.gd
extends Node2D

## Gets the number of times a player has spawned at this location; allows reuse, if required (e.g. more players than spawners).
var used_count: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# The spawner is only used for specifying a position, and nothing else;
	# so outright disable it - it can still be found via the player spawner.
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED

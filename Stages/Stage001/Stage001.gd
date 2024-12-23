# Stage001.gd
extends Node2D

## Configuration for the stage.
@export var stage_config: StageConfigResource

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(self.stage_config != null, "A stage_config needs to be set.")

	RenderingServer.set_default_clear_color(self.stage_config.background_color)

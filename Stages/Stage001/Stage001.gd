# Stage001.gd
extends Node2D

## Configuration for the stage.
@export var stage_config: StageConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(self.stage_config.background_color)

# Pickup.gd
extends Node2D

## The sound effect to play when the item is picked up.
@export var pickup_sound: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


# Someone ran over the pickup.
func _on_pickup_area_2d_area_entered(area: Area2D) -> void:
	print(area.owner.name + " ran over the pickup.")

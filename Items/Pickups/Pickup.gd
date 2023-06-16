# Pickup.gd
class_name Pickup extends Node2D

# Can't get the Item class to work, so using a PackedScene for now.
## The backing Item that the pickup represents; when obtained, this is what the Player will be given.
@export var item: PackedScene

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

	if area.owner is Player:
		area.owner.give(self)

	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($Sprite2D, "scale", Vector2(3, 3), 0.4)

	if self.pickup_sound:
		$AudioStreamPlayer2D.stream = self.pickup_sound				# Node will be freed after sound finishes playing
		$AudioStreamPlayer2D.play()
	else:
		tween.tween_callback(self.queue_free)						# Node will be freed after the tween has finished

func _on_audio_stream_player_2d_finished() -> void:
	self.queue_free()

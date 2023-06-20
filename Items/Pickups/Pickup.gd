# Pickup.gd
class_name Pickup extends RigidBody2D

## If true, debug information relating to the Item will be printed to the output if debug() is called.
@export var debug_output := false

# Can't get the Item class to work, so using a PackedScene for now.
## The backing Item that the pickup represents; when obtained, this is what the Player will be given.
@export var item_packedscene: PackedScene

## Only works via code (e.g. creating a new instance of a Pickup from an existing Item).
@export var item: Item

## The sound effect to play when the item is picked up.
@export var pickup_sound: AudioStream

## Don't allow pick-up by this player; used when dropping an item on the
## ground so that the player doesn't immediately pick it up again.
## The Player is then removed on a short timer so they can eventually pick the item up again.
var ignore_player: Player

var sprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.sprite = self.get_node("Sprite2D")
	pass # Replace with function body.

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
#	pass

# Someone ran over the pickup.
func _on_pickup_area_2d_area_entered(area: Area2D) -> void:
	self.debug(area.owner.name + " ran over the pickup.")

	if not area.owner is Player:
		return

	# Typically used to prevent a Player from picking up an item that they're in the process of throwing.
	if self.ignore_player == area.owner:
		return

	area.owner.give(self)

	# Prevent the player from being unable to walk over the pickup.
	if !self.get_collision_exceptions().has(area.owner):					# Surely layers/masks can do this? Can't seem to get it working, if so!
		self.add_collision_exception_with(area.owner)

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

## Prints debugging information to the output if debug_output is set to true; otherwise, output is suppressed.
func debug(data) -> void:
	if self.debug_output:
		print(str(data))

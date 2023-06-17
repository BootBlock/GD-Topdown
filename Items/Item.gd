class_name Item extends Node2D

## The item has been thrown by the specified Player.
signal item_thrown(player: Player)

## If true, debug information relating to the Item will be printed to the output if debug() is called.
@export var debug_output := false

## The image that represents the item within the world or displayed in the HUD.
@export var world_image: Texture2D

## Determines the stance the item places the player into.
@export var stance: Player.stances

@onready var pickup_scene = preload("res://Items/Pickups/Pickup.tscn")

## Gets the Player that owns this instance.
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

## Drops the item to the ground.
func drop() -> void:
	print("Item.drop()")

## Throws the item.
func throw() -> void:
	print("Item.throw()")
	var pickup = self._create_pickup_for_item()

	# Add the player to the ignore list so they don't pick the pickup up (!) as it's being dropped.
	pickup.ignore_player = self.player

	# Add the new pickup to the current stage.
	GameState.main_scene.current_stage.add_child(pickup)

	# Pickup node needs to have been added to the scene for the sprite property to be available so we can update it.
	pickup.sprite.texture = self.world_image

	# Throw the item in the player's direction and add a bit of random rotation to it.
	pickup.apply_central_impulse(Vector2.RIGHT.rotated(self.player.rotation).normalized() * 1000)
	pickup.angular_velocity = randi_range(1, 12)

	self.player.remove_active_item()

	# Notify any subscribers that the item has just been thrown.
	self.item_thrown.emit(self.player)

	# Wait for 300ms before allowing the player to pick the item back up (prevents insta-pickup upon a throw).
	get_tree().create_timer(0.3).timeout.connect(func(): pickup.ignore_player = null)

## Repackage an existing item into a Pickup that can be dropped on the battlefield and picked up another time.
func _create_pickup_for_item() -> Pickup:
	var pickup = self.pickup_scene.instantiate() as Pickup

	pickup.item = self
	pickup.position = self.player.position

	return pickup

## Prints debugging information to the output if debug_output is set to true; otherwise, output is suppressed.
func debug(data) -> void:
	if self.debug_output:
		print(str(data))


func _on_cleared_ignored_player_timer_timeout() -> void:
	print("CLEARED!")

# thrown.gd
class_name Thrown extends RigidBody2D

## The item has been thrown by the specified Player.
signal item_thrown(player: Player)

## If true, debug information relating to the Item will be printed to the output if debug() is called.
@export var debug_output := false

## The Item being represented by the Thrown.
@export var item_resource: ItemResource

@onready var pickup_scene = preload("res://Items/Pickups/Pickup.tscn")

## Gets the Player that owns this instance.
var player: Player

## Throws the item.
func throw() -> void:
	self.debug("throw(); creating pickup from item and throwing it.")

	# TODO: Pickup.gd should take care of this item repackaging functionality.
	var pickup = self._create_pickup_for_item()

	# Add the player to be ignored so they don't pick the pickup up (!) as it's being dropped.
	pickup.ignore_player = self.player

	# Add the new pickup to the current stage.
	GameState.main_scene.current_stage.add_child(pickup)

	# Pickup node needs to have been added to the scene (above line) for the sprite property to be available so we can update it.
	pickup.sprite.texture = self.item_resource.world_image

	# Throw the item in the player's direction and add a bit of random rotation to it.
	pickup.apply_central_impulse(Vector2.RIGHT.rotated(self.player.rotation).normalized() * 500)
	pickup.angular_velocity = randi_range(1, 12)

	self.player.remove_active_item()

	# Notify all subscribers that the item has just been thrown.
	self.item_thrown.emit(self.player)

	# Wait for 300ms before allowing the player to pick the item back up (prevents insta-pickup while throwing).
	get_tree().create_timer(0.3).timeout.connect(func(): pickup.ignore_player = null)

# TODO: This should be moved into Pickup.gd.
## Repackage an existing item into a Pickup that can be dropped on the battlefield and picked up another time.
func _create_pickup_for_item() -> Pickup:
	var pickup = self.pickup_scene.instantiate() as Pickup

	# Doesn't quite work as the values aren't the same (issue is either here or on pick-up?).

	pickup.item = Utility.clone(self) as Item
	pickup.position = self.player.position
	pickup.linear_velocity = self.player.velocity * 10		# Make the throw more powerful based on the Player's speed.

	return pickup

## Prints debugging information to the output if debug_output is set to true; otherwise, output is suppressed.
func debug(data) -> void:
	if self.debug_output:
		print(data)

# EnvironmentItem.gd
class_name EnvironmentItem extends RigidBody2D

## How much health the item has. A value of zero denotes the item is invulnerable.
@export var health: int = 10

## Whether the item explodes when its health reaches zero.
@export var is_explosive: bool = false

## If the environmental item is explosive, determines how much force is applied to surrounding objects.
@export var explosive_force: float = 0

@onready var explosion_sprite: Sprite2D = $ExplosionSprite2D

## The item has been hit, but not destroyed.
signal got_hit(damage: int)

## The item needs to become destroyed.
signal destroying()

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func hit(value: int) -> void:
	self.health -= value

	if self.health > 0:
		self.got_hit.emit(value)
	else:
		if self.is_explosive:
			self.destroy()

## The item has been hit.
func damaged() -> void:
	self.got_hit.emit()

## Immediately destroys the item.
func destroy() -> void:
	self.destroying.emit()

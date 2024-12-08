# Player.gd
class_name Player extends CharacterBody2D

const ANIMATION_ANIM_LINE_FADE_OUT: String = "aim_line_fade_out"

@export var info: PlayerInfoResource
@export var speed := 80

#region OnReady
@onready var stance_idle: Texture2D = preload("res://Players/Player-01-Idle.png")
@onready var stance_pistol: Texture2D = preload("res://Players/Player-01-PistolStance.png")
@onready var stance_rifle: Texture2D = preload("res://Players/Player-01-RifleStance.png")
@onready var flare = preload("res://Items/Weapons/Utility/Flare/Flare.tscn").instantiate()

@onready var stage = get_tree().get_root().get_node("Main")
@onready var stage_items = stage.get_node("Stage/Items")

@onready var throw_node: Node2D = $ThrowNode
@onready var weapon_attachment: Node2D = $WeaponAttachment
@onready var aim_line: Line2D = $AimLine2D
@onready var aim_line_timer: Timer = $AimLineTimerFadeout
@onready var animation_player: AnimationPlayer = $AnimationPlayer
#endregion

var throwables: Array[Thrown] = []
var items: Array[Item] = []
var active_item: Item

var aim_line_is_fading := false

#region Func: _ready
func _ready() -> void:
	pass # Replace with function body.
#endregion

#region Func: _physics_process
func _physics_process(delta: float) -> void:
	self._process_input(delta)
	self.move_and_slide()
#endregion

#region Func: _process_input
func _process_input(_delta: float) -> void:
	# Item selection
	if Input.is_action_just_pressed("switch_item_next"):
		pass
	elif Input.is_action_just_pressed("switch_item_prev"):
		pass
	elif Input.is_action_just_pressed("throw"):
		self.throw_item()
#	elif Input.is_action_just_pressed("drop_item"):
#		self.drop_item()

	var move_dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	var aim_dir = Vector2(Input.get_axis("aim_left", "aim_right"), Input.get_axis("aim_up", "aim_down"))

	if aim_dir != Vector2.ZERO:
		self.aim_line_is_fading = false

		if !self.aim_line.visible:
			var tween = get_tree().create_tween()
			tween.tween_property(self.aim_line, "modulate:a", 1, 0.08)
			self.aim_line.visible = true

		self.rotation = lerp_angle(self.rotation, aim_dir.angle(), 0.5)
	else:
		if !self.aim_line_is_fading and self.aim_line.visible:
			self.aim_line_is_fading = true
			self.aim_line_timer.start()

	self.velocity = move_dir.limit_length(1) * speed
	self.move_and_slide()

	if Input.is_action_just_pressed("primary_attack"):
		pass

	elif Input.is_action_just_pressed("secondary_attack"):
		var new_flare = self.flare.duplicate() as RigidBody2D
		new_flare.global_position = self.throw_node.global_position
		new_flare.rotation = self.rotation

		var throw_strength = randi_range(350, 800)
		new_flare.apply_central_impulse(Vector2(throw_strength, 0).rotated(new_flare.rotation))
		self.stage_items.add_child(new_flare)
#endregion

#region Event: _on_aim_line_timer_fadeout_timeout
# Fades out the aiming line when the user stops actively aiming.
func _on_aim_line_timer_fadeout_timeout() -> void:
	self.animation_player.play(self.ANIMATION_ANIM_LINE_FADE_OUT)
#endregion
#region Event: _on_animation_player_animation_finished
func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == self.ANIMATION_ANIM_LINE_FADE_OUT:
		self.aim_line.visible = false
#endregion

#region Func: give
## Gives an item to the player.
func give(pickup: Pickup) -> bool:
	assert(pickup.item != null, "Player got a pick-up but it didn't have an item/item_packedscene property set.")

	var pickup_item = pickup.item

	if pickup_item is Gun:
		# Remove any existing weapons from the player.
		Utility.free_children(self.weapon_attachment)

		# Add the new weapon and set an appropriate stance for that weapon.
		self.weapon_attachment.add_child(pickup_item)
		self._set_stance(pickup_item.item_resource.stance)

	elif pickup_item is Item:
		print("PLAYER GOT ITEM: " + pickup_item.name)
	else:
		print("PLAYER GOT UNKNOWN ITEM: " + pickup_item.name)

	# Add the item to the player's "inventory".
	self.items.append(pickup_item)

	pickup_item.player = self
	self.active_item = pickup_item

	return true
#endregion

#region Func: remove_active_item
## Removes the item the Player currently has active. Typically used when throwing an item.
func remove_active_item() -> void:
	self.items.erase(self.active_item)
	self.active_item = null

	Utility.free_children(self.weapon_attachment)
	self._set_stance(Player.stances.none)
#endregion

#region Func: drop_item
## Not really implemented, and may be removed in favour of throw_item().
func drop_item() -> void:
	if self.active_item:
		self.active_item.drop()
#endregion
#region Func: throw_item
func throw_item() -> void:
	if self.active_item:
		self.active_item.throw()
#endregion

#region Func: _set_stance
## Change the Player's stance to better match the type of weapon they're holding.
func _set_stance(stance: stances) -> void:
	# TODO: Player.tscn really should have a proper weapon attachment point system
	#		rather than just offsetting the weapon position and changing the player sprite.

	match stance:
		stances.none:
			$Sprite2D.texture = self.stance_idle

		stances.pistol:
			$Sprite2D.texture = self.stance_pistol

		stances.rifle:
			$Sprite2D.texture = self.stance_rifle
#endregion

#region Enum: stances
enum stances {
	## An idle stance; typically a neutral standing position.
	none,

	pistol, rifle, overhand_throw
}
#endregion

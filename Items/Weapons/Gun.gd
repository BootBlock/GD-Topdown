# Gun.gd
class_name Gun extends Item

enum fire_modes { Semiautomatic, Automatic, Burst }
enum gun_sights { None, Dot, Full }

# Signals
## The gun has been fired.
signal gun_fired(ammo_count: int)

## The gun is reloading.
signal gun_reloading(remaining_clips: int)

## The gun has reloaded.
signal gun_reloaded(remaining_clips: int)

@export_category("Gun Mechanics")
## The firing mode of the gun.
@export var fire_mode: fire_modes = fire_modes.Semiautomatic

## The total number of clips. Set to 0 for a clipless gun.
@export var maximum_number_of_clips: int = 0

## The total number of bullets each clip can hold before reloading is required. Set to 0 for an unlimited clip size.
@export var bullets_per_clip: int = 6

## Determines whether the clip automatically reloads as soon as it becomes empty.
@export var clip_auto_reloads: bool = false

## The amount of damage the gun causes.
@export var damage: int = 0

@export_category("Gun Recoil")
@export var recoil_duration = 0.1		# How long the shake lasts for
@export var recoil_frequency = 20		# Speed of the shake
@export var recoil_amplitude = 2		# Amount of the shake
@export var recoil_priority = 0

@export_category("Gun Modifiers")
## Determines the type of sight that is on the gun.
@export var gun_sight: gun_sights = gun_sights.None

@export_category("Gun Sounds")
## The sound effect to play when the primary ability of the gun has been used.
@export var primary_fire_sound: AudioStream

## The sound effect to play when the secondary  ability of the gun has been used.
@export var secondary_fire_sound: AudioStream

## The sound effect to play when the gun is reloading.
@export var reload_sound: AudioStream

## The sound effect to play when the gun is empty; that is, no remaining clips or bullets.
@export var empty_sound: AudioStream

## The total number of remaining clips.
var remaining_clips: int = 1

## The total number of bullets left in the current clip.
var bullets_remaining_in_clip: int = 6

var is_reloading: bool = false

var raycast: RayCast2D
var gunsight_dot_node: Node2D
var gunsight_dot_light: PointLight2D
var primary_attack_timer: Timer
var reload_timer: Timer
var audio_player: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.player = self.owner as Player
	self.raycast = $RayCast2D
	self.gunsight_dot_node = $GunSightDot

	# TODO: Remove the gunsight from the gun; it should be a separate scene.
	if self.gunsight_dot_node:
		self.gunsight_dot_light = self.gunsight_dot_node.get_node("PointLight2D")

	self.primary_attack_timer = $PrimaryFireTimer
	self.reload_timer = $ReloadTimer
	self.audio_player = $AudioStreamPlayer2D

	# The current clip counts towards the clip total; remaining_clips value of 0 indicate unlimited clips.
	self.remaining_clips = self.maximum_number_of_clips - 1 if self.remaining_clips > 0 else self.remaining_clips
	self.bullets_remaining_in_clip = self.bullets_per_clip

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.gun_sight == gun_sights.Dot:		# This lot should be moved into the GunSightDot node
		if self.raycast.is_colliding():
			if !self.gunsight_dot_node.visible:
				self.gunsight_dot_node.set_deferred("visible", true)

			var collider = self.raycast.get_collider()#.owner
			if collider:
				#var origin = self.raycast.global_transform.origin
				var collision_point = self.raycast.get_collision_point()
				#var distance = origin.distance_to(collision_point)

				# Inverse square law: make the shot less precise the further away the (potential) hit target
#				var energy = 1.0 / (1.0 + 25.0 * distance * distance)
#				print(energy)

				self.gunsight_dot_light.set_deferred("visible", true)
#				self.gunsight_dot_light.set_deferred("texture_scale", energy)

				self.gunsight_dot_node.position = self.to_local(collision_point)
				self.gunsight_dot_node.rotation = self.position.angle_to(self.gunsight_dot_node.position)
		else:
			if self.gunsight_dot_node.visible:
				self.gunsight_dot_node.set_deferred("visible", false)

func fire_primary() -> bool:
	if self.is_reloading or !self.primary_attack_timer.is_stopped():
		return false

	if self.bullets_remaining_in_clip > 0:
		self.bullets_remaining_in_clip -= 1
	else:
		if self.maximum_number_of_clips >= 0:
			if self.remaining_clips > 0:
				if self.clip_auto_reloads:
					self.debug("Cannot fire as the clip is empty - forcing reload...")
					return self.reload()
				else:
					self.debug("Cannot fire as the clip is empty and the gun doesn't auto-reload; Player must manually reload.")
					return false
			else:
				if self.empty_sound:
					self.debug("Clip is empty.")
					self.audio_player.stream = self.empty_sound
					self.audio_player.play()
					return false
		else:
			if self.empty_sound:
				self.debug("Clip is empty.")
				self.audio_player.stream = self.empty_sound
				self.audio_player.play()
				return false

	self._update_ammo_display()

	if self.primary_fire_sound:
		self.audio_player.stream = self.primary_fire_sound
		self.audio_player.play()

	GameState.camera_shake.start(self.recoil_duration, self.recoil_frequency, self.recoil_amplitude, self.recoil_priority)
	self.gun_fired.emit()

	if self.raycast.is_colliding():
		var collider = self.raycast.get_collider()#.owner

		self.debug("Gun bullet collided with " + collider.name)

		if collider.has_method("hit"):
			collider.hit(self.damage)
		elif collider.owner.has_method("hit"):
			collider.owner.hit()

	self.primary_attack_timer.start()
	return true

## Reloads the gun, restoring its current available bullet count to the maximum clip size.
func reload() -> bool:
	# The weapon had clips but has now run out, so don't reload.
	if self.maximum_number_of_clips > 0 and self.remaining_clips == 0:
		self.debug("Player ran out of clips and so cannot reload. Skipping reload.")
		return false

	if self.bullets_per_clip == 0:
		self.debug("Unlimited bullets per clip, so reloading isn't required. Skipping reload.")
		return false

	if self.bullets_remaining_in_clip >= self.bullets_per_clip:
		self.debug("Current clip is full, so reloading would just be a waste of a clip. Skipping reload.")
		return false

	if self.is_reloading:
		self.debug("Already reloading. Skipping additional reload.")
		return false

	self.debug("Reloading...")

	self.is_reloading = true
	self.gun_reloading.emit(self.remaining_clips)

	if self.reload_sound:
		self.audio_player.stream = self.reload_sound
		self.audio_player.play()

	self.reload_timer = self.get_node("ReloadTimer")
	self.reload_timer.start()

	# The clip will be reloaded once the timer has timed out.
	return true

func _update_ammo_display() -> void:
	self.debug("Bullets: " + str(self.bullets_remaining_in_clip) + "/" + str(self.bullets_per_clip) + ", Clips: " + str(self.remaining_clips) + "/" + str(self.maximum_number_of_clips))

func _on_primary_fire_timer_timeout() -> void:
	if self.clip_auto_reloads and self.bullets_remaining_in_clip == 0:
		self.reload()

func _on_secondary_fire_timer_timeout() -> void:
	pass # Replace with function body.

func _on_reload_timer_timeout() -> void:
	if self.maximum_number_of_clips > 0:
		self.gun_reloaded.emit(self.remaining_clips)
		self.remaining_clips -= 1

	self.is_reloading = false
	self.bullets_remaining_in_clip = self.bullets_per_clip

	self.debug("Reloaded.")
	self._update_ammo_display()
	return

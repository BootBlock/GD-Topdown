# Gun.gd
class_name Gun extends Node2D

enum fire_modes { Semiautomatic, Automatic, Burst }
enum gun_sights { None, Dot, Full }

# Signals
## The gun has been fired.
signal gun_fired(ammo_count: int)

## The gun is reloading.
signal gun_reloading(remaining_clips: int)

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

## The player that is holding the gun.
var player: Player

## The total number of remaining clips.
var remaining_clips: int = 1

## The total number of bullets left in the current clip.
var bullets_remaining_in_clip: int = 6

var is_reloading: bool = false

var raycast: RayCast2D
var gunsight_dot_node: Node2D
var gunsight_dot_light: PointLight2D
var primary_attack_timer: Timer
var audio_player: AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.player = self.owner as Player
	self.raycast = $RayCast2D
	self.gunsight_dot_node = $GunSightDot
	self.gunsight_dot_light = self.gunsight_dot_node.get_node("PointLight2D")
	self.primary_attack_timer = $PrimaryFireTimer
	self.audio_player = $AudioStreamPlayer2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.gun_sight == gun_sights.Dot:		# This lot should be moved into the GunSightDot node
		if self.raycast.is_colliding():
			if !self.gunsight_dot_node.visible:
				self.gunsight_dot_node.set_deferred("visible", true)

			var collider = self.raycast.get_collider()#.owner
			if collider:
				var origin = self.raycast.global_transform.origin
				var collision_point = self.raycast.get_collision_point()
				var distance = origin.distance_to(collision_point)

				# Inverse square law
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
				print("Player tried to fire an empty clip - forcing reload...")
				return self.reload()
			else:
				if self.empty_sound:
					self.audio_player.stream = self.empty_sound
					self.audio_player.play()
					return false
		else:
			if self.empty_sound:
				print("Clip is empty.")
				self.audio_player.stream = self.empty_sound
				self.audio_player.play()
				return false

	if self.primary_fire_sound:
		self.audio_player.stream = self.primary_fire_sound
		self.audio_player.play()

	GameState.camera_shake.start(self.recoil_duration, self.recoil_frequency, self.recoil_amplitude, self.recoil_priority)
	self.gun_fired.emit()

	if self.raycast.is_colliding():
		var collider = self.raycast.get_collider()#.owner

		print("Gun bullet collided with " + collider.name)

		if collider.has_method("hit"):
			collider.hit(self.damage)
		elif collider.owner.has_method("hit"):
			collider.owner.hit()

	self.primary_attack_timer.start()
	return true

## Reloads the gun, restoring its current available bullet count to the maximum clip size.
func reload() -> bool:
	if self.maximum_number_of_clips > 0 and self.remaining_clips == 0:
		print("Player ran out of clips.")
		return false

	if (self.bullets_per_clip == 0 or self.bullets_remaining_in_clip == self.bullets_per_clip or self.is_reloading):
		print("No need for a reload; skipping.")
		return false

	self.is_reloading = true

	if self.maximum_number_of_clips > 0:
		self.remaining_clips -= 1
		self.gun_reloading.emit(self.remaining_clips)

	if self.reload_sound:
		self.audio_player.stream = self.reload_sound
		self.audio_player.play()

	# The clip will be reloaded once the sound effect has finished playing.

	# Assume the reload succeeded as we currently only support infinite clips.
	return true

# This timer allows auto-reloading to be supported.
func _on_audio_stream_player_2d_finished() -> void:
	if self.is_reloading:									# Reloading time is based on length of the reload sound effect.
		print("Reloaded. Current ammo count was " + str(self.bullets_remaining_in_clip) + " and is now " + str(self.bullets_per_clip))
		self.is_reloading = false
		self.bullets_remaining_in_clip = self.bullets_per_clip

func _on_primary_fire_timer_timeout() -> void:
	if self.clip_auto_reloads and self.bullets_remaining_in_clip == 0:
		self.reload()

func _on_secondary_fire_timer_timeout() -> void:
	pass # Replace with function body.

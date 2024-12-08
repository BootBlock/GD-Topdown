# Landmine.gd
extends RigidBody2D

## If true, debug information relating to the Item will be printed to the output if debug() is called.
@export var debug_output := false

## Gets or sets whether the landmine is active and should trigger on contact.
@export var is_active: bool = true

@onready var active_indicator_sprite: Sprite2D            = $Sprite2D
@onready var active_indicator_light : PointLight2D        = $ActiveIndicatorPointLight
@onready var active_indicator_timer : Timer               = $ActiveIndicatorTimer
@onready var activated_indicator_timer: Timer             = $ActivatedTimer

@onready var trigger_detection_area:  Area2D              = $DetectionArea
@onready var blasting_range_detection_area:  Area2D       = $BlastRangeArea

@onready var sfx_explosion = preload("res://Sounds/DistantExplosion.ogg")

## The items and players within the blast zone for when the landmine is triggered.
var within_blast_range: Array = []

var activation_is_lit: bool = false

## Determines whether any resoures should be freed, typically once the explosion sound has finished playing.
var should_be_freed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.active_indicator_timer.start()

# Something triggered the landmine!
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area == self.blasting_range_detection_area:													# Ignore objects that belong to the landmine itself.
		return

	self.debug("Landmine._on_area_2d_area_entered(): " + area.name)

	$DetectionArea/CollisionShape.set_deferred("disabled", true)
	$AnimationPlayer.play("triggered")

	self.active_indicator_timer.stop()
	self.activated_indicator_timer.start()

	await get_tree().create_timer(0.2).timeout

	for affected in self.within_blast_range:
		if !affected:
			continue

		self.debug("  -> Blast affected: " + affected.owner.name)
		var impulse_strength_at_centre = 52										# Requires tweaking

		if affected.owner is RigidBody2D:
			var body = affected.owner as RigidBody2D
			var direction = (body.position - self.position).normalized()
			var force = impulse_strength_at_centre * direction / (body.position - self.position).length()
			self.debug("     -> Direction: " + str(direction) + ", Force: " + str(force))

			body.apply_central_impulse(force * 42)								# Requires tweaking

	$AudioStreamPlayer.play()

# Flashes the landmine's indicator if it's currently active.
func _on_active_indicator_timer_timeout() -> void:
	self.activation_is_lit = !self.activation_is_lit

	if self.activation_is_lit:
		self.active_indicator_timer.wait_time = 0.1
	else:
		self.active_indicator_timer.wait_time = 2

	self.active_indicator_light.visible = self.activation_is_lit
	self.active_indicator_timer.start()

func _on_activated_timer_timeout() -> void:
	self.active_indicator_light.visible = false

	$AnimationPlayer.play("explosion")
	$DebrisParticles.emitting = true
	$AudioStreamPlayer.stream = self.sfx_explosion
	$AudioStreamPlayer.volume_db = 6																# The explosion is a bit quiet compared to the trap beep
	$AudioStreamPlayer.play()
	$BlastRangeArea/CollisionShape.set_deferred("disabled", true)
	self.should_be_freed = true

	GameState.camera_shake.start()

	var tween = get_tree().create_tween()
	tween.tween_property(self.active_indicator_sprite, "modulate", Color(0.5, 0.5, 0.5), 3)
	self.linear_damp = 2.6

func _on_audio_stream_player_finished() -> void:
	if should_be_freed:
		$AudioStreamPlayer.stream = null
		self.sfx_explosion = null

func _on_blast_range_area_area_entered(area: Area2D) -> void:
	if area == self.trigger_detection_area or area.name == self.blasting_range_detection_area.name:		# Ignore objects that belong to the landmine itself.
		return

	if !self.within_blast_range.has(area):
		self.debug("Entered blast area: " + area.owner.name)
		self.within_blast_range.append(area)

func _on_blast_range_area_area_exited(area: Area2D) -> void:
	if self.within_blast_range.has(area) and area.owner:
		self.debug("Exited blast area: " + area.owner.name)
		self.within_blast_range.erase(area)

## Prints debugging information to the output if debug_output is set to true; otherwise, output is suppressed.
func debug(data) -> void:
	if self.debug_output:
		print(str(data))

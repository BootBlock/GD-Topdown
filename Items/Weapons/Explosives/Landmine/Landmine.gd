# Landmine.gd
extends RigidBody2D

## Gets or sets whether the landmine is active and should trigger on contact.
@export var is_active: bool = true

@onready var active_indicator_sprite: Sprite2D            = $Sprite2D
@onready var active_indicator_light : PointLight2D        = $ActiveIndicatorPointLight
@onready var active_indicator_timer : Timer               = $ActiveIndicatorTimer
@onready var actived_indicator_timer: Timer               = $ActivatedTimer

@onready var trigger_detection_area:  Area2D              = $DetectionArea
@onready var blasting_range_detection_area:  Area2D       = $BlastRangeArea

@onready var sfx_explosion = preload("res://Sounds/DistantExplosion.ogg")

var within_blast_range: Array = []

var activation_is_lit: bool = false

## Determines whether any resoures should be freed, typically once the explosion sound has finished playing.
var should_be_freed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.active_indicator_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Something triggered the landmine!
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area == self.blasting_range_detection_area:													# Ignore objects that belong to the landmine itself.
		return

	$DetectionArea/CollisionShape.set_deferred("disabled", true)

	$AnimationPlayer.play("triggered")

	self.active_indicator_timer.stop()							# TODO: Remove this block once the anim has been implemented
#	self.active_indicator_light.color = Color.RED
#	self.active_indicator_light.visible = true
#	self.active_indicator_sprite.self_modulate = Color.RED
#	self.active_indicator_light.texture_scale = 2.2
#	self.active_indicator_light.energy = 3
#	self.active_indicator_light.visible = true
	self.actived_indicator_timer.start()

	for affected_area in self.within_blast_range:
		print("LANDMINE BLAST AFFECTED: " + affected_area.owner.name)
		var impulse_strength = 100

		if affected_area.owner is RigidBody2D:
			var body = affected_area.owner as RigidBody2D
			var angle = body.rotation
			body.apply_central_impulse(Vector2(cos(angle), sin(angle)) * impulse_strength)

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
	if area == self.trigger_detection_area:															# Ignore objects that belong to the landmine itself.
		return

	if !self.within_blast_range.has(area):
		#print("Entered blast area: " + area.name)
		self.within_blast_range.append(area)

func _on_blast_range_area_area_exited(area: Area2D) -> void:
	if self.within_blast_range.has(area):
		#print("Exited blast area: " + area.name)
		self.within_blast_range.erase(area)






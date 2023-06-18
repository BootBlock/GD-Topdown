# Flare.gd
extends RigidBody2D

const ANIMATION_FIZZLE_OUT: String = "fizzle_out"

@onready var sprite: Sprite2D = $Sprite2D
@onready var lens_flare_sprite: Sprite2D = $LensFlareSprite2D
@onready var smoke_sprite: Sprite2D = $BlackSmogSprite2D
@onready var exhausted_particles: GPUParticles2D = $SmokeParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $DurationTimer
@onready var smoking_timer: Timer = $SmokingTimer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.sprite.rotation = 0					# Prevent the lens flare from rotating - except it doesn't work
	self.lens_flare_sprite.rotation = 0			# ...

func _on_duration_timer_timeout() -> void:
	self.animation_player.play(self.ANIMATION_FIZZLE_OUT)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == self.ANIMATION_FIZZLE_OUT:
		self.exhausted_particles.emitting = true
		self.smoking_timer.start()

func _on_smoking_timer_timeout() -> void:
	self.exhausted_particles.emitting = false

	var tween = get_tree().create_tween()
	tween.tween_property(self.smoke_sprite, "modulate:a", 0, 5)
	tween.tween_callback(self._dead)

func _dead() -> void:
	self.smoke_sprite.visible = false
	self.linear_damp = 2.6

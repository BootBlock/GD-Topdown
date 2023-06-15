# ScreenShake.gd
extends Node

const TRANSITION = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

@onready var parent_camera: Camera2D = self.get_parent()

var amplitude: float = 0
var priority = 0

## Starts a new shake effect.
##
## duration: How long the effect lasts for.
## frequency: How fast the shake moves.
## amplitude: The amount of shake.
func start(duration: float = 0.2, frequency: float = 15, amplitude := 16, priority = 0) -> void:
	if priority >= self.priority:
		self.priority = priority
		self.amplitude = amplitude

		$DurationTimer.wait_time = duration
		$FrequencyTimer.wait_time = 1 / frequency
		$DurationTimer.start()
		$FrequencyTimer.start()

		self._new_shake()

func _new_shake() -> void:
	var rand = Vector2(randf_range(-amplitude, amplitude), randf_range(-amplitude, amplitude))

	var tween = get_tree().create_tween()
	tween.tween_property(self.parent_camera, "offset", rand, $FrequencyTimer.wait_time).from(self.parent_camera.offset).set_trans(self.TRANSITION).set_ease(self.EASE)
#	self.shake_tween.play()

func _reset() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self.parent_camera, "offset", Vector2.ZERO, $FrequencyTimer.wait_time).from(self.parent_camera.offset).set_trans(self.TRANSITION).set_ease(self.EASE)
#	self.shake_tween.play()
	self.priority = 0

func _on_frequency_timer_timeout() -> void:
	self._new_shake()

func _on_duration_timer_timeout() -> void:
	self._reset()
	$FrequencyTimer.stop()


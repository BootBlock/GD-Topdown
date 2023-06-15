# CombatText.gd
extends Node2D

# TODO: A major optimisation would be to pre-create a couple of Labels and reuse them.

const combat_text_start_offset = Vector2(-5, -33)

var tween: Tween

@onready var label: Label = $Label

func _process(delta: float) -> void:
	self.global_rotation = 0			# Stop the label from rotating

## Display floating combat text.
##
## value: The contents of the text to display. This automatically has str() applied - no need to do it manually.
## direction: A Vector2 representing the direction of travel.
## duration: How long to display the combat text.
## spread: The movement will be randomly spread across this arc.
## critical: Determines whether the event is to be considered a critical.
## color: The colour to apply to the combat text label.
func show_value(value, direction: Vector2, duration: float, spread, critical: bool = false, color: Color = Color(1, 1, 1)):
	self.modulate = color
	self.label.text = value
	self.label.pivot_offset = self.label.size / 2
	var movement = direction.rotated(randf_range(-spread / 2, spread / 2))

	self.tween = get_tree().create_tween()
	self.tween.parallel().tween_property(self.label, "position", self.position + movement, duration).from(self.position + self.combat_text_start_offset).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	self.tween.parallel().tween_property(self.label, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	if critical:
		var original_scale = self.scale

		self.tween.parallel().tween_property(self.label, "scale", Vector2(1, 1), 0.5).from(Vector2(3, 3)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		self.tween.tween_property(self.label, "scale", Vector2(1, 1), 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	self.tween.tween_callback(self.queue_free)
	self.tween.play()

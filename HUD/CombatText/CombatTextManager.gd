# CombatTextManager.gd
extends Node2D

var combat_text = preload("res://HUD/CombatText/CombatText.tscn")

@export var travel: Vector2 = Vector2(0, -80)
@export var spread: float   = PI / 2

func show_value(value, critical: bool = false, duration: float = 1.5):
	if !Config.CombatText:
		return

	var color: Color

	if value is int or value is float:
		if value > 0:
			if critical:
				color =  Color(1, 1, 1) if not critical else Color(1, 0.1, 0.1)		# Damage
		elif value < 0:
			color = Color(0.2, 0.75, 0.2) if not critical else Color(0, 1, 0)	# Heal

			# Make positive as a heal that shows a negative number looks weird
			value = abs(value)
	elif value is String:
		color = Color(1, 1, 1)

	var ct = self.combat_text.instantiate()
	self.add_child(ct)
	ct.show_value(str(value), travel, duration, spread, critical, color)

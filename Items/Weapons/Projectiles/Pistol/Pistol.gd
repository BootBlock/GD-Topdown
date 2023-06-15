# Pistol.gd
class_name Pistol extends Gun

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self._process_input(delta)

func _process_input(delta: float) -> void:
	if Input.is_action_just_pressed("primary_attack"):
		self.fire_primary()
	elif Input.is_action_just_pressed("reload"):
		self.reload()

# FlickeringLight.gd
extends PointLight2D

@export var noise: NoiseTexture2D

var time_passed: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.time_passed += delta

	var sampled_noise = abs(self.noise.noise.get_noise_1d(self.time_passed))
	self.energy = 0.5 + sampled_noise

	# Wrap the value so it doesn't become so large that it loses precision.
	if self.time_passed > 1000000:
		self.time_passed = 0

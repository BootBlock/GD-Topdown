# FlickeringLight.gd
extends PointLight2D

## The value at which time_passed should wrap back to zero so the number doesn't become so large that it loses precision.
const TIME_PASSED_MAXIMUM_VALUE: int = 1000000

## The noise that dictates the flickering effect of the light.
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
	if self.time_passed > self.TIME_PASSED_MAXIMUM_VALUE:
		self.time_passed = 0

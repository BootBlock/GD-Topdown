# ExplosiveBarrel.gd
## An environmental object that creates an explosion when destroyed.
class_name ExplosiveBarrel extends EnvironmentItem

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var got_hit_particles: GPUParticles2D = $GotHitGPUParticles2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# The barrel has been hit.
func _on_got_hit(_damage) -> void:
	self.animation_player.play("hit")

# The barrel has received the signal to be destroyed.
func _on_destroying() -> void:
	self.collision_shape.set_deferred("disabled", true)		# TODO: Keep enabled, but don't trigger on gun shots or summat
	self.animation_player.play("explode")

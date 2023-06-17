# Main.gd
extends Node2D

# Signals
## A new player has joined the game.
signal new_player(player: Player)

#@onready var world_environment = $WorldEnvironment
@onready var stage001_scene = preload("res://Stages/Stage001/Stage001.tscn")
@onready var player_scene = preload("res://Players/Player.tscn")

var current_stage: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.current_stage = self.stage001_scene.instantiate()
	self.add_child(self.current_stage)

	var player = self.player_scene.instantiate()
	var spawner = self._get_next_spawn_position()

	if spawner:
		player.position = spawner.position
		player.rotation = spawner.rotation

		GameState.players.append(player)
		self.add_child(player)
		self.new_player.emit(player)

	# Graphics
	self._update_bloom()

	Config.bloom_level_changed.connect(self._on_config_bloom_level_changed)				# Have to call an intermediary function, for some reason.

	# Display
	# Fullscreen logic is contained within Configuration as Alt+Enter can also invoke it.
	# VSync logic is contained within Configuration.

func _process(_delta: float) -> void:
	if Input.is_action_just_released("fullscreen_toggle"):
		if !Config.FullscreenMode == Config.fullscreen_mode.Windowed:
			Config.FullscreenMode = Config.fullscreen_mode.Windowed
		else:
			Config.FullscreenMode = Config.fullscreen_mode.Fullscreen

## Returns the very first available player spawn location within the current stage, if found; otherwise, returns null.
func _get_next_spawn_position(_remove_spawn_node: bool = true) -> Node2D:
	var potential_spawners = self.current_stage.get_node("PlayerSpawners")
	var spawners = potential_spawners.get_children()

	assert(spawners != null, "The stage doesn't seem to have a Node2D that contains PlayerSpawners nodes; they're required for specifying where players can spawn into the stage.")

	spawners.sort_custom(func(a, b): return a.used_count < b.used_count)

	var spawner = spawners.front()
	spawner.used_count += 1

	return spawner

################################################################################ Events
func _on_config_bloom_level_changed(_value: Config.quantity) -> void:
	self._update_bloom()

################################################################################ Methods
func _update_bloom() -> void:
	return
#	var bloom_strength = 1.0	# These equate to Medium, so no need for a case match below.
#	var bloom_bloom = 0.4
#
#	match Config.BloomLevel:
#		Config.quantity.Low:
#			bloom_bloom = 0.15
#
#		Config.quantity.High:
#			bloom_bloom = 0.8
#
#		Config.quantity.Ultra:
#			bloom_bloom = 1.2
#
#		Config.quantity.Stewpid:
#			bloom_bloom = 1
#			bloom_strength = 1.5
#
#	self.world_environment.set_indexed("environment:glow_bloom", bloom_bloom)
#	self.world_environment.set_indexed("environment:glow_strength", bloom_strength)
#	self.world_environment.set_indexed("environment:glow_enabled", Config.BloomLevel != Config.quantity.None)

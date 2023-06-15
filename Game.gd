# Game.gd
##
## Contains the global state of the game. This is a singleton.
##
class_name Game extends Node2D

## Allows the loading and saving of game state. Not really required so early in development, hence the false value.
const ALLOW_SAVING = false

const GAME_STATE_FILENAME = "user://game.tres"

## The main scene into the entire game screen.
@onready var main_scene = get_tree().get_root().get_node("Main")
@onready var camera = self.main_scene.get_node("Camera2D")
@onready var camera_shake = self.camera.get_node("ScreenShake")

## All of the players in the current game.
var players: Array[Player] = []

var game_state = game_data.new()
var Rnd = RandomNumberGenerator.new()

## Determines whether debug information is shown.
@export var DebugMode: bool = true

signal paused_changed(is_paused: bool)
## Gets whether the game is paused. Setting the property doesn't actually pause the get; this is mainly for getting the state, instead.
@export var paused: bool = false:
	get:
		return paused
	set(value):
		paused = value
		self.paused_changed.emit(paused)

#@onready var player: Player = get_tree().get_first_node_in_group("player") as Player

func _ready() -> void:
	randomize()
	self.Rnd.randomize()
	self._populate_pools()

	if self.ALLOW_SAVING:
		self._load_state()

func _exit_tree() -> void:
	if self.ALLOW_SAVING:
		self._save_state()

func _load_state() -> void:
	if !ResourceLoader.exists(self.GAME_STATE_FILENAME):
		return

	var state = ResourceLoader.load(self.GAME_STATE_FILENAME)

	# Check that the data is valid before applying it.
	if state is game_data:
		self.game_state = state

func _save_state() -> void:
	ResourceSaver.save(self.game_state, self.GAME_STATE_FILENAME)

func _populate_pools() -> void:
	self._populate_pool_offensive()
	self._populate_pool_modifiers()
	self._populate_pool_defensive()

func _populate_pool_offensive() -> void:
#	self.offensive_pool.append(preload("res://GameplayObjects/Items/Offensive/SmartTorpedo/SmartTorpedoAbilityItem.tscn").instantiate())
#	self.offensive_pool.append(preload("res://GameplayObjects/Items/Offensive/SmasherDrone/SmasherDroneAbilityItem.tscn").instantiate())
#	self.offensive_pool.append(preload("res://GameplayObjects/Items/Offensive/PrismLaser/PrismLaserAbilityItem.tscn").instantiate())
	pass

func _populate_pool_modifiers() -> void:
#	self.modifiers_pool.append(preload("res://GameplayObjects/Items/Modifiers/DoubleDamage/DoubleDamageModifierAbilityItem.tscn").instantiate())
#	self.modifiers_pool.append(preload("res://GameplayObjects/Items/Modifiers/Size/SizeModifierAbilityItem.tscn").instantiate())
	pass

func _populate_pool_defensive() -> void:
	pass

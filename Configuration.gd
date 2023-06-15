# Configuration.gd
## Contains game configuration.
class_name Configuration extends Node

const VERSION:     int = 1
const FILENAME: String = "user://config.ini"

var file = ConfigFile.new()

# Display
signal fullscreen_mode_changed(new_value: fullscreen_mode)
enum fullscreen_mode { Windowed = 0, Fullscreen = 3, Fullscreen_Exclusive = 4 }
var FullscreenMode: fullscreen_mode = fullscreen_mode.Windowed:
	get:
		return FullscreenMode
	set(value):
		FullscreenMode = value

		match self.FullscreenMode:
			fullscreen_mode.Windowed:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				self.fullscreen_mode_changed.emit(self.FullscreenMode)
			fullscreen_mode.Fullscreen:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				self.fullscreen_mode_changed.emit(self.FullscreenMode)
			fullscreen_mode.Fullscreen_Exclusive:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
				self.fullscreen_mode_changed.emit(self.FullscreenMode)
			_:
				print("Unknown FullscreenMode specified: " + str(self.FullscreenMode))

		print("FullscreenMode set to: " + str(Config.FullscreenMode))

signal vsync_mode_changed(new_value: vsync_mode)
enum vsync_mode { Disabled = 0, Enabled = 1, Adaptive = 2, Mailbox = 3 }
var VSyncMode: vsync_mode = vsync_mode.Enabled:
	get:
		return VSyncMode
	set(value):
		VSyncMode = value

		match self.VSyncMode:
			vsync_mode.Disabled:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
				self.vsync_mode_changed.emit(self.VSyncMode)
			vsync_mode.Enabled:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
				self.vsync_mode_changed.emit(self.VSyncMode)
			vsync_mode.Adaptive:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
				self.vsync_mode_changed.emit(self.VSyncMode)
			vsync_mode.Mailbox:
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
				self.vsync_mode_changed.emit(self.VSyncMode)
			_:
				print("Unknown VSyncMode specified: " + str(self.VSyncMode))

		print("VSyncMode set to: " + str(Config.VSyncMode))

# Graphics
signal particle_level_changed(new_value: quantity)
var ParticleLevel: quantity = quantity.Medium:
	get:
		return ParticleLevel
	set(value):
		ParticleLevel = value
		self.particle_level_changed.emit(self.ParticleLevel)

signal bloom_level_changed(new_value: quantity)
var BloomLevel: quantity = quantity.High:
	get:
		return BloomLevel
	set(value):
		BloomLevel = value
		self.bloom_level_changed.emit(self.BloomLevel)

signal combat_text_changed(new_value: bool)
## Whether healing, damage, and informational text should be shown above entities.
var CombatText: bool = true:
	get:
		return CombatText
	set(value):
		CombatText = value
		self.combat_text_changed.emit(self.CombatText)

# Input
## Vibration intensity modifier.
var VibrationIntensity: float = 1.0

# Misc
var Quality_Poor: Color = Color(0.62, 0.62, 0.62)
var Quality_Common: Color = Color(1, 1, 1)
var Quality_Uncommon: Color = Color(0.12, 1, 1)
var Quality_Rare: Color = Color(0, 0.44, 0.87)
var Quality_Epic: Color = Color(0.64, 0.21, 0.93)
var Quality_Legendary: Color = Color(1, 0.5, 0)
var Quality_Artefact: Color = Color(0.9, 0.8, 0.5)
var Quality_Heirloom: Color = Color(0, 0.8, 1)

var Seed: int = 0

func _ready() -> void:
	self._load()

func _exit_tree() -> void:
	self._save()				# TODO: Only call this when the user explicitly wants to save

# Methods
func _load() -> void:
	if FileAccess.file_exists(self.FILENAME) and file.load(self.FILENAME) != OK:
		print("Error loading configuration file. Exists: " + str(FileAccess.file_exists(self.FILENAME)) + ", File: " + self.FILENAME)

	var config_version = file.get_value("Configuration", "Version", self.VERSION)

	# Gameplay
	self.CombatText = file.get_value("Gameplay", "CombatText", self.CombatText) as bool

	# Graphics
	self.ParticleLevel = file.get_value("Graphics", "ParticleLevel", self.ParticleLevel)
	self.BloomLevel = file.get_value("Graphics", "BloomLevel", self.BloomLevel)

	# Display
	self.FullscreenMode = file.get_value("Display", "FullscreenMode", self.FullscreenMode)

	# Input
	self.VibrationIntensity = file.get_value("Input", "VibrationIntensity", self.VibrationIntensity)

	self._dump_config_data(config_version)

func _save() -> void:
	file.set_value("Configuration", "Version", self.VERSION)

	# Gameplay
	file.set_value("Gameplay", "CombatText", self.CombatText)

	# Graphics
	file.set_value("Graphics", "ParticleLevel", self.ParticleLevel)
	file.set_value("Graphics", "BloomLevel", self.BloomLevel)

	# Display
	file.set_value("Display", "FullscreenMode", self.FullscreenMode)

	# Input
	file.set_value("Input", "VibrationIntensity", self.VibrationIntensity)

	print("Config values set; saving file...")
	file.save(self.FILENAME)

func _dump_config_data(config_version: int) -> void:
	print("                  File: " + self.FILENAME)
	print(" Configuration version: v" + str(config_version))
	print("")

	# Gameplay
	print("GAMEPLAY")
	print("            CombatText: " + str(self.CombatText))
	print("")

	# Graphics
	print("GRAPHICS")
	print("         ParticleLevel: " + str(self.ParticleLevel))
	print("            BloomLevel: " + str(self.BloomLevel))
	print("")

	# Display
	print("DISPLAY")
	print("        FullscreenMode: " + str(self.FullscreenMode))
	print("")

	# Input
	print("INPUT")
	print("    VibrationIntensity: " + str(self.VibrationIntensity))
	print("======================")
	print("")

enum quantity {
	None,
	Low,
	Medium,
	High,
	Ultra,
	Stewpid,
}

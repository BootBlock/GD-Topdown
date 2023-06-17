extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GameState.players[0].connect(self._on_player_name_changed)
	$Label.text = GameState.players[0].info.name
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.global_rotation = 0


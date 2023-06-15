#
# Unlike keyboard input, controller inputs can be seen by all windows on the operating system, including unfocused windows.
#
# While this is useful for third-party split screen functionality, it can also have adverse effects.
# Players may accidentally send controller inputs to the running project while interacting with another window.
#
# If you wish to ignore events when the project window isn't focused, you will need to create an autoload called Focus.
#
# Then, instead of using Input.is_action_pressed(action), use Focus.input_is_action_pressed(action) where action is the
# name of the input action. Also, instead of using event.is_action_pressed(action), use Focus.event_is_action_pressed(event, action)
# where event is an InputEvent reference action is the name of the input action.
#
#	See https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html#window-focus
#

# Messages.gd (globally instanced as 'System')
extends Node

var focused: bool = true
var old_size = 0

signal viewport_resized(old_size, new_size)

func _ready():
	self.old_size = get_viewport().size
	get_tree().get_root().size_changed.connect(self.size_changed)

func size_changed():
	self.viewport_resized.emit(self.old_size, get_viewport().size)
	self.old_size = get_viewport().size

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focused = true

func input_is_action_pressed(action: StringName) -> bool:
	if focused:
		return Input.is_action_pressed(action)

	return false

func event_is_action_pressed(event: InputEvent, action: StringName) -> bool:
	if focused:
		return Input.is_action_pressed(action)

	return false

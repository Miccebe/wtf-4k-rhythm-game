extends MarginContainer

@export var keybind: Key = KEY_D
@export var settings_name: String = ""
var is_setting_keybind: bool = false


func _process(_delta: float) -> void:
	if self.is_setting_keybind and not $Container/Button.button_pressed:
		$Container/Button.set_pressed_no_signal(true)


func _on_button_down() -> void:
	self.is_setting_keybind = true
	var track_keybind_node: Array[MarginContainer] = [
		$"../Track1Keybind",
		$"../Track2Keybind",
		$"../Track3Keybind",
		$"../Track4Keybind",
	]
	for i in track_keybind_node:
		if self == i:
			continue
		i.stop_set_keybind()


func _input(event: InputEvent) -> void:
	if self.is_setting_keybind:
		if event is InputEventKey and event.pressed:
			self.set_keybind(event.keycode)


func stop_set_keybind() -> void:
	self.is_setting_keybind = false
	$Container/Button.set_pressed_no_signal(false)


func set_keybind(_keycode: Key) -> void:
	self.keybind = _keycode
	$Container/Button.text = OS.get_keycode_string(_keycode)
	$Container/Button.set_pressed_no_signal(false)
	self.is_setting_keybind = false
	print("keybind = %s" % self.keybind)

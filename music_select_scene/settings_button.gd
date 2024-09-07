extends Button


func _process(_delta: float) -> void:
	if $"../SettingsScene".visible and not self.button_pressed:
		self.set_pressed_no_signal(true)

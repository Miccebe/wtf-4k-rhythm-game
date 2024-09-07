extends Button


func _process(_delta: float) -> void:
	if $"../SettingsScene".visible and not self.button_pressed:
		self.set_pressed_no_signal(true)


func _on_button_down() -> void:
	$"../PauseButton".emit_signal("paused")


func _on_button_up() -> void:
	$"../PauseButton".emit_signal("continued")

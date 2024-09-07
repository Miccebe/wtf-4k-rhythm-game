extends Label


func _ready() -> void:
	self.visible = false


func _on_pause_button_toggled(toggled_on: bool) -> void:
	self.visible = toggled_on

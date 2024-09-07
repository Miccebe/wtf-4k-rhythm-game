extends Button

signal retry


func _pressed() -> void:
	emit_signal("retry")

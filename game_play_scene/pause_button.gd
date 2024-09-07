extends Button

signal paused
signal continued


func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		self.text = 'Continue'
		emit_signal("paused")
	else:
		self.text = 'Pause'
		emit_signal("continued")

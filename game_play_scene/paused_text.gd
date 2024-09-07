extends Label


func _ready() -> void:
	self.visible = false


func _on_paused() -> void:
	self.visible = true


func _on_continued() -> void:
	self.visible = false

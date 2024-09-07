extends AudioStreamPlayer


func _on_music_volume_changed(changed_config: Settings) -> void:
	self._on_music_volume_changed_directly(changed_config.music_volume, "music_volume")


func _on_music_volume_changed_directly(_value: int, _settings_name: String) -> void:
	if _settings_name == "music_volume":
		self.volume_db = lerp(-50, 0, _value / 100.0) if _value != 0 else -80
		print("_on_music_volume_changed_directly: self.volume_db = ", self.volume_db)


func _on_paused() -> void:
	self.stream_paused = true


func _on_continued() -> void:
	self.stream_paused = false

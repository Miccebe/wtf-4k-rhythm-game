extends AudioStreamPlayer

var play_wait_time: float
var is_waiting: bool = false
var current_wait_time: float

var is_paused: bool = false


func _physics_process(delta: float) -> void:
	if self.is_paused:
		return
	if self.is_waiting and not self.playing:
		self.current_wait_time += delta
		if self.current_wait_time >= self.play_wait_time:
			self.is_waiting = false
			self.current_wait_time = 0
			self.play()


func start_playing(_offset: float) -> void:
	## 这个_offset计入note下落时间
	self.play_wait_time = _offset
	self.is_waiting = true


func _on_music_volume_changed(changed_config: Settings) -> void:
	self._on_music_volume_changed_directly(changed_config.music_volume, "music_volume")


func _on_music_volume_changed_directly(_value: int, _settings_name: String) -> void:
	if _settings_name == "music_volume":
		var changed_volume: float = lerp(-50, 0, _value / 100.0) if _value != 0 else -80
		self.volume_db = changed_volume
		print("_on_music_volume_changed_directly: self.volume_db = ", self.volume_db)


func _on_paused() -> void:
	self.is_paused = true
	self.stream_paused = true


func _on_continued() -> void:
	self.is_paused = false
	self.stream_paused = false

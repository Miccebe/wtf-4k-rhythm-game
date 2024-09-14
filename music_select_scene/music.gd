extends AudioStreamPlayer

const FADE_OUT_DURATION_MILLISEC: float = 3000.0
const FADE_OUT_STRENGTH: float = 2
const PREVIEW_RESTART_COOLDOWN_SEC: float = 1.0
const DEFAULT_PREVIEW_START_TIME_SEC: float = 0.0
const DEFAULT_PREVIEW_END_TIME_SEC: float = 20.0
const FADE_OUT_END_VOLUME: float = -60.0

var preview_start_time_sec: float = self.DEFAULT_PREVIEW_START_TIME_SEC
var preview_end_time_sec: float = self.DEFAULT_PREVIEW_END_TIME_SEC

var fade_out_time_millisec: float = self.FADE_OUT_DURATION_MILLISEC
var fade_out_start_volume: float = self.volume_db
var is_fading_out: bool = false
var time_after_fading_out: float = self.PREVIEW_RESTART_COOLDOWN_SEC


func _physics_process(delta: float) -> void:
	if (
		(self.preview_end_time_sec - self.get_playback_position()) * 1000 <= self.FADE_OUT_DURATION_MILLISEC 
		and not self.is_fading_out
	):		# 开始淡化
		self.fade_out_start()
	if self.is_fading_out:		# 正在淡化
		self.volume_db = self.fade_out_volume_interpolation(self.fade_out_time_millisec)
		self.fade_out_time_millisec -= delta * 1000
		# 如果淡出已完成
		if self.fade_out_time_millisec <= 0:
			print("Music fade out ended.")
			self.stop()
			self.is_fading_out = false
			self.time_after_fading_out = 0
			self.volume_db = -80.0
	if (
		not self.is_fading_out 
		and self.time_after_fading_out < self.PREVIEW_RESTART_COOLDOWN_SEC 
		and not self.playing
	):		# 淡化结束且正在重播冷却
		self.time_after_fading_out += delta
		if self.time_after_fading_out >= self.PREVIEW_RESTART_COOLDOWN_SEC:	  # 重播的冷却结束
			print("Music replay started.")
			self.play(self.preview_start_time_sec)
			self.volume_db = self.fade_out_start_volume
			

func _on_music_volume_changed(changed_config: Settings) -> void:
	self._on_music_volume_changed_directly(changed_config.music_volume, "music_volume")


func _on_music_volume_changed_directly(_value: int, _settings_name: String) -> void:
	if _settings_name == "music_volume":
		var changed_volume: float = lerp(-50, 0, _value / 100.0) if _value != 0 else -80
		if self.is_fading_out:
			self.fade_out_start_volume = changed_volume
			print("_on_music_volume_changed_directly: self.fade_out_start_volume = ", self.fade_out_start_volume)
		else:
			self.volume_db = changed_volume
			self.fade_out_start_volume = changed_volume
			print("_on_music_volume_changed_directly: self.volume_db = ", self.volume_db)


func fade_out_start() -> void:
	print("fade_out_start() runned.")
	self.is_fading_out = true
	self.fade_out_start_volume = self.volume_db
	self.fade_out_time_millisec = self.FADE_OUT_DURATION_MILLISEC


func fade_out_volume_interpolation(_time_millisec: float) -> float:
	## 音量衰减公式：
	## D(t)=(f(u)-f(Fs))*(Ds-De)/(f(Fe)-f(Fs))+De, 其中f(t)=s**t, u=t*(Fe-Fs)/Tk+Fs
	## D(t)=(f(u)-f(F_s))\cdot\frac{D_s-D_e}{f(F_e)-f(F_s)}+D_e, f(t)=s^t, u=t\cdot\frac{F_e-F_s}{T_k}+F_s
	## 参数解释：t是时间；Ds和De分别是衰减始末的音量；Fs和Fe是衰减函数选用的区间，默认值为[-1, 1]
	## s是衰减强度，对应衰减函数的底数，默认值为10；Tk是衰减的持续时间
	## 合并成一个表达式后的公式：
	## D(t)=(s**(t*(Fe-Fs)/Tk+Fs)-s**Fs)*(Ds-De)/(s**Fe-s**Fs)+De
	## D(t)=(s^{t\cdot\frac{F_e-F_s}{T_k}+F_s}-s^{F_s})\cdot\frac{D_s-D_e}{s^{F_e}-s^{F_s}}+D_e
	const FUNCTION_RANGE_START: float = -1.0
	const FUNCTION_RANGE_END: float = 1.0
	return (
		(
			self.FADE_OUT_STRENGTH ** (
			_time_millisec * (FUNCTION_RANGE_END - FUNCTION_RANGE_START) / self.FADE_OUT_DURATION_MILLISEC
			+ FUNCTION_RANGE_START
			)
			- self.FADE_OUT_STRENGTH ** FUNCTION_RANGE_START
		) 
		* (self.fade_out_start_volume - self.FADE_OUT_END_VOLUME)
		/ (self.FADE_OUT_STRENGTH ** FUNCTION_RANGE_END - self.FADE_OUT_STRENGTH ** FUNCTION_RANGE_START)
		+ self.FADE_OUT_END_VOLUME
	)


func set_preview_clip(preview_clip: String) -> Error:
	## 输入格式是<StartTime>-<EndTime>，例如0:19:000-0:40:000
	## 时间格式为[[[hour:]m]m:]ss[.millisec]或sec[.millisec]，其中millisec至多三位数，sec和hour为任意位数，m和s均为单字符
	var time_string_to_sec = func(_time_string: String) -> float:
		var time_list: PackedStringArray = _time_string.split(':')
		if len(time_list) == 1:
			time_list = ["0", "0"] + (Array(time_list[0].split('.')) if time_list[0].find('.') != -1 else [time_list[0], "000"])
		elif len(time_list) == 2:
			time_list = ["0", time_list[0]] + (Array(time_list[1].split('.')) if time_list[1].find('.') != -1 else [time_list[1], "000"])
		else:
			time_list = [time_list[0], time_list[1]] + (Array(time_list[2].split('.')) if time_list[2].find('.') != -1 else [time_list[2], "000"])
		time_list[3] = time_list[3] + "000".left(3 - len(time_list[3]))
		return float(time_list[0]) * 3600 + float(time_list[1]) * 60 + float(time_list[2]) + float("0." + time_list[3])
	
	var check_input_match: RegEx = RegEx.new()
	check_input_match.compile(r"(((\d+:[0-5])?[0-9]:)?[0-5][0-9]|\d+)(.[0-9]{1,3})?-(((\d+:[0-5])?[0-9]:)?[0-5][0-9]|\d+)(.[0-9]{1,3})?")
	if check_input_match.search(preview_clip).get_string() != preview_clip:
		self.preview_start_time_sec = self.DEFAULT_PREVIEW_START_TIME_SEC
		self.preview_end_time_sec = self.DEFAULT_PREVIEW_END_TIME_SEC
		return ERR_INVALID_PARAMETER
	var start_time_string: String = preview_clip.split('-')[0]
	var end_time_string: String = preview_clip.split('-')[1]
	self.preview_start_time_sec = time_string_to_sec.call(start_time_string)
	self.preview_end_time_sec = time_string_to_sec.call(end_time_string)
	print("set_preview_clip(): self.preview_start_time_sec = %s, self.preview_end_time_sec = %s" 
		% [self.preview_start_time_sec, self.preview_end_time_sec])
	return OK

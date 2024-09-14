extends HBoxContainer

const START_FAST_ADJUSTMENT_TIME: float = 0.5

@export var default_value: float = 0.0
@export var value_max: float = 1000.0
@export var value_min: float = -1000.0
@export var greater_text: String = ""
@export var lesser_text: String = ""
@export var percentage: bool = false
@export var integer: bool = true
@export var changed_actual_time: bool = false
@export var settings_name: String = ""
var correct_text_regex: RegEx

var minus_button_press_time: float = 0.0
var plus_button_press_time: float = 0.0

signal settings_changed(_value: float, _settings_name: String)


func _ready() -> void:
	$Slider.allow_greater = true if self.greater_text else false
	$Slider.allow_lesser = true if self.lesser_text else false
	if self.percentage:
		self.correct_text_regex = RegEx.create_from_string(r"^\-?\d+\.?(\d+)?%?$")
	else:
		self.correct_text_regex = RegEx.create_from_string(r"^\-?\d+\.?(\d+)?$")
	$Slider.set_value_no_signal(self.correct_value(self.default_value))
	$ValueText.text = self.correct_text(self.default_value)
	self.settings_changed.connect($"../../.."._on_received_change_actual_time)


func _process(delta: float) -> void:
	if $Minus.button_pressed:
		self.minus_button_press_time += delta
		if self.minus_button_press_time >= self.START_FAST_ADJUSTMENT_TIME:
			self._on_minus_button_down()
	if $Plus.button_pressed:
		self.plus_button_press_time += delta
		if self.plus_button_press_time >= self.START_FAST_ADJUSTMENT_TIME:
			self._on_plus_button_down()


func _on_slider_changed(value: float) -> void:
	$ValueText.text = self.correct_text(value)
	if self.changed_actual_time:
		emit_signal("settings_changed", value, self.settings_name)
	LogScript.write_log(["Successfully set settings ", self.settings_name, " to ", self.correct_text(value)])


func _on_text_changed(new_text: String) -> void:
	var original_value: float = $Slider.value
	var match_result: RegExMatch = self.correct_text_regex.search(new_text)
	if match_result and match_result.get_string() == new_text:
		$Slider.set_value_no_signal(self.correct_value(float(new_text)))
		$ValueText.text = self.correct_text(float(new_text))
		LogScript.write_log(["Successfully set settings ", self.settings_name, " to ", self.correct_value(float(new_text))])
	else:
		$ValueText.text = self.correct_text(original_value)
		LogScript.write_log(["Set settings ", self.settings_name, " failed. Has reset to ", self.correct_text(original_value)])
	if self.changed_actual_time:
		emit_signal("settings_changed", $Slider.value)
	

func _on_plus_button_down() -> void:
	$Slider.value = self.correct_value($Slider.value + $Slider.step)


func _on_plus_button_up() -> void:
	self.plus_button_press_time = 0.0


func _on_minus_button_down() -> void:
	$Slider.value = self.correct_value($Slider.value - $Slider.step)


func _on_minus_button_up() -> void:
	self.minus_button_press_time = 0.0


func correct_value(_value):
	var corrected_value
	if not self.greater_text and _value > self.value_max:
		corrected_value = self.optional_integerfy_value(self.value_max)
	elif not self.lesser_text and _value < self.value_min:
		corrected_value = self.optional_integerfy_value(self.value_min)
	else:
		corrected_value = self.optional_integerfy_value(_value)
	return corrected_value
	
	
func correct_text(_value) -> String:
	var optional_percentage_char = func () -> String:
		if self.percentage:
			return '%'
		else:
			return ""
	
	var corrected_text: String
	if _value > self.value_max:
		if self.greater_text.is_empty():
			corrected_text = str(self.optional_integerfy_value(self.value_max)) + optional_percentage_char.call()
		elif self.greater_text == "$self$":
			corrected_text = str(self.optional_integerfy_value(_value)) + optional_percentage_char.call()
		else:
			corrected_text = self.greater_text
	elif _value < self.value_min:
		if self.lesser_text.is_empty():
			corrected_text = str(self.optional_integerfy_value(self.value_min)) + optional_percentage_char.call()
		elif self.lesser_text == "$self$":
			corrected_text = str(self.optional_integerfy_value(_value)) + optional_percentage_char.call()
		else:
			corrected_text = self.lesser_text
	else:
		corrected_text = str(self.optional_integerfy_value(_value)) + optional_percentage_char.call()
	return corrected_text
	


func optional_integerfy_value(_value):
		if self.integer:
			return int(_value)
		else:
			return _value

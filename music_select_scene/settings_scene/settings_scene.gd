extends Node2D
class_name SettingsScene

var settings_config: Settings = Settings.new()
var current_settings_page: SettingsPage = SettingsPage.GAME_SETTINGS

enum SettingsPage {
	GAME_SETTINGS = 0,
	VOLUME_SETTINGS = 1,
}

const SETTINGS_PAGE_MAX: int = 1

signal page_changed(_page: SettingsPage)
signal settings_changed(changed_config: Settings)
signal settings_changed_directly(_value: float, _settings_name: String)


func _ready() -> void:
	self.current_settings_page = SettingsPage.GAME_SETTINGS
	emit_signal("page_changed", current_settings_page)
	settings_config.load_config()
	$Control/GameSettings/MusicOffset/Slider.value = $Control/GameSettings/MusicOffset.correct_value(settings_config.music_offset)
	$Control/GameSettings/InputOffset/Slider.value = $Control/GameSettings/InputOffset.correct_value(settings_config.input_offset)
	$Control/GameSettings/ChartFlowSpeed/Slider.value = $Control/GameSettings/ChartFlowSpeed.correct_value(settings_config.chart_flow_speed)
	$Control/GameSettings/Track1Keybind.set_keybind(settings_config.track1_key)
	$Control/GameSettings/Track2Keybind.set_keybind(settings_config.track2_key)
	$Control/GameSettings/Track3Keybind.set_keybind(settings_config.track3_key)
	$Control/GameSettings/Track4Keybind.set_keybind(settings_config.track4_key)
	$Control/VolumeSettings/MusicVolume/Slider.value = $Control/VolumeSettings/MusicVolume.correct_value(settings_config.music_volume)
	$Control/VolumeSettings/SEVolume/Slider.value = $Control/VolumeSettings/SEVolume.correct_value(settings_config.se_volume)
	$Control/VolumeSettings/CorrectVolume/Slider.value = $Control/VolumeSettings/CorrectVolume.correct_value(settings_config.correct_volume)
	emit_signal("settings_changed", self.settings_config)


func save_settings() -> void:
	settings_config.music_offset = $Control/GameSettings/MusicOffset/Slider.value
	settings_config.input_offset = $Control/GameSettings/InputOffset/Slider.value
	settings_config.chart_flow_speed = $Control/GameSettings/ChartFlowSpeed/Slider.value
	settings_config.track1_key = $Control/GameSettings/Track1Keybind.keybind
	settings_config.track2_key = $Control/GameSettings/Track2Keybind.keybind
	settings_config.track3_key = $Control/GameSettings/Track3Keybind.keybind
	settings_config.track4_key = $Control/GameSettings/Track4Keybind.keybind
	settings_config.music_volume = $Control/VolumeSettings/MusicVolume/Slider.value
	settings_config.se_volume = $Control/VolumeSettings/SEVolume/Slider.value
	settings_config.correct_volume = $Control/VolumeSettings/CorrectVolume/Slider.value
	settings_config.save_config()
	emit_signal("settings_changed", settings_config)


func close_windows() -> void:
	self.visible = false


func _on_received_change_actual_time(_value: float, _settings_name: String) -> void:
	emit_signal("settings_changed_directly", _value, _settings_name)

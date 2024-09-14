extends Button

const ENABLED_BUTTON_COLOR: Color = Color("#42ff6e")
const DISABLED_BUTTON_COLOR: Color = Color("#656565")

var is_enabled: bool = false

signal enable
signal disable
signal chart_load_failed
signal changed_to_game_play_scene

func _ready() -> void:
	_on_disable()


func _pressed() -> void:
	var songs_list_node: ItemList = $"../SongsListContent"
	if songs_list_node.selected_chart < 0 or songs_list_node.selected_chart >= len(songs_list_node.songs_list.charts):
		return
	if PlayingChart.load_chart(songs_list_node.songs_list.charts[songs_list_node.selected_chart]):
		emit_signal("chart_load_failed")
		return
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://game_play_scene/game_play_scene.tscn")
	LogScript.write_log(['Scene switched to "game_play_scene" successfully.'])


func _on_enable() -> void:
	self.is_enabled = true
	$ButtonText.label_settings.font_color = self.ENABLED_BUTTON_COLOR


func _on_disable() -> void:
	self.is_enabled = false
	$ButtonText.label_settings.font_color = self.DISABLED_BUTTON_COLOR

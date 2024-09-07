extends Button


func _pressed() -> void:
	var scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://music_select_scene/music_select_scene.tscn")

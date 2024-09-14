extends Node


func _on_se_volume_changed(changed_config: Settings) -> void:
	$TrackSound.volume_db = lerp(-30, 15, changed_config.se_volume / 100.0) if changed_config.se_volume != 0 else -80
	print("_on_se_volume_changed: $TrackSound.volume_db = ", $TrackSound.volume_db)
	

func _on_correct_volume_changed(changed_config: Settings) -> void:
	var changed_value = lerp(-30, 15, changed_config.correct_volume / 100.0) if changed_config.correct_volume != 0 else -80
	$Tap.volume_db = changed_value
	$Catch.volume_db = changed_value
	$Hold.volume_db = changed_value
	$HoldEnd.volume_db = changed_value
	print("_on_correct_volume_changed: changed_value = ", changed_value)

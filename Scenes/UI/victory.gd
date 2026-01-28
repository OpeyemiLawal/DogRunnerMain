extends Control


func _on_reply_pressed() -> void:
	get_tree().reload_current_scene()
	$".".visible = false


func _on_next_mission_pressed() -> void:
	$ComingSoon.visible = true


func _on_close_cs_pressed() -> void:
	$ComingSoon.visible = false

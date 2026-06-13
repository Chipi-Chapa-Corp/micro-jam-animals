extends Control

const GAME_SCENE: String = "res://scenes/game/scene.tscn"
const CREDITS_SCENE: String = "res://scenes/credits/scene.tscn"


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(CREDITS_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()

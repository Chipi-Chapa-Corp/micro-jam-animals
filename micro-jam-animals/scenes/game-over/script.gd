extends Control

const GAME_SCENE: String = "res://scenes/game/scene.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"


func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

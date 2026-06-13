extends Control

const GAME_OVER_SCENE: String = "res://scenes/game-over/scene.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"


func _on_end_game_pressed() -> void:
	get_tree().change_scene_to_file(GAME_OVER_SCENE)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

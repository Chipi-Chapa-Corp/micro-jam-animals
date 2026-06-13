extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

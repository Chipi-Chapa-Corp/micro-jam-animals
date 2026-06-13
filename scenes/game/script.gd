extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)

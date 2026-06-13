extends Node2D

const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"

@onready var pause_menu: Control = $UI/PauseMenu


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_set_pause_menu_visible(not pause_menu.visible)


func _on_resume_pressed() -> void:
	_set_pause_menu_visible(false)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _set_pause_menu_visible(is_visible: bool) -> void:
	pause_menu.visible = is_visible

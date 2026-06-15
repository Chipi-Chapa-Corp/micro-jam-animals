extends Control

const GAME_SCENE: String = "res://scenes/game/scene.tscn"
const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"

@onready var final_score: Label = $CenterContainer/Menu/FinalScore


func _ready() -> void:
	AudioManager.set_menu_volume_ducked(false)
	AudioManager.play_menu_music()
	final_score.text = "Final Score %s" % GameState.get_score()


func _on_restart_pressed() -> void:
	_start_game()


func _start_game() -> void:
	GameState.reset()
	GameState.go_next_round()
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

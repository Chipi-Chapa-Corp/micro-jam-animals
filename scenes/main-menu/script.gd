extends Control

const GAME_SCENE: String = "res://scenes/game/scene.tscn"
const DECK_SCENE: String = "res://scenes/deck/scene.tscn"


func _ready() -> void:
	GameState.set_game_active(false)
	AudioManager.set_menu_volume_ducked(false)
	AudioManager.play_menu_music()


func _on_start_pressed() -> void:
	_start_game()


func _on_tutorial_pressed() -> void:
	GameState.reset()
	GameState.set_game_active(true)
	GameState.set_tutorial_active(true)
	get_tree().change_scene_to_file(GAME_SCENE)


func _start_game() -> void:
	GameState.set_game_active(true)
	GameState.set_tutorial_active(false)
	GameState.reset()
	GameState.go_next_round()
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_deck_pressed() -> void:
	get_tree().change_scene_to_file(DECK_SCENE)

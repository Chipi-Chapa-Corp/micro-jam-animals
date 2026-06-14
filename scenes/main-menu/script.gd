extends Control

const GAME_SCENE: String = "res://scenes/game/scene.tscn"
const DECK_SCENE: String = "res://scenes/deck/scene.tscn"
const CREDITS_SCENE: String = "res://scenes/credits/scene.tscn"


func _ready() -> void:
	AudioManager.set_menu_volume_ducked(false)
	AudioManager.play_menu_music()


func _on_start_pressed() -> void:
	_start_game()


func _start_game() -> void:
	GameState.reset()
	GameState.go_next_round()
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_deck_pressed() -> void:
	get_tree().change_scene_to_file(DECK_SCENE)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(CREDITS_SCENE)


func _on_quit_pressed() -> void:
	get_tree().quit()

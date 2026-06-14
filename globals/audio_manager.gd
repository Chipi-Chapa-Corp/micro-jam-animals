extends Node

var MENU_MUSIC: AudioStreamMP3 = preload("res://assets/sound/menu.mp3")
var GAME_MUSIC: AudioStreamMP3 = preload("res://assets/sound/game.mp3")
const CARD_TAKEN_SOUND: AudioStreamMP3 = preload("res://assets/sound/card-taken.mp3")
const CHANGE_TICK_SOUND: AudioStreamMP3 = preload("res://assets/sound/change-tick.mp3")
const PREDATORS_LOST_SOUND: AudioStreamMP3 = preload("res://assets/sound/predators-lost.mp3")
const PREDATORS_WON_SOUND: AudioStreamMP3 = preload("res://assets/sound/predators-won.mp3")
const MUSIC_VOLUME_MULTIPLIER: float = 0.4
const SOUND_VOLUME_MULTIPLIER: float = 1.8
const MENU_VOLUME_MULTIPLIER: float = 0.4

var _music_player: AudioStreamPlayer
var _music_volume_multiplier: float = 1.0


func _ready() -> void:
	MENU_MUSIC.loop = true
	GAME_MUSIC.loop = true
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	play_menu_music()


func play_menu_music() -> void:
	_play_music(MENU_MUSIC)


func play_game_music() -> void:
	_play_music(GAME_MUSIC)


func set_menu_volume_ducked(is_ducked: bool) -> void:
	_music_volume_multiplier = MENU_VOLUME_MULTIPLIER if is_ducked else 1.0
	_refresh_music_volume()


func play_card_taken() -> void:
	_play_sound(CARD_TAKEN_SOUND)


func play_change_tick() -> void:
	_play_sound(CHANGE_TICK_SOUND)


func play_predators_lost() -> void:
	_play_sound(PREDATORS_LOST_SOUND)


func play_predators_won() -> void:
	_play_sound(PREDATORS_WON_SOUND)


func _play_music(stream: AudioStreamMP3) -> void:
	if _music_player.stream == stream and _music_player.playing:
		return

	_music_player.stop()
	_music_player.stream = stream
	_refresh_music_volume()
	_music_player.play()


func _refresh_music_volume() -> void:
	if not _music_player:
		return

	_music_player.volume_db = linear_to_db(MUSIC_VOLUME_MULTIPLIER * _music_volume_multiplier)


func _play_sound(stream: AudioStreamMP3) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = linear_to_db(SOUND_VOLUME_MULTIPLIER)
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

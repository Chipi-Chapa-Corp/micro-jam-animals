extends Node2D

const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"
const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_MOVE_DURATION: float = 0.2
const CARD_MOVE_SCALE: Vector2 = Vector2(1.08, 1.08)
const CARD_MOVE_SCALE_DURATION: float = 0.08
const CARD_MOVE_LAYOUT_FRAMES: int = 3
const CARD_DRAW_MOVE_DURATION: float = 0.58
const CARD_DRAW_FLIP_DURATION: float = 0.24
const CARD_DRAW_STAGGER_DURATION: float = 0.08

@onready var pause_menu: Control = $UI/PauseMenu
@onready var card_animation_layer: Control = $UI/CardAnimationLayer
@onready var discard_pile: DiscardPile = $UI/PreyDeckContainer/DiscardPile
@onready var prey_deck: PreyDeck = $UI/PreyDeckContainer/PreyDeckCenter/PreyDeck
@onready var player_hand_deck: PlayerHandDeck = $UI/PlayerHandDeckContainer/PlayerHandDeck
@onready var prey_pile: PreyPile = $UI/PreyPile

var _is_discard_animating: bool = false


func _ready() -> void:
	player_hand_deck.card_move_animation_requested.connect(_on_player_hand_card_move_animation_requested)
	prey_deck.card_move_animation_requested.connect(_on_prey_card_move_animation_requested)
	discard_pile.hover_changed.connect(_on_discard_pile_hover_changed)
	discard_pile.clicked.connect(_on_discard_pile_clicked)
	GameState.player_cards_discarded.connect(_on_player_cards_discarded)


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


func _on_player_hand_card_move_animation_requested(
	card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float
) -> void:
	_animate_card_move(card, from_global_position, from_rotation_degrees, prey_deck)


func _on_prey_card_move_animation_requested(
	card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float
) -> void:
	_animate_card_move(card, from_global_position, from_rotation_degrees, player_hand_deck)


func _on_discard_pile_hover_changed(is_hovered: bool) -> void:
	if _is_discard_animating:
		return

	prey_deck.set_discard_hovered(is_hovered)


func _on_discard_pile_clicked() -> void:
	if _is_discard_animating:
		return

	_is_discard_animating = true
	await prey_deck.move_cards_to_discard(discard_pile.get_drop_global_position())
	_is_discard_animating = false


func _on_player_cards_discarded(
	_discarded_cards: Array, new_cards: Array, _player_discards_count: int
) -> void:
	if new_cards.is_empty():
		return

	prey_pile.begin_draw_animations()
	var from_global_position := prey_pile.get_draw_global_position()
	for index in range(new_cards.size()):
		var card = new_cards[index]
		if card is Dictionary:
			if index == new_cards.size() - 1:
				await _animate_card_draw_from_pile(card, from_global_position)
			else:
				_animate_card_draw_from_pile(card, from_global_position)

			if index < new_cards.size() - 1:
				await get_tree().create_timer(CARD_DRAW_STAGGER_DURATION).timeout

	prey_pile.end_draw_animations()


func _animate_card_move(
	card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float, target_deck: Node
) -> void:
	var card_id := str(card.get("id", ""))
	var target_card := _get_target_card(target_deck, card_id)
	var target_modulate := Color.WHITE
	var target_mouse_filter := Control.MOUSE_FILTER_STOP
	if target_card:
		target_modulate = target_card.modulate
		target_mouse_filter = target_card.mouse_filter
		target_card.modulate.a = 0.0
		target_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var moving_card := CARD_SCENE.instantiate() as CardScene
	moving_card.configure(
		CARD_KIND,
		str(card.get("suit", "")),
		int(card.get("value", 0)),
		float(card.get("scale", moving_card.art_scale)),
		float(card.get("rotation", moving_card.art_rotation_degrees))
	)
	moving_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_add_moving_card(moving_card, target_deck, target_card)
	moving_card.pivot_offset = moving_card.size * 0.5
	moving_card.global_position = from_global_position
	moving_card.rotation_degrees = from_rotation_degrees

	for _frame_index in range(CARD_MOVE_LAYOUT_FRAMES):
		await get_tree().process_frame

		if not is_inside_tree():
			moving_card.queue_free()
			return

		moving_card.global_position = from_global_position
		moving_card.rotation_degrees = from_rotation_degrees

	var to_global_position := from_global_position
	var to_rotation_degrees := 0.0
	if is_instance_valid(target_card):
		to_global_position = target_card.global_position
		to_rotation_degrees = target_card.rotation_degrees

	var scale_tween := create_tween()
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(moving_card, "scale", CARD_MOVE_SCALE, CARD_MOVE_SCALE_DURATION)
	scale_tween.tween_property(
		moving_card, "scale", Vector2.ONE, CARD_MOVE_DURATION - CARD_MOVE_SCALE_DURATION
	)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(moving_card, "global_position", to_global_position, CARD_MOVE_DURATION)
	tween.parallel().tween_property(moving_card, "rotation_degrees", to_rotation_degrees, CARD_MOVE_DURATION)
	await tween.finished

	moving_card.queue_free()
	if is_instance_valid(target_card):
		target_card.modulate = target_modulate
		target_card.mouse_filter = target_mouse_filter


func _animate_card_draw_from_pile(card: Dictionary, from_global_position: Vector2) -> void:
	var card_id := str(card.get("id", ""))
	var target_card := _get_target_card(player_hand_deck, card_id)
	var target_modulate := Color.WHITE
	var target_mouse_filter := Control.MOUSE_FILTER_STOP
	if target_card:
		target_modulate = target_card.modulate
		target_mouse_filter = target_card.mouse_filter
		target_card.modulate.a = 0.0
		target_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var moving_card := CARD_SCENE.instantiate() as CardScene
	moving_card.configure(
		CARD_KIND,
		str(card.get("suit", "")),
		int(card.get("value", 0)),
		float(card.get("scale", moving_card.art_scale)),
		float(card.get("rotation", moving_card.art_rotation_degrees))
	)
	moving_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if is_instance_valid(target_card):
		player_hand_deck.add_child(moving_card)
		moving_card.z_index = target_card.z_index
	else:
		card_animation_layer.add_child(moving_card)
		moving_card.z_index = 1000

	moving_card.prepare_draw_from_pile(moving_card.z_index)
	moving_card.pivot_offset = moving_card.size * 0.5
	moving_card.global_position = from_global_position
	moving_card.rotation_degrees = 0.0

	for _frame_index in range(CARD_MOVE_LAYOUT_FRAMES):
		await get_tree().process_frame

		if not is_inside_tree():
			moving_card.queue_free()
			return

		moving_card.global_position = from_global_position
		moving_card.rotation_degrees = 0.0

	var to_global_position := from_global_position
	var to_rotation_degrees := 0.0
	var to_z_index := moving_card.z_index
	if is_instance_valid(target_card):
		to_global_position = target_card.global_position
		to_rotation_degrees = target_card.rotation_degrees
		to_z_index = target_card.z_index

	var tween := moving_card.tween_draw_to(
		to_global_position, to_rotation_degrees, to_z_index, CARD_DRAW_MOVE_DURATION, CARD_DRAW_FLIP_DURATION
	)
	await tween.finished

	moving_card.queue_free()
	if is_instance_valid(target_card):
		target_card.modulate = target_modulate
		target_card.mouse_filter = target_mouse_filter


func _get_target_card(target_deck: Node, card_id: String) -> CardScene:
	if target_deck.has_method("get_card_by_id"):
		return target_deck.get_card_by_id(card_id) as CardScene

	return null


func _add_moving_card(moving_card: CardScene, target_deck: Node, target_card: CardScene) -> void:
	if target_deck == player_hand_deck and is_instance_valid(target_card):
		player_hand_deck.add_child(moving_card)
		moving_card.z_index = target_card.z_index
		return

	moving_card.z_index = 1000
	card_animation_layer.add_child(moving_card)

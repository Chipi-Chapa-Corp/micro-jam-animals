extends Node2D

const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"
const GAME_OVER_SCENE: String = "res://scenes/game-over/scene.tscn"
const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_MOVE_DURATION: float = 0.2
const CARD_MOVE_SCALE: Vector2 = Vector2(1.08, 1.08)
const CARD_MOVE_SCALE_DURATION: float = 0.08
const CARD_MOVE_LAYOUT_FRAMES: int = 3
const CARD_DRAW_MOVE_DURATION: float = 0.58
const CARD_DRAW_FLIP_DURATION: float = 0.24
const CARD_DRAW_STAGGER_DURATION: float = 0.08
const SCORE_REVEAL_INTERVAL: float = 0.48
const SCORE_PANEL_SLIDE_DURATION: float = 0.18
const SCORE_PANEL_WIDTH: float = 190.0
const SCORE_PANEL_BASE_HEIGHT: float = 46.0
const SCORE_PANEL_ROW_HEIGHT: float = 20.0
const SCORE_PANEL_MIN_HEIGHT: float = 72.0
const SUIT_ORDER: Array[String] = [Cards.SUIT_WATER, Cards.SUIT_LAND, Cards.SUIT_AIR]

@onready var pause_menu: Control = $UI/PauseMenu
@onready var play_button: Button = $UI/PlayButton
@onready var card_animation_layer: Control = $UI/CardAnimationLayer
@onready var discard_pile: DiscardPile = $UI/PreyDeckContainer/DiscardPile
@onready var prey_deck: PreyDeck = $UI/PreyDeckContainer/PreyDeckCenter/PreyDeck
@onready var player_hand_deck: PlayerHandDeck = $UI/PlayerHandDeckContainer/PlayerHandDeck
@onready var prey_pile: PreyPile = $UI/PreyPile
@onready var predator_score_panel: Panel = $UI/PredatorScorePanel
@onready var predator_hand_label: Label = $UI/PredatorScorePanel/Margin/Content/HandLabel
@onready var predator_suit_rows: VBoxContainer = $UI/PredatorScorePanel/Margin/Content/SuitRows
@onready var predator_water_row: Label = $UI/PredatorScorePanel/Margin/Content/SuitRows/Water
@onready var predator_land_row: Label = $UI/PredatorScorePanel/Margin/Content/SuitRows/Land
@onready var predator_air_row: Label = $UI/PredatorScorePanel/Margin/Content/SuitRows/Air
@onready var score_panel: Panel = $UI/PreyDeckContainer/ScorePanel
@onready var hand_label: Label = $UI/PreyDeckContainer/ScorePanel/Margin/Content/HandLabel
@onready var suit_rows: VBoxContainer = $UI/PreyDeckContainer/ScorePanel/Margin/Content/SuitRows
@onready var water_row: Label = $UI/PreyDeckContainer/ScorePanel/Margin/Content/SuitRows/Water
@onready var land_row: Label = $UI/PreyDeckContainer/ScorePanel/Margin/Content/SuitRows/Land
@onready var air_row: Label = $UI/PreyDeckContainer/ScorePanel/Margin/Content/SuitRows/Air
@onready var health_label: Label = $UI/HudPanel/Margin/Content/HealthLabel
@onready var score_label: Label = $UI/HudPanel/Margin/Content/ScoreLabel

var _is_discard_animating: bool = false
var _is_round_resolving: bool = false


func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	player_hand_deck.card_move_animation_requested.connect(_on_player_hand_card_move_animation_requested)
	prey_deck.card_move_animation_requested.connect(_on_prey_card_move_animation_requested)
	discard_pile.hover_changed.connect(_on_discard_pile_hover_changed)
	discard_pile.clicked.connect(_on_discard_pile_clicked)
	GameState.score_changed.connect(_on_score_changed)
	GameState.health_changed.connect(_on_health_changed)
	GameState.predators_changed.connect(_on_predators_changed)
	GameState.player_table_changed.connect(_on_player_table_changed)
	GameState.player_cards_discarded.connect(_on_player_cards_discarded)
	_refresh_hud()
	_refresh_score_preview()
	_refresh_play_button()


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


func _refresh_hud() -> void:
	health_label.text = "HP %s" % GameState.get_health()
	score_label.text = "Score %s" % GameState.get_score()


func _refresh_score_preview() -> void:
	var result := GameState.get_player_table_score_result()
	if GameState.get_player_table().is_empty():
		score_panel.visible = false
		_set_score_panel_row_count(score_panel, 0, false)
		_refresh_predator_raw_preview()
		return

	score_panel.visible = true
	_refresh_prey_hand_preview(result)
	_refresh_predator_target_rows(result)


func _refresh_play_button() -> void:
	play_button.disabled = _is_round_resolving or not GameState.can_resolve_player_table()


func _set_input_available(is_available: bool) -> void:
	play_button.disabled = not is_available or not GameState.can_resolve_player_table()
	prey_deck.set_cards_available(is_available)
	player_hand_deck.set_cards_available(is_available)
	discard_pile.mouse_filter = Control.MOUSE_FILTER_STOP if is_available else Control.MOUSE_FILTER_IGNORE


func _on_play_pressed() -> void:
	if _is_round_resolving or not GameState.can_resolve_player_table():
		return

	_is_round_resolving = true
	_set_input_available(false)
	var result := GameState.get_player_table_score_result()
	await _reveal_score_result(result)
	GameState.change_score(int(roundf(float(result.get("score_gain", 0.0)))))
	GameState.change_health(-int(result.get("damage", 0)))

	if GameState.get_health() <= 0:
		get_tree().change_scene_to_file(GAME_OVER_SCENE)
		return

	GameState.go_next_round()
	_is_round_resolving = false
	_set_input_available(true)
	_refresh_score_preview()
	_refresh_play_button()


func _reveal_score_result(result: Dictionary) -> void:
	score_panel.visible = true
	predator_score_panel.visible = true
	_refresh_prey_hand_preview(result)
	_refresh_predator_target_rows(result)
	_reset_score_rows(result)
	await _show_score_rows()
	await _reveal_prey_score_steps(result)
	await _reveal_predator_score_steps(result)
	await get_tree().create_timer(SCORE_REVEAL_INTERVAL * 2.0).timeout


func _refresh_prey_hand_preview(result: Dictionary) -> void:
	hand_label.text = "%s +%s" % [
		str(result.get("hand_label", "High Card")),
		_format_score(float(result.get("score_gain", 0.0)))
	]
	for suit in SUIT_ORDER:
		var prey_row := _get_suit_row(suit)
		prey_row.visible = false
		prey_row.text = "%s 0" % _get_suit_label(suit)

	suit_rows.visible = false
	suit_rows.modulate.a = 1.0
	_set_score_panel_row_count(score_panel, 0, false)


func _refresh_predator_raw_preview() -> void:
	var result := GameState.get_player_table_score_result()
	predator_score_panel.visible = true
	predator_hand_label.text = str(result.get("predator_hand_label", "High Card"))

	var raw_scores := {
		Cards.SUIT_WATER: 0,
		Cards.SUIT_LAND: 0,
		Cards.SUIT_AIR: 0,
	}
	for predator in GameState.get_predators():
		if not (predator is Dictionary):
			continue

		var suit := str(predator.get("suit", ""))
		if raw_scores.has(suit):
			raw_scores[suit] = int(raw_scores[suit]) + _get_card_value(predator)

	var row_count := 0
	for suit in SUIT_ORDER:
		var row := _get_predator_suit_row(suit)
		var score := int(raw_scores[suit])
		row.visible = score > 0
		row.text = "%s %s" % [_get_suit_label(suit), int(raw_scores[suit])]
		if row.visible:
			row_count += 1

	predator_suit_rows.visible = row_count > 0
	_set_score_panel_row_count(predator_score_panel, row_count, false)


func _reset_score_rows(result: Dictionary) -> void:
	var suits: Dictionary = result.get("suits", {})
	for suit in SUIT_ORDER:
		var suit_result: Dictionary = suits.get(suit, {})
		var row := _get_suit_row(suit)
		row.visible = int(suit_result.get("prey_count", 0)) > 0
		row.text = "%s 0" % _get_suit_label(suit)


func _show_score_rows() -> void:
	var row_count := _get_visible_suit_row_count()
	await _set_score_panel_row_count(score_panel, row_count, true)
	suit_rows.visible = true
	suit_rows.modulate.a = 0.0

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(suit_rows, "modulate:a", 1.0, SCORE_PANEL_SLIDE_DURATION)
	await tween.finished


func _set_score_panel_row_count(panel: Panel, row_count: int, animate: bool) -> void:
	var target_height := maxf(
		SCORE_PANEL_MIN_HEIGHT, SCORE_PANEL_BASE_HEIGHT + SCORE_PANEL_ROW_HEIGHT * float(row_count)
	)
	var target_size := Vector2(SCORE_PANEL_WIDTH, target_height)
	if not animate:
		panel.size = target_size
		return

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "size", target_size, SCORE_PANEL_SLIDE_DURATION)
	await tween.finished


func _reveal_prey_score_steps(result: Dictionary) -> void:
	for step in result.get("card_steps", []):
		if not (step is Dictionary):
			continue

		var suit := str(step.get("suit", ""))
		var row := _get_suit_row(suit)
		var card_id := str(step.get("id", ""))
		await _pulse_prey_card(card_id)
		row.text = "%s %s" % [
			_get_suit_label(suit), _format_score(float(step.get("score_after", 0.0)))
		]
		await get_tree().create_timer(SCORE_REVEAL_INTERVAL).timeout


func _reveal_predator_score_steps(result: Dictionary) -> void:
	var suits: Dictionary = result.get("suits", {})
	for suit in SUIT_ORDER:
		var suit_result: Dictionary = suits.get(suit, {})
		if int(suit_result.get("prey_count", 0)) <= 0:
			continue

		var prey_row := _get_suit_row(suit)
		prey_row.text = "%s %s" % [
			_get_suit_label(suit), _format_score(float(suit_result.get("prey_score", 0.0)))
		]
		await get_tree().create_timer(SCORE_REVEAL_INTERVAL).timeout


func _refresh_predator_target_rows(result: Dictionary) -> void:
	predator_hand_label.text = str(result.get("predator_hand_label", "High Card"))
	var suits: Dictionary = result.get("suits", {})
	var row_count := 0
	for suit in SUIT_ORDER:
		var suit_result: Dictionary = suits.get(suit, {})
		var row := _get_predator_suit_row(suit)
		row.visible = int(suit_result.get("prey_count", 0)) > 0
		if not row.visible:
			continue

		row_count += 1
		row.text = "%s %s" % [
			_get_suit_label(suit),
			_format_score(float(suit_result.get("predator_target_score", 0.0)))
		]

	predator_suit_rows.visible = row_count > 0
	_set_score_panel_row_count(predator_score_panel, row_count, false)


func _pulse_prey_card(card_id: String) -> void:
	var card := prey_deck.get_card_by_id(card_id)
	if card:
		await card.pulse_highlight()
	else:
		await get_tree().create_timer(SCORE_REVEAL_INTERVAL).timeout


func _get_suit_row(suit: String) -> Label:
	match suit:
		Cards.SUIT_WATER:
			return water_row
		Cards.SUIT_LAND:
			return land_row
		_:
			return air_row


func _get_predator_suit_row(suit: String) -> Label:
	match suit:
		Cards.SUIT_WATER:
			return predator_water_row
		Cards.SUIT_LAND:
			return predator_land_row
		_:
			return predator_air_row


func _get_visible_suit_row_count() -> int:
	var row_count := 0
	for suit in SUIT_ORDER:
		if _get_suit_row(suit).visible:
			row_count += 1

	return row_count


func _get_suit_label(suit: String) -> String:
	match suit:
		Cards.SUIT_WATER:
			return "Water"
		Cards.SUIT_LAND:
			return "Land"
		_:
			return "Air"


func _format_score(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))

	return "%.1f" % value


func _get_card_value(card: Dictionary) -> int:
	var value := int(card.get("value", 0))
	if value == 1:
		return 14

	return value


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


func _on_score_changed(_score: int) -> void:
	_refresh_hud()


func _on_health_changed(_health: int) -> void:
	_refresh_hud()


func _on_predators_changed(_predators: Array) -> void:
	if _is_round_resolving:
		return

	_refresh_score_preview()


func _on_player_table_changed(_player_table: Array) -> void:
	if _is_round_resolving:
		return

	_refresh_score_preview()
	_refresh_play_button()


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

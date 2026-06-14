extends Control
class_name PreyDeck

signal card_move_animation_requested(card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float)

const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_SIZE: Vector2 = Vector2(110.0, 154.0)
const CARD_SEPARATION: float = 16.0
const DISCARD_CARD_SEPARATION: float = -22.0
const DISCARD_PULL_OFFSET: Vector2 = Vector2(92.0, 0.0)
const DISCARD_HOVER_DURATION: float = 0.16
const DISCARD_MOVE_DURATION: float = 0.58
const DISCARD_FLIP_DURATION: float = 0.24
const DISCARD_STAGGER_DURATION: float = 0.08
const SHIFT_DURATION: float = 0.14
const TABLE_INDEX_META: String = "prey_deck_index"

var _has_rendered_cards: bool = false
var _is_available: bool = true
var _is_discard_hovered: bool = false
var _is_discard_animating: bool = false
var _layout_tween: Tween


func _ready() -> void:
	GameState.player_table_changed.connect(_on_player_table_changed)
	GameState.player_table_move_failed.connect(_on_player_table_move_failed)
	render_cards()


func render_cards() -> void:
	if not _has_rendered_cards:
		_clear_cards()

	var existing_cards := _get_cards_by_id()
	var moving_cards := []
	var next_card_ids := {}
	var prey := GameState.get_player_table()
	print("PreyDeck initial cards: ", prey)

	for index in range(prey.size()):
		var prey_card = prey[index]
		if prey_card is Dictionary:
			var card_id := _get_prey_card_id(prey_card)
			var card: CardScene = existing_cards.get(card_id, null) as CardScene
			next_card_ids[card_id] = true

			if card:
				moving_cards.append(card)
				card.set_meta(TABLE_INDEX_META, index)
			else:
				_add_card(prey_card, index)

	_remove_missing_cards(next_card_ids)
	_layout_cards(_has_rendered_cards, moving_cards)
	_has_rendered_cards = true


func get_card_by_id(card_id: String) -> CardScene:
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(TABLE_INDEX_META) and card.id == card_id:
			return card

	return null


func set_cards_available(is_available: bool) -> void:
	_is_available = is_available
	for child in get_children():
		var card := child as CardScene
		if card:
			card.mouse_filter = Control.MOUSE_FILTER_STOP if _is_available else Control.MOUSE_FILTER_IGNORE


func set_discard_hovered(is_hovered: bool) -> void:
	if _is_discard_animating or _is_discard_hovered == is_hovered:
		return

	_is_discard_hovered = is_hovered
	_layout_cards(true, _get_cards_in_table_order())


func move_cards_to_discard(discard_global_position: Vector2) -> void:
	if _is_discard_animating:
		return

	var cards := _get_cards_in_table_order()
	if cards.is_empty():
		_is_discard_hovered = false
		return
	if GameState.get_player_discards_count() <= 0:
		_is_discard_hovered = false
		_layout_cards(true, cards)
		return

	var discard_card_ids := _get_limited_table_card_ids()
	if discard_card_ids.is_empty():
		_is_discard_hovered = false
		_layout_cards(true, cards)
		return

	var discard_cards := _get_cards_by_ids(discard_card_ids)

	_is_discard_animating = true
	_is_discard_hovered = true
	_layout_cards(true, cards)

	var hover_tween := _layout_tween
	if hover_tween:
		await hover_tween.finished

	if not is_inside_tree():
		_is_discard_hovered = false
		_is_discard_animating = false
		return

	var move_tween: Tween

	for index in range(discard_cards.size()):
		var card := discard_cards[index] as CardScene
		if not is_instance_valid(card):
			continue

		move_tween = card.tween_discard_to(
			discard_global_position,
			GameState.MAX_PLAYER_TABLE_CARDS + index,
			DISCARD_MOVE_DURATION,
			DISCARD_FLIP_DURATION
		)

		if index < discard_cards.size() - 1:
			await get_tree().create_timer(DISCARD_STAGGER_DURATION).timeout

	if move_tween:
		await move_tween.finished

	_is_discard_hovered = false
	_is_discard_animating = false
	GameState.discard_cards(discard_card_ids)


func _add_card(prey_card: Dictionary, table_index: int) -> void:
	print("PreyDeck instantiating card: ", prey_card)
	var card := CARD_SCENE.instantiate() as CardScene
	card.configure(
		CARD_KIND,
		str(prey_card.get("suit", "")),
		int(prey_card.get("value", 0)),
		float(prey_card.get("scale", card.art_scale)),
		float(prey_card.get("rotation", card.art_rotation_degrees))
	)
	card.set_meta(TABLE_INDEX_META, table_index)
	card.mouse_filter = Control.MOUSE_FILTER_STOP if _is_available else Control.MOUSE_FILTER_IGNORE
	card.clicked.connect(_on_card_clicked)
	add_child(card)


func _layout_cards(animate_shift: bool = false, moving_cards: Array = []) -> void:
	if _layout_tween:
		_layout_tween.kill()
		_layout_tween = null

	var cards := _get_cards_in_table_order()
	var card_count := cards.size()
	_update_minimum_size()
	if card_count == 0:
		return

	var card_separation := CARD_SEPARATION
	var layout_offset := Vector2.ZERO
	var layout_duration := SHIFT_DURATION
	if _is_discard_hovered:
		card_separation = DISCARD_CARD_SEPARATION
		layout_offset = DISCARD_PULL_OFFSET
		layout_duration = DISCARD_HOVER_DURATION

	var card_step := CARD_SIZE.x + card_separation
	var cards_width := CARD_SIZE.x + (card_step * float(card_count - 1))
	var start_x := ((custom_minimum_size.x - cards_width) * 0.5) + layout_offset.x
	var should_animate_shift := animate_shift and not moving_cards.is_empty()
	var tween_started := false
	if should_animate_shift:
		_layout_tween = create_tween()
		_layout_tween.set_trans(Tween.TRANS_SINE)
		_layout_tween.set_ease(Tween.EASE_OUT)

	for index in range(card_count):
		var card := cards[index] as CardScene
		var target_position := Vector2(
			start_x + (card_step * float(index)), layout_offset.y
		)

		card.pivot_offset = CARD_SIZE * 0.5
		card.z_index = index

		if should_animate_shift and moving_cards.has(card):
			if tween_started:
				_layout_tween.parallel().tween_property(card, "position", target_position, layout_duration)
			else:
				_layout_tween.tween_property(card, "position", target_position, layout_duration)
				tween_started = true
		else:
			card.position = target_position


func _update_minimum_size() -> void:
	var max_cards_width := CARD_SIZE.x + (
		(CARD_SIZE.x + CARD_SEPARATION) * float(GameState.MAX_PLAYER_TABLE_CARDS - 1)
	)
	custom_minimum_size = Vector2(max_cards_width, CARD_SIZE.y)


func _get_cards_in_table_order() -> Array:
	var cards := []
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(TABLE_INDEX_META):
			cards.append(card)
	cards.sort_custom(_sort_cards_by_table_index)
	return cards


func _get_limited_table_card_ids() -> Array:
	var card_ids := []
	var player_table := GameState.get_player_table()
	for card in player_table:
		if card_ids.size() >= GameState.MAX_PLAYER_DISCARD_CARDS:
			break

		if card is Dictionary:
			card_ids.append(str(card.get("id", "")))

	return card_ids


func _get_cards_by_ids(card_ids: Array) -> Array:
	var cards := []
	for card_id in card_ids:
		var card := get_card_by_id(str(card_id))
		if card:
			cards.append(card)

	return cards


func _sort_cards_by_table_index(first: Node, second: Node) -> bool:
	return int(first.get_meta(TABLE_INDEX_META, 0)) < int(second.get_meta(TABLE_INDEX_META, 0))


func _clear_cards() -> void:
	if _layout_tween:
		_layout_tween.kill()
		_layout_tween = null

	for child in get_children():
		remove_child(child)
		child.queue_free()


func _shake_cards() -> void:
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(TABLE_INDEX_META):
			card.shake_feedback()


func _get_cards_by_id() -> Dictionary:
	var cards_by_id := {}
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(TABLE_INDEX_META):
			cards_by_id[card.id] = card

	return cards_by_id


func _remove_missing_cards(next_card_ids: Dictionary) -> void:
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(TABLE_INDEX_META) and not next_card_ids.has(card.id):
			remove_child(card)
			card.queue_free()


func _get_prey_card_id(prey_card: Dictionary) -> String:
	return "%s_%s_%s" % [CARD_KIND, str(prey_card.get("suit", "")), int(prey_card.get("value", 0))]


func _on_player_table_changed(_player_table: Array) -> void:
	render_cards()


func _on_card_clicked(card_id: String) -> void:
	if not _is_available:
		return

	var source_card := get_card_by_id(card_id)
	if not source_card:
		return

	var from_global_position := source_card.global_position
	var from_rotation_degrees := source_card.rotation_degrees
	var result := GameState.move_card_from_player_table_to_hand(card_id)
	if result.is_empty():
		return

	card_move_animation_requested.emit(result, from_global_position, from_rotation_degrees)


func _on_player_table_move_failed(error: String) -> void:
	if error == GameState.ERROR_PLAYER_TABLE_FULL:
		_shake_cards()

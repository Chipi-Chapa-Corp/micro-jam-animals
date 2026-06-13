extends Control
class_name PlayerHandDeck

signal card_move_animation_requested(card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float)

const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_SIZE: Vector2 = Vector2(110.0, 154.0)
const CARD_STEP: float = 78.0
const MAX_FAN_ROTATION_DEGREES: float = 5.0
const MAX_FAN_DROP: float = 18.0
const TOP_PADDING: float = 20.0
const SHIFT_DURATION: float = 0.14
const HAND_INDEX_META: String = "player_hand_index"

var _has_rendered_cards: bool = false
var _layout_tween: Tween


func _ready() -> void:
	GameState.player_hand_changed.connect(_on_player_hand_changed)
	render_cards()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_cards()


func render_cards() -> void:
	if not _has_rendered_cards:
		_clear_cards()

	var existing_cards := _get_cards_by_id()
	var moving_cards := []
	var next_card_ids := {}
	var player_hand := GameState.get_player_hand()

	for index in range(player_hand.size()):
		var player_card = player_hand[index]
		if player_card is Dictionary:
			var card_id := _get_player_card_id(player_card)
			var card: CardScene = existing_cards.get(card_id, null) as CardScene
			next_card_ids[card_id] = true

			if card:
				moving_cards.append(card)
				card.set_meta(HAND_INDEX_META, index)
			else:
				_add_card(player_card, index)

	_remove_missing_cards(next_card_ids)

	_layout_cards(_has_rendered_cards, moving_cards)
	_has_rendered_cards = true


func get_card_by_id(card_id: String) -> CardScene:
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(HAND_INDEX_META) and card.id == card_id:
			return card

	return null


func _add_card(player_card: Dictionary, hand_index: int) -> void:
	var card := CARD_SCENE.instantiate() as CardScene
	card.configure(CARD_KIND, str(player_card.get("suit", "")), int(player_card.get("value", 0)))
	card.set_meta(HAND_INDEX_META, hand_index)
	card.clicked.connect(_on_card_clicked)
	add_child(card)


func _layout_cards(animate_shift: bool = false, moving_cards: Array = []) -> void:
	if _layout_tween:
		_layout_tween.kill()
		_layout_tween = null

	var cards := _get_cards_in_hand_order()
	var card_count := cards.size()
	if card_count == 0:
		return

	var deck_width := size.x
	if is_zero_approx(deck_width):
		deck_width = custom_minimum_size.x

	var total_width := CARD_SIZE.x + (CARD_STEP * float(card_count - 1))
	var start_x := (deck_width - total_width) * 0.5
	var center_index := float(card_count - 1) * 0.5
	var half_count := maxf(center_index, 1.0)
	var should_animate_shift := animate_shift and not moving_cards.is_empty()
	var tween_started := false
	if should_animate_shift:
		_layout_tween = create_tween()
		_layout_tween.set_trans(Tween.TRANS_SINE)
		_layout_tween.set_ease(Tween.EASE_OUT)

	for index in range(card_count):
		var card := cards[index] as CardScene
		var center_offset := float(index) - center_index
		var normalized_offset := center_offset / half_count
		var fan_drop := absf(normalized_offset) * MAX_FAN_DROP
		var target_position := Vector2(start_x + (CARD_STEP * float(index)), TOP_PADDING + fan_drop)
		var target_rotation_degrees := normalized_offset * MAX_FAN_ROTATION_DEGREES

		card.pivot_offset = CARD_SIZE * 0.5
		card.z_index = card_count - index

		if should_animate_shift and moving_cards.has(card):
			if tween_started:
				_layout_tween.parallel().tween_property(card, "position", target_position, SHIFT_DURATION)
			else:
				_layout_tween.tween_property(card, "position", target_position, SHIFT_DURATION)
				tween_started = true
			_layout_tween.parallel().tween_property(
				card, "rotation_degrees", target_rotation_degrees, SHIFT_DURATION
			)
		else:
			card.position = target_position
			card.rotation_degrees = target_rotation_degrees

	_sync_hover_order(cards)


func _sync_hover_order(cards: Array) -> void:
	var card_count := cards.size()

	for child_index in range(card_count):
		move_child(cards[card_count - child_index - 1], child_index)


func _get_cards_in_hand_order() -> Array:
	var cards := []
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(HAND_INDEX_META):
			cards.append(card)
	cards.sort_custom(_sort_cards_by_hand_index)
	return cards


func _sort_cards_by_hand_index(first: Node, second: Node) -> bool:
	return int(first.get_meta(HAND_INDEX_META, 0)) < int(second.get_meta(HAND_INDEX_META, 0))


func _clear_cards() -> void:
	if _layout_tween:
		_layout_tween.kill()
		_layout_tween = null

	for child in get_children():
		remove_child(child)
		child.queue_free()


func _get_cards_by_id() -> Dictionary:
	var cards_by_id := {}
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(HAND_INDEX_META):
			cards_by_id[card.id] = card

	return cards_by_id


func _remove_missing_cards(next_card_ids: Dictionary) -> void:
	for child in get_children():
		var card := child as CardScene
		if card and card.has_meta(HAND_INDEX_META) and not next_card_ids.has(card.id):
			remove_child(card)
			card.queue_free()


func _get_player_card_id(player_card: Dictionary) -> String:
	return "%s_%s_%s" % [
		CARD_KIND, str(player_card.get("suit", "")), int(player_card.get("value", 0))
	]


func _on_card_clicked(card_id: String) -> void:
	var source_card := get_card_by_id(card_id)
	if not source_card:
		return

	var from_global_position := source_card.global_position
	var from_rotation_degrees := source_card.rotation_degrees
	var result := GameState.move_card_from_player_hand_to_table(card_id)
	if result.has("error"):
		return

	card_move_animation_requested.emit(result, from_global_position, from_rotation_degrees)


func _on_player_hand_changed(_player_hand: Array) -> void:
	render_cards()

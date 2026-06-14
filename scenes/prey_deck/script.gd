extends Control
class_name PreyDeck

signal card_move_animation_requested(card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float)

const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_SIZE: Vector2 = Vector2(110.0, 154.0)
const CARD_SEPARATION: float = 16.0
const SHIFT_DURATION: float = 0.14
const TABLE_INDEX_META: String = "prey_deck_index"

var _has_rendered_cards: bool = false
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

	var cards_width := CARD_SIZE.x + ((CARD_SIZE.x + CARD_SEPARATION) * float(card_count - 1))
	var start_x := (custom_minimum_size.x - cards_width) * 0.5
	var should_animate_shift := animate_shift and not moving_cards.is_empty()
	var tween_started := false
	if should_animate_shift:
		_layout_tween = create_tween()
		_layout_tween.set_trans(Tween.TRANS_SINE)
		_layout_tween.set_ease(Tween.EASE_OUT)

	for index in range(card_count):
		var card := cards[index] as CardScene
		var target_position := Vector2(
			start_x + ((CARD_SIZE.x + CARD_SEPARATION) * float(index)), 0.0
		)

		card.pivot_offset = CARD_SIZE * 0.5
		card.z_index = index

		if should_animate_shift and moving_cards.has(card):
			if tween_started:
				_layout_tween.parallel().tween_property(card, "position", target_position, SHIFT_DURATION)
			else:
				_layout_tween.tween_property(card, "position", target_position, SHIFT_DURATION)
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

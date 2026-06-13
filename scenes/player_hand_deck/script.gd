extends Control
class_name PlayerHandDeck

const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_SIZE: Vector2 = Vector2(110.0, 154.0)
const CARD_STEP: float = 78.0
const MAX_FAN_ROTATION_DEGREES: float = 5.0
const MAX_FAN_DROP: float = 18.0
const TOP_PADDING: float = 20.0
const HAND_INDEX_META: String = "player_hand_index"


func _ready() -> void:
	GameState.player_hand_changed.connect(_on_player_hand_changed)
	render_cards()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_cards()


func render_cards() -> void:
	_clear_cards()

	var player_hand := GameState.get_player_hand()

	for index in range(player_hand.size()):
		var player_card = player_hand[index]
		if player_card is Dictionary:
			_add_card(player_card, index)

	_layout_cards()


func _add_card(player_card: Dictionary, hand_index: int) -> void:
	var card := CARD_SCENE.instantiate() as CardScene
	card.configure(CARD_KIND, str(player_card.get("suit", "")), int(player_card.get("value", 0)))
	card.set_meta(HAND_INDEX_META, hand_index)
	card.clicked.connect(_on_card_clicked)
	add_child(card)


func _layout_cards() -> void:
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

	for index in range(card_count):
		var card := cards[index] as CardScene
		var center_offset := float(index) - center_index
		var normalized_offset := center_offset / half_count
		var fan_drop := absf(normalized_offset) * MAX_FAN_DROP

		card.position = Vector2(start_x + (CARD_STEP * float(index)), TOP_PADDING + fan_drop)
		card.pivot_offset = CARD_SIZE * 0.5
		card.rotation_degrees = normalized_offset * MAX_FAN_ROTATION_DEGREES
		card.z_index = card_count - index

	_sync_hover_order(cards)


func _sync_hover_order(cards: Array) -> void:
	var card_count := cards.size()

	for child_index in range(card_count):
		move_child(cards[card_count - child_index - 1], child_index)


func _get_cards_in_hand_order() -> Array:
	var cards := get_children()
	cards.sort_custom(_sort_cards_by_hand_index)
	return cards


func _sort_cards_by_hand_index(first: Node, second: Node) -> bool:
	return int(first.get_meta(HAND_INDEX_META, 0)) < int(second.get_meta(HAND_INDEX_META, 0))


func _clear_cards() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _on_card_clicked(card_id: String) -> void:
	var result := GameState.move_card_from_player_hand_to_table(card_id)
	if result.has("error"):
		return


func _on_player_hand_changed(_player_hand: Array) -> void:
	render_cards()

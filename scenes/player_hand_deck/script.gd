extends Control
class_name PlayerHandDeck

const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_SIZE: Vector2 = Vector2(145.0, 203.0)
const CARD_STEP: float = 94.0
const MAX_FAN_ROTATION_DEGREES: float = 5.0
const MAX_FAN_DROP: float = 18.0
const TOP_PADDING: float = 20.0


func _ready() -> void:
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
			_add_card(player_card)

	_layout_cards()


func _add_card(player_card: Dictionary) -> void:
	var card := CARD_SCENE.instantiate() as CardScene
	card.configure(CARD_KIND, str(player_card.get("suit", "")), int(player_card.get("value", 0)))
	add_child(card)


func _layout_cards() -> void:
	var cards := get_children()
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
		card.z_index = index


func _clear_cards() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

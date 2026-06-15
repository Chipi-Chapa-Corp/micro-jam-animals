extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"
const GAME_SCENE: String = "res://scenes/game/scene.tscn"
const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_GAP: int = 10
const HAND_HIGH_CARD: String = "high_card"
const HAND_PAIR: String = "pair"
const HAND_TWO_PAIR: String = "two_pair"
const HAND_THREE_OF_A_KIND: String = "three_of_a_kind"
const HAND_STRAIGHT: String = "straight"
const HAND_FULL_HOUSE: String = "full_house"
const SUITS: Array[String] = ["water", "land", "air"]
const HAND_KEYS: Array[String] = [
	HAND_HIGH_CARD,
	HAND_PAIR,
	HAND_TWO_PAIR,
	HAND_THREE_OF_A_KIND,
	HAND_STRAIGHT,
	HAND_FULL_HOUSE,
]
const STRAIGHT_VALUES: Array = [
	[1, 2, 3, 4, 5],
	[2, 3, 4, 5, 6],
	[3, 4, 5, 6, 7],
	[4, 5, 6, 7, 8],
	[5, 6, 7, 8, 9],
	[6, 7, 8, 9, 10],
	[7, 8, 9, 10, 11],
	[8, 9, 10, 11, 12],
	[9, 10, 11, 12, 13],
	[10, 11, 12, 13, 1],
]

@onready var hand_rows: VBoxContainer = $MarginContainer/Content/ScrollContainer/Hands/HandRows

var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()
	_render_hands()


func _render_hands() -> void:
	for child in hand_rows.get_children():
		child.queue_free()

	for index in range(HAND_KEYS.size()):
		var hand_key := HAND_KEYS[index]
		hand_rows.add_child(_create_hand_row(hand_key))

		if index < HAND_KEYS.size() - 1:
			hand_rows.add_child(HSeparator.new())


func _create_hand_row(hand_key: String) -> VBoxContainer:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)

	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text = "%s x%s" % [
		str(GameState.HAND_LABELS.get(hand_key, "High Card")),
		_format_multiplier(float(GameState.HAND_MULTIPLIERS.get(hand_key, 1.0))),
	]
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(title)

	row.add_child(header)

	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", CARD_GAP)

	for card_definition in _get_random_hand_cards(hand_key):
		cards.add_child(_create_card(card_definition))

	row.add_child(cards)
	return row


func _create_card(card_definition: Dictionary) -> CardScene:
	var card := CARD_SCENE.instantiate() as CardScene
	card.configure(
		CARD_KIND,
		str(card_definition.get("suit", "")),
		int(card_definition.get("value", 0)),
		float(card_definition.get("scale", card.art_scale)),
		float(card_definition.get("rotation", card.art_rotation_degrees))
	)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return card


func _get_random_hand_cards(hand_key: String) -> Array:
	return _get_cards_for_values(_get_random_hand_values(hand_key))


func _get_random_hand_values(hand_key: String) -> Array:
	match hand_key:
		HAND_PAIR:
			return _get_repeated_value_hand(2)
		HAND_TWO_PAIR:
			return _get_two_pair_values()
		HAND_THREE_OF_A_KIND:
			return _get_repeated_value_hand(3)
		HAND_STRAIGHT:
			return _get_straight_values()
		HAND_FULL_HOUSE:
			return _get_full_house_values()
		_:
			return [_get_random_card_value()]


func _get_repeated_value_hand(count: int) -> Array:
	var value := _get_random_card_value()
	var values := []

	for _index in range(count):
		values.append(value)

	return values


func _get_two_pair_values() -> Array:
	var pair_values := _get_random_unique_values(2)
	return [pair_values[0], pair_values[0], pair_values[1], pair_values[1]]


func _get_straight_values() -> Array:
	var random_index := _random.randi_range(0, STRAIGHT_VALUES.size() - 1)
	return STRAIGHT_VALUES[random_index].duplicate()


func _get_full_house_values() -> Array:
	var values := _get_random_unique_values(2)
	return [values[0], values[0], values[0], values[1], values[1]]


func _get_random_unique_values(count: int) -> Array:
	var values := []

	while values.size() < count:
		var value := _get_random_card_value()

		if not values.has(value):
			values.append(value)

	return values


func _get_random_card_value() -> int:
	return _random.randi_range(1, 13)


func _get_cards_for_values(values: Array) -> Array:
	var cards := []
	var picked_ids := {}

	for value in values:
		var card := _get_random_prey_card(int(value), picked_ids)
		if not card.is_empty():
			cards.append(card)

	return cards


func _get_random_prey_card(value: int, picked_ids: Dictionary) -> Dictionary:
	var available_ids := []

	for suit in SUITS:
		var card_id := "%s_%s_%s" % [CARD_KIND, suit, value]
		if not picked_ids.has(card_id):
			available_ids.append(card_id)

	if available_ids.is_empty():
		return {}

	var random_index := _random.randi_range(0, available_ids.size() - 1)
	var picked_id: String = available_ids[random_index]
	picked_ids[picked_id] = true
	return Cards.get_by_id(picked_id)


func _format_multiplier(multiplier: float) -> String:
	if is_equal_approx(multiplier, roundf(multiplier)):
		return str(int(roundf(multiplier)))

	return str(multiplier)


func _on_back_pressed() -> void:
	if get_tree().current_scene != self:
		queue_free()
		return

	if GameState.is_game_active():
		get_tree().change_scene_to_file(GAME_SCENE)
		return

	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

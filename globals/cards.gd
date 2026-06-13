extends Node

const SUIT_WATER: String = "water"
const SUIT_LAND: String = "land"
const SUIT_AIR: String = "air"
const PREDATOR_HAND_HIGH_CARD: String = "high_card"
const PREDATOR_HAND_PAIR: String = "pair"
const PREDATOR_HAND_THREE_OF_A_KIND: String = "three_of_a_kind"
const PREDATOR_HAND_TWO_PAIR: String = "two_pair"
const PREDATOR_HAND_STRAIGHT: String = "straight"
const PREDATOR_HAND_FULL_HOUSE: String = "full_house"
const PREDATOR_HAND_PATTERNS: Array[String] = [
	PREDATOR_HAND_HIGH_CARD,
	PREDATOR_HAND_PAIR,
	PREDATOR_HAND_THREE_OF_A_KIND,
	PREDATOR_HAND_TWO_PAIR,
	PREDATOR_HAND_STRAIGHT,
	PREDATOR_HAND_FULL_HOUSE,
]
const PREDATOR_STRAIGHT_VALUES: Array = [
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

const PREY_IDS: Array[String] = [
	"prey_water_1",
	"prey_water_2",
	"prey_water_3",
	"prey_water_4",
	"prey_water_5",
	"prey_water_6",
	"prey_water_7",
	"prey_water_8",
	"prey_water_9",
	"prey_water_10",
	"prey_water_11",
	"prey_water_12",
	"prey_water_13",
	"prey_land_1",
	"prey_land_2",
	"prey_land_3",
	"prey_land_4",
	"prey_land_5",
	"prey_land_6",
	"prey_land_7",
	"prey_land_8",
	"prey_land_9",
	"prey_land_10",
	"prey_land_11",
	"prey_land_12",
	"prey_land_13",
	"prey_air_1",
	"prey_air_2",
	"prey_air_3",
	"prey_air_4",
	"prey_air_5",
	"prey_air_6",
	"prey_air_7",
	"prey_air_8",
	"prey_air_9",
	"prey_air_10",
	"prey_air_11",
	"prey_air_12",
	"prey_air_13",
]

const PREDATOR_IDS: Array[String] = [
	"predator_water_1",
	"predator_water_2",
	"predator_water_3",
	"predator_water_4",
	"predator_water_5",
	"predator_water_6",
	"predator_water_7",
	"predator_water_8",
	"predator_water_9",
	"predator_water_10",
	"predator_water_11",
	"predator_water_12",
	"predator_water_13",
	"predator_land_1",
	"predator_land_2",
	"predator_land_3",
	"predator_land_4",
	"predator_land_5",
	"predator_land_6",
	"predator_land_7",
	"predator_land_8",
	"predator_land_9",
	"predator_land_10",
	"predator_land_11",
	"predator_land_12",
	"predator_land_13",
	"predator_air_1",
	"predator_air_2",
	"predator_air_3",
	"predator_air_4",
	"predator_air_5",
	"predator_air_6",
	"predator_air_7",
	"predator_air_8",
	"predator_air_9",
	"predator_air_10",
	"predator_air_11",
	"predator_air_12",
	"predator_air_13",
]

const DEFINITIONS: Dictionary = {
	"prey_water_1": {"id": "prey_water_1", "value": 1, "suit": SUIT_WATER},
	"prey_water_2": {"id": "prey_water_2", "value": 2, "suit": SUIT_WATER},
	"prey_water_3": {"id": "prey_water_3", "value": 3, "suit": SUIT_WATER},
	"prey_water_4": {"id": "prey_water_4", "value": 4, "suit": SUIT_WATER},
	"prey_water_5": {"id": "prey_water_5", "value": 5, "suit": SUIT_WATER},
	"prey_water_6": {"id": "prey_water_6", "value": 6, "suit": SUIT_WATER},
	"prey_water_7": {"id": "prey_water_7", "value": 7, "suit": SUIT_WATER},
	"prey_water_8": {"id": "prey_water_8", "value": 8, "suit": SUIT_WATER},
	"prey_water_9": {"id": "prey_water_9", "value": 9, "suit": SUIT_WATER},
	"prey_water_10": {"id": "prey_water_10", "value": 10, "suit": SUIT_WATER},
	"prey_water_11": {"id": "prey_water_11", "value": 11, "suit": SUIT_WATER},
	"prey_water_12": {"id": "prey_water_12", "value": 12, "suit": SUIT_WATER},
	"prey_water_13": {"id": "prey_water_13", "value": 13, "suit": SUIT_WATER},
	"prey_land_1": {"id": "prey_land_1", "value": 1, "suit": SUIT_LAND},
	"prey_land_2": {"id": "prey_land_2", "value": 2, "suit": SUIT_LAND},
	"prey_land_3": {"id": "prey_land_3", "value": 3, "suit": SUIT_LAND},
	"prey_land_4": {"id": "prey_land_4", "value": 4, "suit": SUIT_LAND},
	"prey_land_5": {"id": "prey_land_5", "value": 5, "suit": SUIT_LAND},
	"prey_land_6": {"id": "prey_land_6", "value": 6, "suit": SUIT_LAND},
	"prey_land_7": {"id": "prey_land_7", "value": 7, "suit": SUIT_LAND},
	"prey_land_8": {"id": "prey_land_8", "value": 8, "suit": SUIT_LAND},
	"prey_land_9": {"id": "prey_land_9", "value": 9, "suit": SUIT_LAND},
	"prey_land_10": {"id": "prey_land_10", "value": 10, "suit": SUIT_LAND},
	"prey_land_11": {"id": "prey_land_11", "value": 11, "suit": SUIT_LAND},
	"prey_land_12": {"id": "prey_land_12", "value": 12, "suit": SUIT_LAND},
	"prey_land_13": {"id": "prey_land_13", "value": 13, "suit": SUIT_LAND},
	"prey_air_1": {"id": "prey_air_1", "value": 1, "suit": SUIT_AIR},
	"prey_air_2": {"id": "prey_air_2", "value": 2, "suit": SUIT_AIR},
	"prey_air_3": {"id": "prey_air_3", "value": 3, "suit": SUIT_AIR},
	"prey_air_4": {"id": "prey_air_4", "value": 4, "suit": SUIT_AIR},
	"prey_air_5": {"id": "prey_air_5", "value": 5, "suit": SUIT_AIR},
	"prey_air_6": {"id": "prey_air_6", "value": 6, "suit": SUIT_AIR},
	"prey_air_7": {"id": "prey_air_7", "value": 7, "suit": SUIT_AIR},
	"prey_air_8": {"id": "prey_air_8", "value": 8, "suit": SUIT_AIR},
	"prey_air_9": {"id": "prey_air_9", "value": 9, "suit": SUIT_AIR},
	"prey_air_10": {"id": "prey_air_10", "value": 10, "suit": SUIT_AIR},
	"prey_air_11": {"id": "prey_air_11", "value": 11, "suit": SUIT_AIR},
	"prey_air_12": {"id": "prey_air_12", "value": 12, "suit": SUIT_AIR},
	"prey_air_13": {"id": "prey_air_13", "value": 13, "suit": SUIT_AIR},
	"predator_water_1": {"id": "predator_water_1", "value": 1, "suit": SUIT_WATER},
	"predator_water_2": {"id": "predator_water_2", "value": 2, "suit": SUIT_WATER},
	"predator_water_3": {"id": "predator_water_3", "value": 3, "suit": SUIT_WATER},
	"predator_water_4": {"id": "predator_water_4", "value": 4, "suit": SUIT_WATER},
	"predator_water_5": {"id": "predator_water_5", "value": 5, "suit": SUIT_WATER},
	"predator_water_6": {"id": "predator_water_6", "value": 6, "suit": SUIT_WATER},
	"predator_water_7": {"id": "predator_water_7", "value": 7, "suit": SUIT_WATER},
	"predator_water_8": {"id": "predator_water_8", "value": 8, "suit": SUIT_WATER},
	"predator_water_9": {"id": "predator_water_9", "value": 9, "suit": SUIT_WATER},
	"predator_water_10": {"id": "predator_water_10", "value": 10, "suit": SUIT_WATER},
	"predator_water_11": {"id": "predator_water_11", "value": 11, "suit": SUIT_WATER},
	"predator_water_12": {"id": "predator_water_12", "value": 12, "suit": SUIT_WATER},
	"predator_water_13": {"id": "predator_water_13", "value": 13, "suit": SUIT_WATER},
	"predator_land_1": {"id": "predator_land_1", "value": 1, "suit": SUIT_LAND},
	"predator_land_2": {"id": "predator_land_2", "value": 2, "suit": SUIT_LAND},
	"predator_land_3": {"id": "predator_land_3", "value": 3, "suit": SUIT_LAND},
	"predator_land_4": {"id": "predator_land_4", "value": 4, "suit": SUIT_LAND},
	"predator_land_5": {"id": "predator_land_5", "value": 5, "suit": SUIT_LAND},
	"predator_land_6": {"id": "predator_land_6", "value": 6, "suit": SUIT_LAND},
	"predator_land_7": {"id": "predator_land_7", "value": 7, "suit": SUIT_LAND},
	"predator_land_8": {"id": "predator_land_8", "value": 8, "suit": SUIT_LAND},
	"predator_land_9": {"id": "predator_land_9", "value": 9, "suit": SUIT_LAND},
	"predator_land_10": {"id": "predator_land_10", "value": 10, "suit": SUIT_LAND},
	"predator_land_11": {"id": "predator_land_11", "value": 11, "suit": SUIT_LAND},
	"predator_land_12": {"id": "predator_land_12", "value": 12, "suit": SUIT_LAND},
	"predator_land_13": {"id": "predator_land_13", "value": 13, "suit": SUIT_LAND},
	"predator_air_1": {"id": "predator_air_1", "value": 1, "suit": SUIT_AIR},
	"predator_air_2": {"id": "predator_air_2", "value": 2, "suit": SUIT_AIR},
	"predator_air_3": {"id": "predator_air_3", "value": 3, "suit": SUIT_AIR},
	"predator_air_4": {"id": "predator_air_4", "value": 4, "suit": SUIT_AIR},
	"predator_air_5": {"id": "predator_air_5", "value": 5, "suit": SUIT_AIR},
	"predator_air_6": {"id": "predator_air_6", "value": 6, "suit": SUIT_AIR},
	"predator_air_7": {"id": "predator_air_7", "value": 7, "suit": SUIT_AIR},
	"predator_air_8": {"id": "predator_air_8", "value": 8, "suit": SUIT_AIR},
	"predator_air_9": {"id": "predator_air_9", "value": 9, "suit": SUIT_AIR},
	"predator_air_10": {"id": "predator_air_10", "value": 10, "suit": SUIT_AIR},
	"predator_air_11": {"id": "predator_air_11", "value": 11, "suit": SUIT_AIR},
	"predator_air_12": {"id": "predator_air_12", "value": 12, "suit": SUIT_AIR},
	"predator_air_13": {"id": "predator_air_13", "value": 13, "suit": SUIT_AIR},
}

var _random := RandomNumberGenerator.new()


func _ready() -> void:
	_random.randomize()


func get_by_id(card_id: String) -> Dictionary:
	if not DEFINITIONS.has(card_id):
		return {}

	return DEFINITIONS[card_id].duplicate()


func pick_random_prey(count: int, excluded: Array = []) -> Array:
	return _pick_random_cards(PREY_IDS, count, excluded)


func pick_random_predator_hand(excluded: Array = []) -> Array:
	var excluded_ids := _get_excluded_ids(excluded)

	for _attempt in range(30):
		var pattern := _pick_random_predator_hand_pattern()
		var values := _get_random_predator_hand_values(pattern)
		var picked_cards := _pick_random_predators_with_values(values, excluded_ids)

		if not picked_cards.is_empty():
			return picked_cards

	return pick_random_predators(1, excluded)


func pick_random_predators(count: int, excluded: Array = []) -> Array:
	return _pick_random_cards(PREDATOR_IDS, count, excluded)


func _pick_random_cards(card_ids: Array, count: int, excluded: Array) -> Array:
	var available_ids: Array = []
	var excluded_ids := _get_excluded_ids(excluded)

	for card_id in card_ids:
		if not excluded_ids.has(card_id):
			available_ids.append(card_id)

	var picked_cards: Array = []
	var picked_count := clampi(count, 0, available_ids.size())

	for _card_index in range(picked_count):
		var random_index := _random.randi_range(0, available_ids.size() - 1)
		var card_id: String = available_ids.pop_at(random_index)
		picked_cards.append(get_by_id(card_id))

	return picked_cards


func _pick_random_predator_hand_pattern() -> String:
	var random_index := _random.randi_range(0, PREDATOR_HAND_PATTERNS.size() - 1)
	return PREDATOR_HAND_PATTERNS[random_index]


func _get_random_predator_hand_values(pattern: String) -> Array:
	match pattern:
		PREDATOR_HAND_PAIR:
			return _get_repeated_value_hand(2)
		PREDATOR_HAND_THREE_OF_A_KIND:
			return _get_repeated_value_hand(3)
		PREDATOR_HAND_TWO_PAIR:
			return _get_two_pair_values()
		PREDATOR_HAND_STRAIGHT:
			return _get_straight_values()
		PREDATOR_HAND_FULL_HOUSE:
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
	var random_index := _random.randi_range(0, PREDATOR_STRAIGHT_VALUES.size() - 1)
	return PREDATOR_STRAIGHT_VALUES[random_index].duplicate()


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


func _pick_random_predators_with_values(values: Array, excluded_ids: Dictionary) -> Array:
	var picked_cards := []
	var picked_ids := {}

	for value in values:
		var available_ids := _get_predator_ids_for_value(int(value), excluded_ids, picked_ids)

		if available_ids.is_empty():
			return []

		var random_index := _random.randi_range(0, available_ids.size() - 1)
		var card_id: String = available_ids[random_index]
		picked_ids[card_id] = true
		picked_cards.append(get_by_id(card_id))

	return picked_cards


func _get_predator_ids_for_value(
	value: int, excluded_ids: Dictionary, picked_ids: Dictionary
) -> Array:
	var available_ids := []

	for card_id in PREDATOR_IDS:
		var card := get_by_id(card_id)

		if (
			int(card.get("value", 0)) == value
			and not excluded_ids.has(card_id)
			and not picked_ids.has(card_id)
		):
			available_ids.append(card_id)

	return available_ids


func _get_excluded_ids(excluded: Array) -> Dictionary:
	var excluded_ids := {}

	for item in excluded:
		var card_id := _get_card_id(item)
		if not card_id.is_empty():
			excluded_ids[card_id] = true

	return excluded_ids


func _get_card_id(card: Variant) -> String:
	if card is Dictionary:
		return str(card.get("id", ""))

	return str(card)

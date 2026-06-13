extends Node

const SUIT_WATER: String = "water"
const SUIT_LAND: String = "land"
const SUIT_AIR: String = "air"

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

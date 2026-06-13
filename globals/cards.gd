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
	"predator_shark",
	"predator_crocodile",
	"predator_octopus",
	"predator_lion",
	"predator_wolf",
	"predator_snake",
	"predator_eagle",
	"predator_hawk",
	"predator_owl",
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
	"predator_shark": {"id": "predator_shark", "value": 8, "suit": SUIT_WATER},
	"predator_crocodile": {"id": "predator_crocodile", "value": 6, "suit": SUIT_WATER},
	"predator_octopus": {"id": "predator_octopus", "value": 5, "suit": SUIT_WATER},
	"predator_lion": {"id": "predator_lion", "value": 8, "suit": SUIT_LAND},
	"predator_wolf": {"id": "predator_wolf", "value": 6, "suit": SUIT_LAND},
	"predator_snake": {"id": "predator_snake", "value": 4, "suit": SUIT_LAND},
	"predator_eagle": {"id": "predator_eagle", "value": 7, "suit": SUIT_AIR},
	"predator_hawk": {"id": "predator_hawk", "value": 5, "suit": SUIT_AIR},
	"predator_owl": {"id": "predator_owl", "value": 4, "suit": SUIT_AIR},
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

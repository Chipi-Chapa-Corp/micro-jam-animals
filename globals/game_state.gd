extends Node

signal score_changed(score: int)
signal health_changed(health: int)
signal player_hand_changed(player_hand: Array)
signal player_table_changed(player_table: Array)
signal player_table_move_failed(error: String)
signal player_cards_discarded(discarded_cards: Array, new_cards: Array, player_discards_count: int)
signal player_discards_count_changed(player_discards_count: int)

const DEFAULT_SCORE: int = 0
const DEFAULT_HEALTH: int = 100
const DEFAULT_ROUND: int = 0
const RANDOM_PREDATOR_HAND_COUNT: int = -1
const DEFAULT_PLAYER_HAND_COUNT: int = 10
const DEFAULT_PLAYER_DISCARDS_COUNT: int = 3
const MAX_PLAYER_TABLE_CARDS: int = 5
const MAX_PLAYER_DISCARD_CARDS: int = 3
const ERROR_PLAYER_TABLE_FULL: String = "player_table_full"

var _score: int = DEFAULT_SCORE
var _health: int = DEFAULT_HEALTH
var _round: int = DEFAULT_ROUND
var _predators: Array = []
var _player_hand: Array = []
var _player_table: Array = []
var _player_discards_count: int = DEFAULT_PLAYER_DISCARDS_COUNT


func reset() -> void:
	set_score(DEFAULT_SCORE)
	set_health(DEFAULT_HEALTH)
	_set_round(DEFAULT_ROUND)
	generate_predators(0)
	set_player_hand([])
	set_player_table([])
	_set_player_discards_count(DEFAULT_PLAYER_DISCARDS_COUNT)


func start_new_round() -> void:
	_set_round(_round + 1)
	generate_predators()
	fill_player_hand()
	set_player_table([])
	_set_player_discards_count(DEFAULT_PLAYER_DISCARDS_COUNT)


func go_next_round() -> void:
	start_new_round()


func get_score() -> int:
	return _score


func set_score(value: int) -> void:
	if _score == value:
		return

	_score = value
	score_changed.emit(_score)


func change_score(amount: int) -> void:
	set_score(_score + amount)


func get_health() -> int:
	return _health


func set_health(value: int) -> void:
	if _health == value:
		return

	_health = value
	health_changed.emit(_health)


func change_health(amount: int) -> void:
	set_health(_health + amount)


func get_round() -> int:
	return _round


func get_predators() -> Array:
	return _predators.duplicate()


func generate_predators(count: int = RANDOM_PREDATOR_HAND_COUNT, excluded: Array = []) -> Array:
	var next_predators := []

	if count == RANDOM_PREDATOR_HAND_COUNT:
		next_predators = Cards.pick_random_predator_hand(excluded)
	else:
		next_predators = Cards.pick_random_predators(count, excluded)

	_predators = next_predators
	return get_predators()


func get_player_hand() -> Array:
	return _player_hand.duplicate()


func set_player_hand(value: Array) -> void:
	_player_hand = value.duplicate()
	player_hand_changed.emit(get_player_hand())


func generate_player_hand(count: int = DEFAULT_PLAYER_HAND_COUNT, excluded: Array = []) -> Array:
	set_player_hand(Cards.pick_random_prey(count, excluded))
	return get_player_hand()


func fill_player_hand(count: int = DEFAULT_PLAYER_HAND_COUNT) -> Array:
	var missing_count := count - _player_hand.size()
	if missing_count <= 0:
		return get_player_hand()

	var excluded_cards := []
	excluded_cards.append_array(_player_hand)
	excluded_cards.append_array(_player_table)

	_player_hand.append_array(Cards.pick_random_prey(missing_count, excluded_cards))
	return get_player_hand()


func get_player_table() -> Array:
	return _player_table.duplicate()


func set_player_table(value: Array) -> void:
	_player_table = value.duplicate()
	player_table_changed.emit(get_player_table())


func move_card_from_player_hand_to_table(card_id: String) -> Dictionary:
	var index := _find_card_index_by_id(_player_hand, card_id)
	if index == -1:
		return {}

	if _player_table.size() >= MAX_PLAYER_TABLE_CARDS:
		player_table_move_failed.emit(ERROR_PLAYER_TABLE_FULL)
		return {"error": ERROR_PLAYER_TABLE_FULL}

	var next_player_hand := get_player_hand()
	var next_player_table := get_player_table()
	var card: Dictionary = next_player_hand.pop_at(index)
	next_player_table.append(card)
	set_player_hand(next_player_hand)
	set_player_table(next_player_table)
	return card.duplicate()


func move_card_from_player_table_to_hand(card_id: String) -> Dictionary:
	var index := _find_card_index_by_id(_player_table, card_id)
	if index == -1:
		return {}

	var next_player_hand := get_player_hand()
	var next_player_table := get_player_table()
	var card: Dictionary = next_player_table.pop_at(index)
	next_player_hand.append(card)
	set_player_table(next_player_table)
	set_player_hand(next_player_hand)
	return card.duplicate()


func discard_cards(card_ids: Array) -> Array:
	if _player_discards_count <= 0:
		return []

	var discarded_cards := _take_cards_from_player_hand(card_ids, MAX_PLAYER_DISCARD_CARDS)
	if discarded_cards.is_empty():
		return []

	var excluded_cards := []
	excluded_cards.append_array(_player_hand)
	excluded_cards.append_array(_player_table)
	excluded_cards.append_array(discarded_cards)

	var new_cards := Cards.pick_random_prey(discarded_cards.size(), excluded_cards)
	_player_hand.append_array(new_cards)
	_set_player_discards_count(_player_discards_count - 1)
	player_cards_discarded.emit(
		_duplicate_cards(discarded_cards), _duplicate_cards(new_cards), _player_discards_count
	)
	return _duplicate_cards(new_cards)


func get_player_discards_count() -> int:
	return _player_discards_count


func _set_round(value: int) -> void:
	_round = value


func _set_player_discards_count(value: int) -> void:
	if _player_discards_count == value:
		return

	_player_discards_count = value
	player_discards_count_changed.emit(_player_discards_count)


func _find_card_index_by_id(cards: Array, card_id: String) -> int:
	for index in range(cards.size()):
		var card = cards[index]
		if card is Dictionary and card.get("id", "") == card_id:
			return index

	return -1


func _take_cards_from_player_hand(card_ids: Array, limit: int) -> Array:
	var next_player_hand := get_player_hand()
	var taken_cards := []

	for card_id in card_ids:
		if taken_cards.size() >= limit:
			break

		var index := _find_card_index_by_id(next_player_hand, str(card_id))
		if index == -1:
			continue

		taken_cards.append(next_player_hand.pop_at(index))

	if not taken_cards.is_empty():
		set_player_hand(next_player_hand)

	return taken_cards


func _duplicate_cards(cards: Array) -> Array:
	var duplicates := []

	for card in cards:
		if card is Dictionary:
			duplicates.append(card.duplicate())
		else:
			duplicates.append(card)

	return duplicates

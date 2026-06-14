extends Node

signal score_changed(score: int)
signal health_changed(health: int)
signal predators_changed(predators: Array)
signal player_hand_changed(player_hand: Array)
signal player_table_changed(player_table: Array)
signal player_table_move_failed(error: String)
signal player_cards_discarded(discarded_cards: Array, new_cards: Array, player_discards_count: int)
signal player_discards_count_changed(player_discards_count: int)

const DEFAULT_SCORE: int = 0
const DEFAULT_HEALTH: int = 100
const DEFAULT_ROUND: int = 0
const RANDOM_PREDATOR_HAND_COUNT: int = -1
const DEFAULT_PLAYER_HAND_COUNT: int = 8
const DEFAULT_PLAYER_DISCARDS_COUNT: int = 2
const MIN_PLAYER_TABLE_CARDS: int = 1
const MAX_PLAYER_TABLE_CARDS: int = 5
const MAX_PLAYER_DISCARD_CARDS: int = MAX_PLAYER_TABLE_CARDS
const ERROR_PLAYER_TABLE_FULL: String = "player_table_full"
const HAND_HIGH_CARD: String = "high_card"
const HAND_PAIR: String = "pair"
const HAND_TWO_PAIR: String = "two_pair"
const HAND_THREE_OF_A_KIND: String = "three_of_a_kind"
const HAND_STRAIGHT: String = "straight"
const HAND_FULL_HOUSE: String = "full_house"
const DAMAGE_SCALE: float = 12.0
const MATCHUP_WEAK_MULTIPLIER: float = 0.75
const MATCHUP_SAME_MULTIPLIER: float = 1.0
const MATCHUP_STRONG_MULTIPLIER: float = 1.25
const HAND_MULTIPLIERS: Dictionary = {
	HAND_HIGH_CARD: 1.0,
	HAND_PAIR: 2.0,
	HAND_TWO_PAIR: 3.0,
	HAND_THREE_OF_A_KIND: 4.0,
	HAND_STRAIGHT: 5.0,
	HAND_FULL_HOUSE: 6.0,
}
const HAND_LABELS: Dictionary = {
	HAND_HIGH_CARD: "High Card",
	HAND_PAIR: "Pair",
	HAND_TWO_PAIR: "Two Pair",
	HAND_THREE_OF_A_KIND: "Three of a Kind",
	HAND_STRAIGHT: "Straight",
	HAND_FULL_HOUSE: "Full House",
}

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
	predators_changed.emit(get_predators())
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
	player_hand_changed.emit(get_player_hand())
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

	var discarded_cards := _take_cards_from_player_table(card_ids, MAX_PLAYER_DISCARD_CARDS)
	if discarded_cards.is_empty():
		return []

	var excluded_cards := []
	excluded_cards.append_array(_player_hand)
	excluded_cards.append_array(_player_table)
	excluded_cards.append_array(discarded_cards)

	var new_cards := Cards.pick_random_prey(discarded_cards.size(), excluded_cards)
	var next_player_hand := get_player_hand()
	next_player_hand.append_array(new_cards)
	set_player_hand(next_player_hand)
	var next_player_discards_count := _player_discards_count - 1
	player_cards_discarded.emit(
		_duplicate_cards(discarded_cards), _duplicate_cards(new_cards), next_player_discards_count
	)
	_set_player_discards_count(next_player_discards_count)
	return _duplicate_cards(new_cards)


func get_player_discards_count() -> int:
	return _player_discards_count


func can_resolve_player_table() -> bool:
	return (
		_player_table.size() >= MIN_PLAYER_TABLE_CARDS
		and _player_table.size() <= MAX_PLAYER_TABLE_CARDS
	)


func get_player_table_score_result() -> Dictionary:
	return get_score_result(_player_table, _predators)


func get_score_result(prey: Array, predators: Array) -> Dictionary:
	var hand_key := _get_hand_key(prey)
	var scoring_prey := _get_scoring_cards(prey, hand_key)
	var discarded_prey := _get_discarded_cards(prey, scoring_prey)
	var scoring_value := _get_cards_score_value(scoring_prey)
	var hand_multiplier := float(HAND_MULTIPLIERS.get(hand_key, 1.0))
	var score_gain := float(scoring_value) * hand_multiplier
	var predator_hand_key := _get_hand_key(predators)
	var predator_raw_score := _get_cards_score_value(predators)
	var predator_hand_multiplier := float(HAND_MULTIPLIERS.get(predator_hand_key, 1.0))
	var predator_score := float(predator_raw_score) * predator_hand_multiplier

	var card_steps := []
	var suit_results := {}
	var total_damage := 0
	var result := {
		"hand_key": hand_key,
		"hand_label": str(HAND_LABELS.get(hand_key, "High Card")),
		"hand_multiplier": hand_multiplier,
		"scoring_value": scoring_value,
		"score_gain": score_gain,
		"predator_hand_key": predator_hand_key,
		"predator_hand_label": str(HAND_LABELS.get(predator_hand_key, "High Card")),
		"predator_hand_multiplier": predator_hand_multiplier,
		"predator_raw_score": predator_raw_score,
		"predator_score": predator_score,
		"scoring_cards": scoring_prey,
		"discarded_cards": discarded_prey,
		"card_steps": card_steps,
		"suits": suit_results,
		"damage": 0,
	}
	var suit_scores := {
		Cards.SUIT_WATER: 0.0,
		Cards.SUIT_LAND: 0.0,
		Cards.SUIT_AIR: 0.0,
	}
	var suit_counts := {
		Cards.SUIT_WATER: 0,
		Cards.SUIT_LAND: 0,
		Cards.SUIT_AIR: 0,
	}

	for card in scoring_prey:
		if not (card is Dictionary):
			continue

		var suit := str(card.get("suit", ""))
		if not suit_scores.has(suit):
			continue

		var value := _get_card_score_value(card)
		var amount := float(value)
		var score_after := float(suit_scores[suit]) + amount
		suit_scores[suit] = score_after
		suit_counts[suit] = int(suit_counts[suit]) + 1
		card_steps.append(
			{
				"id": str(card.get("id", "")),
				"suit": suit,
				"value": value,
				"multiplier": hand_multiplier,
				"amount": amount,
				"score_after": score_after,
			}
		)

	for suit in [Cards.SUIT_WATER, Cards.SUIT_LAND, Cards.SUIT_AIR]:
		var prey_count := int(suit_counts[suit])
		var base_prey_score := float(suit_scores[suit])
		var predator_target_score := 0.0
		for predator in predators:
			if not (predator is Dictionary):
				continue

			var predator_suit := str(predator.get("suit", ""))
			var predator_value := _get_card_score_value(predator)
			var multiplier := _get_matchup_multiplier(suit, predator_suit)
			var raw_amount := float(predator_value) * multiplier
			predator_target_score += raw_amount

		var prey_score := base_prey_score * hand_multiplier
		var prey_matchup_score := prey_score
		if predator_target_score > 0.0:
			prey_matchup_score = prey_score * (float(predator_raw_score) / predator_target_score)

		var escaped := prey_count > 0 and prey_matchup_score >= predator_score
		var damage := 0
		if prey_count > 0 and not escaped and predator_score > 0:
			damage = int(
				ceil(((predator_score - prey_matchup_score) / predator_score) * DAMAGE_SCALE)
			)
			damage *= prey_count

		total_damage += damage
		suit_results[suit] = {
			"prey_count": prey_count,
			"base_prey_score": base_prey_score,
			"prey_score": prey_score,
			"prey_matchup_score": prey_matchup_score,
			"predator_target_score": predator_target_score,
			"predator_score": predator_score,
			"escaped": escaped,
			"damage": damage,
		}

	result["damage"] = total_damage
	return result


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


func _take_cards_from_player_table(card_ids: Array, limit: int) -> Array:
	var next_player_table := get_player_table()
	var taken_cards := []

	for card_id in card_ids:
		if taken_cards.size() >= limit:
			break

		var index := _find_card_index_by_id(next_player_table, str(card_id))
		if index == -1:
			continue

		taken_cards.append(next_player_table.pop_at(index))

	if not taken_cards.is_empty():
		set_player_table(next_player_table)

	return taken_cards


func _duplicate_cards(cards: Array) -> Array:
	var duplicates := []

	for card in cards:
		if card is Dictionary:
			duplicates.append(card.duplicate())
		else:
			duplicates.append(card)

	return duplicates


func _get_card_score_value(card: Dictionary) -> int:
	var value := int(card.get("value", 0))
	if value == 1:
		return 14

	return value


func _get_cards_score_value(cards: Array) -> int:
	var score := 0
	for card in cards:
		if card is Dictionary:
			score += _get_card_score_value(card)

	return score


func _get_hand_key(cards: Array) -> String:
	var card_count := cards.size()
	if card_count == 0:
		return HAND_HIGH_CARD
	if _is_straight(cards):
		return HAND_STRAIGHT

	var counts := _get_rank_counts(cards)
	counts.sort()
	counts.reverse()

	if card_count == MAX_PLAYER_TABLE_CARDS and counts == [3, 2]:
		return HAND_FULL_HOUSE
	if counts[0] >= 3:
		return HAND_THREE_OF_A_KIND
	if counts[0] == 2 and counts.size() > 1 and counts[1] == 2:
		return HAND_TWO_PAIR
	if counts[0] == 2:
		return HAND_PAIR

	return HAND_HIGH_CARD


func _get_scoring_cards(cards: Array, hand_key: String) -> Array:
	match hand_key:
		HAND_FULL_HOUSE, HAND_STRAIGHT:
			return _duplicate_cards(cards)
		HAND_THREE_OF_A_KIND:
			return _get_cards_with_rank_count(cards, 3)
		HAND_TWO_PAIR:
			return _get_pair_cards(cards, 2)
		HAND_PAIR:
			return _get_pair_cards(cards, 1)
		_:
			return _get_high_card(cards)


func _get_discarded_cards(cards: Array, scoring_cards: Array) -> Array:
	var scoring_ids := {}
	for card in scoring_cards:
		if card is Dictionary:
			scoring_ids[str(card.get("id", ""))] = true

	var discarded_cards := []
	for card in cards:
		if card is Dictionary and not scoring_ids.has(str(card.get("id", ""))):
			discarded_cards.append(card.duplicate())

	return discarded_cards


func _get_cards_with_rank_count(cards: Array, count: int) -> Array:
	var ranks := _get_rank_card_groups(cards)
	var best_rank := -1

	for rank in ranks:
		var grouped_cards: Array = ranks[rank]
		if grouped_cards.size() >= count and int(rank) > best_rank:
			best_rank = int(rank)

	var scoring_cards := []
	if best_rank == -1:
		return scoring_cards

	var rank_cards: Array = ranks[best_rank]
	for index in range(mini(count, rank_cards.size())):
		var card = rank_cards[index]
		if card is Dictionary:
			scoring_cards.append(card.duplicate())

	return scoring_cards


func _get_pair_cards(cards: Array, pair_count: int) -> Array:
	var ranks := _get_rank_card_groups(cards)
	var pair_ranks := []

	for rank in ranks:
		var grouped_cards: Array = ranks[rank]
		if grouped_cards.size() >= 2:
			pair_ranks.append(int(rank))

	pair_ranks.sort()
	pair_ranks.reverse()

	var scoring_cards := []
	for index in range(mini(pair_count, pair_ranks.size())):
		var pair_cards: Array = ranks[pair_ranks[index]]
		for card_index in range(mini(2, pair_cards.size())):
			var card = pair_cards[card_index]
			if card is Dictionary:
				scoring_cards.append(card.duplicate())

	return scoring_cards


func _get_high_card(cards: Array) -> Array:
	var high_card := {}
	var high_value := -1

	for card in cards:
		if not (card is Dictionary):
			continue

		var value := _get_card_score_value(card)
		if value > high_value:
			high_value = value
			high_card = card

	if high_card.is_empty():
		return []

	return [high_card.duplicate()]


func _get_rank_card_groups(cards: Array) -> Dictionary:
	var ranks := {}

	for card in cards:
		if not (card is Dictionary):
			continue

		var value := _get_card_score_value(card)
		if not ranks.has(value):
			ranks[value] = []

		ranks[value].append(card)

	return ranks


func _get_rank_counts(cards: Array) -> Array:
	var ranks := {}

	for card in cards:
		if not (card is Dictionary):
			continue

		var value := _get_card_score_value(card)
		ranks[value] = int(ranks.get(value, 0)) + 1

	return ranks.values()


func _is_straight(cards: Array) -> bool:
	if cards.size() != MAX_PLAYER_TABLE_CARDS:
		return false

	var ranks := []
	for card in cards:
		if not (card is Dictionary):
			continue

		var value := _get_card_score_value(card)
		if ranks.has(value):
			return false

		ranks.append(value)

	if ranks.size() != MAX_PLAYER_TABLE_CARDS:
		return false

	ranks.sort()
	if ranks == [2, 3, 4, 5, 14]:
		return true

	return int(ranks[ranks.size() - 1]) - int(ranks[0]) == MAX_PLAYER_TABLE_CARDS - 1


func _get_matchup_multiplier(prey_suit: String, predator_suit: String) -> float:
	if _does_suit_beat(prey_suit, predator_suit):
		return MATCHUP_WEAK_MULTIPLIER
	if _does_suit_beat(predator_suit, prey_suit):
		return MATCHUP_STRONG_MULTIPLIER

	return MATCHUP_SAME_MULTIPLIER


func _does_suit_beat(first_suit: String, second_suit: String) -> bool:
	return (
		(first_suit == Cards.SUIT_AIR and second_suit == Cards.SUIT_LAND)
		or (first_suit == Cards.SUIT_LAND and second_suit == Cards.SUIT_WATER)
		or (first_suit == Cards.SUIT_WATER and second_suit == Cards.SUIT_AIR)
	)

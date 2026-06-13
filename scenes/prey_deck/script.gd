extends HBoxContainer
class_name PreyDeck

signal card_move_animation_requested(card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float)

const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"


func _ready() -> void:
	GameState.player_table_changed.connect(_on_player_table_changed)
	GameState.player_table_move_failed.connect(_on_player_table_move_failed)
	render_cards()


func render_cards() -> void:
	_clear_cards()

	var prey := GameState.get_player_table()
	print("PreyDeck initial cards: ", prey)

	for prey_card in prey:
		if prey_card is Dictionary:
			_add_card(prey_card)


func get_card_by_id(card_id: String) -> CardScene:
	for child in get_children():
		var card := child as CardScene
		if card and card.id == card_id:
			return card

	return null


func _add_card(prey_card: Dictionary) -> void:
	print("PreyDeck instantiating card: ", prey_card)
	var card := CARD_SCENE.instantiate() as CardScene
	card.configure(CARD_KIND, str(prey_card.get("suit", "")), int(prey_card.get("value", 0)))
	card.clicked.connect(_on_card_clicked)
	add_child(card)


func _clear_cards() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _shake_cards() -> void:
	for child in get_children():
		var card := child as CardScene
		if card:
			card.shake_feedback()


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

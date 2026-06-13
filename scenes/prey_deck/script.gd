extends HBoxContainer
class_name PreyDeck

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


func _add_card(prey_card: Dictionary) -> void:
	print("PreyDeck instantiating card: ", prey_card)
	var card := CARD_SCENE.instantiate() as CardScene
	card.configure(CARD_KIND, str(prey_card.get("suit", "")), int(prey_card.get("value", 0)))
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


func _on_player_table_move_failed(error: String) -> void:
	if error == GameState.ERROR_PLAYER_TABLE_FULL:
		_shake_cards()

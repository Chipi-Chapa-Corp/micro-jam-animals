extends HBoxContainer
class_name PredatorDeck

const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "predator"


func _ready() -> void:
	render_cards()


func render_cards() -> void:
	_clear_cards()

	var predators := GameState.get_predators()
	print("PredatorDeck initial cards: ", predators)

	for predator in predators:
		if predator is Dictionary:
			_add_card(predator)


func _add_card(predator: Dictionary) -> void:
	print("PredatorDeck instantiating card: ", predator)
	var card := CARD_SCENE.instantiate() as CardScene
	card.configure(
		CARD_KIND,
		str(predator.get("suit", "")),
		int(predator.get("value", 0)),
		float(predator.get("scale", card.art_scale)),
		float(predator.get("rotation", card.art_rotation_degrees))
	)
	add_child(card)


func _clear_cards() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

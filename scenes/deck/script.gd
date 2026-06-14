extends Control

const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"
const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const PREY_KIND: String = "prey"
const PREDATOR_KIND: String = "predator"
const CARD_WIDTH: float = 110.0
const CARD_GAP: float = 14.0

@onready var scroll_container: ScrollContainer = $MarginContainer/Content/ScrollContainer
@onready var prey_grid: GridContainer = $MarginContainer/Content/ScrollContainer/Cards/PreyGrid
@onready var predator_grid: GridContainer = $MarginContainer/Content/ScrollContainer/Cards/PredatorGrid


func _ready() -> void:
	_render_cards()
	scroll_container.resized.connect(_refresh_columns)
	call_deferred("_refresh_columns")


func _render_cards() -> void:
	_add_cards(prey_grid, Cards.PREY_IDS, PREY_KIND)
	_add_cards(predator_grid, Cards.PREDATOR_IDS, PREDATOR_KIND)


func _add_cards(grid: GridContainer, card_ids: Array[String], kind: String) -> void:
	for card_id in card_ids:
		var card_definition := Cards.get_by_id(card_id)
		if card_definition.is_empty():
			continue

		var card := CARD_SCENE.instantiate() as CardScene
		card.configure(
			kind,
			str(card_definition.get("suit", "")),
			int(card_definition.get("value", 0)),
			float(card_definition.get("scale", card.art_scale)),
			float(card_definition.get("rotation", card.art_rotation_degrees))
		)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		grid.add_child(card)


func _refresh_columns() -> void:
	var available_width := scroll_container.size.x
	var columns := maxi(1, int((available_width + CARD_GAP) / (CARD_WIDTH + CARD_GAP)))
	prey_grid.columns = columns
	predator_grid.columns = columns


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

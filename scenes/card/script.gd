extends Control
class_name CardScene

@export var kind: String = "prey"
@export var suit: String = "air"
@export var value: int = 4

var id: String:
	get:
		return get_card_id()

@onready var art: TextureRect = $Art


func _ready() -> void:
	_refresh_art()


func configure(next_kind: String, next_suit: String, next_value: int) -> void:
	kind = next_kind
	suit = next_suit
	value = next_value
	_refresh_art()


func get_card_id() -> String:
	return "%s_%s_%s" % [kind, suit, value]


func _refresh_art() -> void:
	if not is_node_ready():
		return

	art.texture = load(_get_asset_path()) as Texture2D


func _get_asset_path() -> String:
	# return "res://assets/%s.png" % get_card_id()
	return "res://assets/prey_%s_%s.png" % [suit, value]

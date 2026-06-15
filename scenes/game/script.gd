extends Node2D

const MAIN_MENU_SCENE: String = "res://scenes/main-menu/scene.tscn"
const GAME_SCENE: String = "res://scenes/game/scene.tscn"
const GAME_OVER_SCENE: String = "res://scenes/game-over/scene.tscn"
const HANDS_SCENE: PackedScene = preload("res://scenes/hands/scene.tscn")
const CARD_SCENE: PackedScene = preload("res://scenes/card/scene.tscn")
const CARD_KIND: String = "prey"
const CARD_MOVE_DURATION: float = 0.2
const CARD_MOVE_SCALE: Vector2 = Vector2(1.08, 1.08)
const CARD_MOVE_SCALE_DURATION: float = 0.08
const CARD_MOVE_LAYOUT_FRAMES: int = 3
const CARD_DRAW_MOVE_DURATION: float = 0.58
const CARD_DRAW_FLIP_DURATION: float = 0.24
const CARD_DRAW_STAGGER_DURATION: float = 0.08
const ROUND_DISCARD_MOVE_DURATION: float = 0.58
const ROUND_DISCARD_FLIP_DURATION: float = 0.24
const ROUND_DISCARD_STAGGER_DURATION: float = 0.06
const ROUND_PILE_SLIDE_DURATION: float = 0.28
const ROUND_RESULT_DELAY: float = 3.0
const SCORE_REVEAL_INTERVAL: float = 0.48
const SCORE_PANEL_SLIDE_DURATION: float = 0.18
const SCREEN_SHAKE_STEP_DURATION: float = 0.04
const SCREEN_SHAKE_STRENGTH: float = 12.0
const SUIT_ORDER: Array[String] = [Cards.SUIT_WATER, Cards.SUIT_LAND, Cards.SUIT_AIR]
const SCORE_LOWER_COLOR: Color = Color(0.86, 0.18, 0.14)
const SCORE_HIGHER_COLOR: Color = Color(0.33, 0.82, 0.32)
const SCORE_SUIT_COLORS: Dictionary = {
	Cards.SUIT_WATER: Color(111.0 / 255.0, 111.0 / 255.0, 175.0 / 255.0),
	Cards.SUIT_LAND: Color(126.0 / 255.0, 160.0 / 255.0, 118.0 / 255.0),
	Cards.SUIT_AIR: Color(171.0 / 255.0, 177.0 / 255.0, 188.0 / 255.0),
}
const TUTORIAL_STAGE_FINAL: int = 12
const TUTORIAL_SUIT_TEXT: String = "Flying prey gets away easier from Land predators. Land prey gets away easier from Water predators. Water prey gets away easier from Flying predators"

@onready var background_layer: CanvasLayer = $BackgroundLayer
@onready var ui_layer: CanvasLayer = $UI
@onready var pause_menu: Control = $UI/PauseMenu
@onready var predator_deck_container: Control = $UI/PredatorDeckContainer
@onready var play_button: Button = $UI/PlayButton
@onready var card_animation_layer: Control = $UI/CardAnimationLayer
@onready var predator_deck: PredatorDeck = $UI/PredatorDeckContainer/PredatorDeck
@onready var score_delta_label: Label = $UI/ScoreDeltaLabel
@onready var discard_pile: DiscardPile = $UI/PreyDeckContainer/DiscardPile
@onready var prey_deck_container: Control = $UI/PreyDeckContainer
@onready var prey_deck_center: Control = $UI/PreyDeckContainer/PreyDeckCenter
@onready var prey_deck: PreyDeck = $UI/PreyDeckContainer/PreyDeckCenter/PreyDeck
@onready var player_hand_deck_container: Control = $UI/PlayerHandDeckContainer
@onready var player_hand_deck: PlayerHandDeck = $UI/PlayerHandDeckContainer/PlayerHandDeck
@onready var prey_pile: PreyPile = $UI/PreyPile
@onready var predator_score_panel: Control = $UI/PredatorScorePanel
@onready var predator_hand_label: Label = $UI/PredatorScorePanel/Margin/Content/HandLabel
@onready var score_panel: Control = $UI/PreyDeckContainer/ScorePanel
@onready var hand_label: Label = $UI/PreyDeckContainer/ScorePanel/HeaderPanel/Margin/Content/HandLabel
@onready var suit_rows: VBoxContainer = $UI/PreyDeckContainer/ScorePanel/SuitRows
@onready var score_gain_row: HBoxContainer = $UI/PreyDeckContainer/ScorePanel/SuitRows/ScoreGainRow
@onready var score_gain_label: Label = $UI/PreyDeckContainer/ScorePanel/SuitRows/ScoreGainRow/ScoreGainLabel
@onready var water_row: Label = $UI/PreyDeckContainer/ScorePanel/SuitRows/Water/Score
@onready var land_row: Label = $UI/PreyDeckContainer/ScorePanel/SuitRows/Land/Score
@onready var air_row: Label = $UI/PreyDeckContainer/ScorePanel/SuitRows/Air/Score
@onready var suits_guide: TextureRect = $UI/SuitsGuide
@onready var hud_panel: Panel = $UI/HudPanel
@onready var health_label: Label = $UI/HudPanel/Margin/Content/HealthLabel
@onready var score_label: Label = $UI/HudPanel/Margin/Content/ScoreLabel

var _is_discard_animating: bool = false
var _is_round_resolving: bool = false
var _is_tutorial_mode: bool = false
var _is_tutorial_animating: bool = false
var _tutorial_allows_score_preview: bool = false
var _tutorial_stage: int = 0
var _tutorial_score_awarded: bool = false
var _tutorial_result: Dictionary = {}
var _tutorial_panel: Panel
var _tutorial_label: Label
var _tutorial_next_button: Button
var _tutorial_final_buttons: HBoxContainer
var _tutorial_main_menu_button: Button
var _tutorial_play_button: Button
var _hands_overlay: Control
var _prey_suit_scores: Dictionary = {}
var _predator_compare_scores: Dictionary = {}
var _screen_shake_tween: Tween


func _ready() -> void:
	_is_tutorial_mode = GameState.is_tutorial_active()
	AudioManager.set_menu_volume_ducked(false)
	AudioManager.play_game_music()
	play_button.pressed.connect(_on_play_pressed)
	player_hand_deck.card_move_animation_requested.connect(_on_player_hand_card_move_animation_requested)
	prey_deck.card_move_animation_requested.connect(_on_prey_card_move_animation_requested)
	discard_pile.hover_changed.connect(_on_discard_pile_hover_changed)
	discard_pile.clicked.connect(_on_discard_pile_clicked)
	GameState.score_changed.connect(_on_score_changed)
	GameState.health_changed.connect(_on_health_changed)
	GameState.predators_changed.connect(_on_predators_changed)
	GameState.player_table_changed.connect(_on_player_table_changed)
	GameState.player_cards_discarded.connect(_on_player_cards_discarded)
	_refresh_hud()
	if _is_tutorial_mode:
		call_deferred("_start_tutorial")
	else:
		_refresh_score_preview()
		_refresh_play_button()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_set_pause_menu_visible(not pause_menu.visible)


func _on_resume_pressed() -> void:
	_set_pause_menu_visible(false)


func _on_main_menu_pressed() -> void:
	GameState.set_game_active(false)
	GameState.set_tutorial_active(false)
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_restart_pressed() -> void:
	GameState.reset()
	if _is_tutorial_mode:
		GameState.set_tutorial_active(true)
	else:
		GameState.set_tutorial_active(false)
		GameState.go_next_round()
	get_tree().change_scene_to_file(GAME_SCENE)


func _on_combinations_pressed() -> void:
	if is_instance_valid(_hands_overlay):
		return

	_hands_overlay = HANDS_SCENE.instantiate() as Control
	_hands_overlay.z_index = 1002
	$UI.add_child(_hands_overlay)


func _set_pause_menu_visible(should_show: bool) -> void:
	pause_menu.visible = should_show
	AudioManager.set_menu_volume_ducked(should_show)


func _start_tutorial() -> void:
	_create_tutorial_panel()
	_set_input_available(false)
	_prepare_tutorial_board()
	await _show_tutorial_stage(0)


func _create_tutorial_panel() -> void:
	if _tutorial_panel:
		return

	_tutorial_panel = Panel.new()
	_tutorial_panel.name = "TutorialPanel"
	_tutorial_panel.z_index = 900
	_tutorial_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_tutorial_panel.anchor_left = 1.0
	_tutorial_panel.anchor_right = 1.0
	_tutorial_panel.offset_left = -660.0
	_tutorial_panel.offset_top = 24.0
	_tutorial_panel.offset_right = -156.0
	_tutorial_panel.offset_bottom = 178.0
	$UI.add_child(_tutorial_panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	_tutorial_panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	margin.add_child(content)

	_tutorial_label = Label.new()
	_tutorial_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tutorial_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tutorial_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tutorial_label.add_theme_font_size_override("font_size", 18)
	content.add_child(_tutorial_label)

	_tutorial_next_button = Button.new()
	_tutorial_next_button.text = "Next"
	_tutorial_next_button.custom_minimum_size = Vector2(120.0, 42.0)
	_tutorial_next_button.pressed.connect(_on_tutorial_next_pressed)
	content.add_child(_tutorial_next_button)

	_tutorial_final_buttons = HBoxContainer.new()
	_tutorial_final_buttons.visible = false
	_tutorial_final_buttons.add_theme_constant_override("separation", 12)
	content.add_child(_tutorial_final_buttons)

	_tutorial_main_menu_button = Button.new()
	_tutorial_main_menu_button.text = "Main Menu"
	_tutorial_main_menu_button.custom_minimum_size = Vector2(150.0, 42.0)
	_tutorial_main_menu_button.pressed.connect(_on_tutorial_main_menu_pressed)
	_tutorial_final_buttons.add_child(_tutorial_main_menu_button)

	_tutorial_play_button = Button.new()
	_tutorial_play_button.text = "Play"
	_tutorial_play_button.custom_minimum_size = Vector2(120.0, 42.0)
	_tutorial_play_button.pressed.connect(_on_tutorial_play_pressed)
	_tutorial_final_buttons.add_child(_tutorial_play_button)


func _prepare_tutorial_board() -> void:
	GameState.reset()
	_tutorial_stage = 0
	_tutorial_score_awarded = false
	_tutorial_result = {}
	_tutorial_allows_score_preview = false
	_is_round_resolving = false
	_is_discard_animating = false
	_set_tutorial_gameplay_visible(false)
	suits_guide.visible = true
	score_delta_label.visible = false
	_tutorial_next_button.visible = true
	_tutorial_next_button.disabled = false
	_tutorial_final_buttons.visible = false


func _set_tutorial_gameplay_visible(should_show: bool) -> void:
	predator_deck_container.visible = should_show
	predator_score_panel.visible = should_show
	prey_deck_container.visible = should_show
	prey_deck_center.visible = should_show
	score_panel.visible = false
	player_hand_deck_container.visible = should_show
	prey_pile.visible = should_show
	discard_pile.visible = should_show
	hud_panel.visible = should_show
	play_button.visible = false


func _on_tutorial_next_pressed() -> void:
	if _is_tutorial_animating or _tutorial_stage >= TUTORIAL_STAGE_FINAL:
		return

	_tutorial_stage += 1
	await _show_tutorial_stage(_tutorial_stage)


func _show_tutorial_stage(stage: int) -> void:
	_is_tutorial_animating = true
	_tutorial_next_button.disabled = true
	_set_tutorial_panel_stage(stage)

	match stage:
		0:
			_set_tutorial_text(TUTORIAL_SUIT_TEXT)
		1:
			predator_deck_container.visible = true
			GameState.set_predators(_get_tutorial_predators())
			_set_tutorial_text("Each round there will be some Predators hunting You.")
		2:
			predator_score_panel.visible = true
			_refresh_predator_raw_preview()
			_set_tutorial_text(
				"Each set of predators is a combination similar to Poker hands. You can see all available hands in menu (Esc)."
			)
		3:
			prey_pile.visible = true
			_set_tutorial_text("There are many Prey the Predators hunt.")
		4:
			player_hand_deck_container.visible = true
			await _show_tutorial_player_hand(_get_tutorial_first_hand())
			_set_tutorial_text(
				"Your goal is to build a combination that would manage to get away from Predators."
			)
		5:
			prey_deck_container.visible = true
			prey_deck_center.visible = false
			discard_pile.visible = true
			_set_tutorial_text("You can discard up to 5 cards twice each round")
		6:
			prey_deck_center.visible = true
			await _run_tutorial_discard_demo()
			_set_tutorial_text("now you can build a powerful combination")
		7:
			await _run_tutorial_play_cards()
			_set_tutorial_text("now you can build a powerful combination")
		8:
			_set_tutorial_text(
				"First, base values of each card are added to each type score. Sum of them gives your final 'Get Away Score'"
			)
			await _run_tutorial_base_score_step()
		9:
			_set_tutorial_text(
				"Those who get away easier against Predator types get x1.25 score, those who harder x0.75"
			)
			await _reveal_suit_matchup_steps(_tutorial_result)
		10:
			_set_tutorial_text("Finally, combination multiplier is applied")
			await _reveal_hand_multiplier_step(_tutorial_result)
		11:
			_show_tutorial_reward()
		12:
			_show_tutorial_finish()

	_is_tutorial_animating = false
	if stage < TUTORIAL_STAGE_FINAL:
		_tutorial_next_button.disabled = false


func _set_tutorial_text(text: String) -> void:
	_tutorial_label.text = text


func _set_tutorial_panel_stage(stage: int) -> void:
	match stage:
		0:
			_set_tutorial_panel_rect(1.0, 0.0, 1.0, 0.0, -660.0, 24.0, -156.0, 178.0)
		1, 2, 3:
			_set_tutorial_panel_rect(0.0, 1.0, 0.0, 1.0, 24.0, -184.0, 560.0, -24.0)
		4, 5:
			_set_tutorial_panel_rect(0.0, 0.0, 0.0, 0.0, 24.0, 232.0, 560.0, 388.0)
		8, 9, 10:
			_set_tutorial_panel_rect(0.0, 0.0, 0.0, 0.0, 252.0, 252.0, 700.0, 430.0)
		_:
			_set_tutorial_panel_rect(1.0, 0.0, 1.0, 0.0, -440.0, 24.0, -24.0, 210.0)


func _set_tutorial_panel_rect(
	anchor_left: float,
	anchor_top: float,
	anchor_right: float,
	anchor_bottom: float,
	offset_left: float,
	offset_top: float,
	offset_right: float,
	offset_bottom: float
) -> void:
	_tutorial_panel.anchor_left = anchor_left
	_tutorial_panel.anchor_top = anchor_top
	_tutorial_panel.anchor_right = anchor_right
	_tutorial_panel.anchor_bottom = anchor_bottom
	_tutorial_panel.offset_left = offset_left
	_tutorial_panel.offset_top = offset_top
	_tutorial_panel.offset_right = offset_right
	_tutorial_panel.offset_bottom = offset_bottom


func _get_tutorial_predators() -> Array:
	return _get_cards_by_ids(
		[
			"predator_water_3",
			"predator_land_3",
			"predator_air_3",
		]
	)


func _get_tutorial_first_hand() -> Array:
	return _get_cards_by_ids(
		[
			"prey_air_9",
			"prey_land_9",
			"prey_water_5",
			"prey_land_5",
			"prey_water_2",
			"prey_land_4",
			"prey_air_6",
			"prey_water_8",
		]
	)


func _get_tutorial_second_hand() -> Array:
	return _get_cards_by_ids(
		[
			"prey_air_9",
			"prey_land_9",
			"prey_water_5",
			"prey_land_5",
			"prey_water_8",
			"prey_land_7",
			"prey_air_10",
			"prey_land_11",
		]
	)


func _get_tutorial_final_hand() -> Array:
	return _get_cards_by_ids(
		[
			"prey_air_9",
			"prey_land_9",
			"prey_water_5",
			"prey_land_5",
			"prey_water_9",
			"prey_water_8",
			"prey_water_12",
			"prey_land_13",
		]
	)


func _show_tutorial_player_hand(cards: Array) -> void:
	GameState.set_player_hand(cards)
	await _draw_player_hand_cards_from_pile(cards)
	_set_input_available(false)


func _run_tutorial_discard_demo() -> void:
	await _tutorial_move_cards_to_table(["prey_water_2", "prey_land_4", "prey_air_6"])
	await get_tree().create_timer(1.0).timeout
	await _tutorial_discard_table_cards()
	GameState.set_player_hand(_get_tutorial_second_hand())
	await _draw_player_hand_cards_from_pile(
		_get_cards_by_ids(["prey_land_7", "prey_air_10", "prey_land_11"])
	)

	await _tutorial_move_cards_to_table(["prey_land_7", "prey_air_10", "prey_land_11"])
	await get_tree().create_timer(1.0).timeout
	await _tutorial_discard_table_cards()
	GameState.set_player_hand(_get_tutorial_final_hand())
	await _draw_player_hand_cards_from_pile(
		_get_cards_by_ids(["prey_water_9", "prey_water_12", "prey_land_13"])
	)
	_set_input_available(false)


func _run_tutorial_play_cards() -> void:
	play_button.visible = true
	play_button.disabled = false
	play_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tutorial_allows_score_preview = false
	await _tutorial_move_cards_to_table(
		["prey_air_9", "prey_land_9", "prey_water_9", "prey_water_5", "prey_land_5"]
	)
	_tutorial_allows_score_preview = true
	_refresh_score_preview()
	_set_input_available(false)
	play_button.visible = true
	play_button.disabled = false
	play_button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _run_tutorial_base_score_step() -> void:
	_tutorial_result = GameState.get_player_table_score_result()
	score_panel.visible = true
	predator_score_panel.visible = true
	_refresh_prey_hand_preview(_tutorial_result)
	_refresh_predator_score_preview(_tutorial_result)
	_reset_score_rows(_tutorial_result, true)
	_set_score_gain_visible(true, 0.0)
	score_delta_label.visible = false
	await _show_score_rows()
	await _reveal_prey_score_steps(_tutorial_result)


func _show_tutorial_reward() -> void:
	hud_panel.visible = true
	score_delta_label.visible = false
	var score_gain := int(roundf(float(_tutorial_result.get("score_gain", 0.0))))
	if not _tutorial_score_awarded:
		_tutorial_score_awarded = true
		GameState.change_score(score_gain)

	_set_tutorial_text(
		"Everybody got away! Predators won't get bloodlust and won't harm You. You get %s points."
		% score_gain
	)


func _show_tutorial_finish() -> void:
	_tutorial_next_button.visible = false
	_tutorial_final_buttons.visible = true
	_set_tutorial_text(
		"Every time predator bites some prey, they get bloodlust and bite You afterwards. If you lose your HP - you Die!"
	)


func _tutorial_move_cards_to_table(card_ids: Array) -> void:
	for card_id in card_ids:
		await _tutorial_move_card_to_table(str(card_id))


func _tutorial_move_card_to_table(card_id: String) -> void:
	var source_card := player_hand_deck.get_card_by_id(card_id)
	var from_global_position := Vector2.ZERO
	var from_rotation_degrees := 0.0
	if source_card:
		from_global_position = source_card.global_position
		from_rotation_degrees = source_card.rotation_degrees

	var result := GameState.move_card_from_player_hand_to_table(card_id)
	if result.is_empty():
		return

	if source_card:
		await _animate_card_move(result, from_global_position, from_rotation_degrees, prey_deck)
	else:
		await get_tree().process_frame

	_set_input_available(false)


func _tutorial_discard_table_cards() -> void:
	prey_deck.set_discard_hovered(true)
	await get_tree().create_timer(0.2).timeout

	var cards := _get_card_children(prey_deck)
	if cards.is_empty():
		prey_deck.set_discard_hovered(false)
		GameState.set_player_table([])
		return

	var move_tween: Tween
	var discard_global_position := discard_pile.get_drop_global_position()
	for index in range(cards.size()):
		var card := cards[index] as CardScene
		if not is_instance_valid(card):
			continue

		move_tween = card.tween_discard_to(
			discard_global_position,
			GameState.MAX_PLAYER_TABLE_CARDS + index,
			ROUND_DISCARD_MOVE_DURATION,
			ROUND_DISCARD_FLIP_DURATION
		)

		if index < cards.size() - 1:
			await get_tree().create_timer(ROUND_DISCARD_STAGGER_DURATION).timeout

	if move_tween:
		await move_tween.finished

	prey_deck.set_discard_hovered(false)
	GameState.set_player_table([])


func _get_cards_by_ids(card_ids: Array) -> Array:
	var cards := []
	for card_id in card_ids:
		var card := Cards.get_by_id(str(card_id))
		if not card.is_empty():
			cards.append(card)

	return cards


func _on_tutorial_main_menu_pressed() -> void:
	GameState.set_game_active(false)
	GameState.set_tutorial_active(false)
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_tutorial_play_pressed() -> void:
	GameState.set_game_active(true)
	GameState.set_tutorial_active(false)
	GameState.reset()
	GameState.go_next_round()
	get_tree().change_scene_to_file(GAME_SCENE)


func _refresh_hud() -> void:
	health_label.text = "HP %s" % GameState.get_health()
	score_label.text = "Score %s" % GameState.get_score()


func _refresh_score_preview() -> void:
	var result := GameState.get_player_table_score_result()
	score_delta_label.visible = false
	if GameState.get_player_table().is_empty():
		score_panel.visible = false
		_reset_score_rows(result)
		_set_score_gain_visible(false)
		_set_score_panel_row_count(score_panel, 0, false)
		_refresh_predator_raw_preview()
		score_delta_label.visible = false
		return

	score_panel.visible = true
	_refresh_prey_hand_preview(result)
	_refresh_predator_score_preview(result)


func _refresh_play_button() -> void:
	if _is_tutorial_mode:
		return

	play_button.disabled = _is_round_resolving or not GameState.can_resolve_player_table()


func _set_input_available(is_available: bool) -> void:
	play_button.disabled = not is_available or not GameState.can_resolve_player_table()
	prey_deck.set_cards_available(is_available)
	player_hand_deck.set_cards_available(is_available)
	discard_pile.mouse_filter = Control.MOUSE_FILTER_STOP if is_available else Control.MOUSE_FILTER_IGNORE


func _on_play_pressed() -> void:
	if _is_tutorial_mode:
		return

	if _is_round_resolving or not GameState.can_resolve_player_table():
		return

	_is_round_resolving = true
	_set_input_available(false)
	var result := GameState.get_player_table_score_result()
	var score_gain := int(roundf(float(result.get("score_gain", 0.0))))
	var damage := int(result.get("damage", 0))
	await _reveal_score_result(result)
	if damage > 0:
		AudioManager.play_predators_won()
	else:
		AudioManager.play_predators_lost()
	GameState.change_score(score_gain)
	GameState.change_health(-damage)
	_show_round_result_label(score_gain, damage)
	if damage > 0:
		await _shake_screen()
	await get_tree().create_timer(ROUND_RESULT_DELAY).timeout

	if GameState.get_health() <= 0:
		get_tree().change_scene_to_file(GAME_OVER_SCENE)
		return

	var previous_hand_card_ids := _get_card_ids(GameState.get_player_hand())
	await _slide_round_piles_in()
	await _animate_round_cards_to_discard()
	GameState.go_next_round()
	_set_input_available(false)
	await _draw_player_hand_cards_from_pile(
		_get_cards_without_ids(GameState.get_player_hand(), previous_hand_card_ids)
	)
	_is_round_resolving = false
	_set_input_available(true)
	_refresh_score_preview()
	_refresh_play_button()


func _reveal_score_result(result: Dictionary) -> void:
	score_panel.visible = true
	predator_score_panel.visible = true
	_refresh_prey_hand_preview(result)
	_refresh_predator_score_preview(result)
	_reset_score_rows(result, true)
	_set_score_gain_visible(true, 0.0)
	score_delta_label.visible = false
	await _show_score_rows()
	await _reveal_prey_score_steps(result)
	await _reveal_suit_matchup_steps(result)
	await _reveal_hand_multiplier_step(result)


func _refresh_prey_hand_preview(result: Dictionary) -> void:
	_set_prey_hand_score(result)
	_set_score_gain_visible(false)
	for suit in SUIT_ORDER:
		_set_prey_suit_score(suit, 0.0, false)

	suit_rows.visible = false
	suit_rows.modulate.a = 1.0
	_set_score_panel_row_count(score_panel, 0, false)


func _refresh_predator_raw_preview() -> void:
	var result := GameState.get_player_table_score_result()
	_set_predator_total_score(result, false)


func _reset_score_rows(_result: Dictionary, should_show: bool = false) -> void:
	for suit in SUIT_ORDER:
		_set_prey_suit_score(suit, 0.0, should_show)


func _show_score_rows() -> void:
	var row_count := _get_visible_suit_row_count()
	await _set_score_panel_row_count(score_panel, row_count, true)
	suit_rows.visible = true
	suit_rows.modulate.a = 0.0

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(suit_rows, "modulate:a", 1.0, SCORE_PANEL_SLIDE_DURATION)
	await tween.finished


func _set_score_panel_row_count(_panel: Control, _row_count: int, _animate: bool) -> void:
	pass


func _reveal_prey_score_steps(result: Dictionary) -> void:
	for step in result.get("card_steps", []):
		if not (step is Dictionary):
			continue

		var suit := str(step.get("suit", ""))
		var card_id := str(step.get("id", ""))
		await _pulse_prey_card(card_id)
		_set_prey_suit_score(suit, float(step.get("score_after", 0.0)), true)
		_set_score_gain_visible(true, _get_visible_prey_score_total())
		_show_score_change_label(suit, float(step.get("amount", 0.0)))
		await get_tree().create_timer(SCORE_REVEAL_INTERVAL).timeout


func _reveal_hand_multiplier_step(result: Dictionary) -> void:
	var suits: Dictionary = result.get("suits", {})
	await _pulse_scoring_hand_cards(result)
	_show_hand_multiplier_label(float(result.get("hand_multiplier", 1.0)))
	_set_prey_hand_score(result)

	for suit in SUIT_ORDER:
		var suit_result: Dictionary = suits.get(suit, {})
		if int(suit_result.get("prey_count", 0)) <= 0:
			continue

		_set_prey_suit_score(suit, float(suit_result.get("prey_score", 0.0)), true)

	_set_score_gain_visible(true, _get_visible_prey_score_total())
	await get_tree().create_timer(SCORE_REVEAL_INTERVAL).timeout


func _reveal_suit_matchup_steps(result: Dictionary) -> void:
	var suits: Dictionary = result.get("suits", {})
	for suit in SUIT_ORDER:
		var suit_result: Dictionary = suits.get(suit, {})
		if int(suit_result.get("prey_count", 0)) <= 0:
			continue

		await _pulse_suit_matchup_cards(result, suit)
		var base_prey_score := float(suit_result.get("base_prey_score", 0.0))
		var prey_matchup_score := float(suit_result.get("prey_matchup_score", 0.0))
		var matchup_amount := prey_matchup_score - base_prey_score
		_set_prey_suit_score(suit, prey_matchup_score, true)
		_set_score_gain_visible(true, _get_visible_prey_score_total())
		_show_score_change_label(suit, matchup_amount)
		await get_tree().create_timer(SCORE_REVEAL_INTERVAL).timeout


func _set_prey_hand_score(result: Dictionary) -> void:
	hand_label.text = "%s x%s" % [
		str(result.get("hand_label", "High Card")),
		_format_score(float(result.get("hand_multiplier", 1.0)))
	]


func _set_score_gain_visible(should_show: bool, score: float = 0.0) -> void:
	score_gain_row.visible = should_show
	if not should_show:
		return

	score_gain_label.text = "Score +%s" % _format_score(score)


func _get_visible_prey_score_total() -> float:
	var total := 0.0
	for suit in SUIT_ORDER:
		if _prey_suit_scores.has(suit):
			total += float(_prey_suit_scores[suit])

	return total


func _refresh_predator_score_preview(result: Dictionary) -> void:
	_set_predator_total_score(result, true)


func _set_predator_total_score(result: Dictionary, _compare_played_suits: bool) -> void:
	predator_score_panel.visible = true
	predator_hand_label.text = "%s %s" % [
		str(result.get("predator_hand_label", "High Card")),
		_format_score(float(result.get("predator_score", 0.0)))
	]

	for suit in SUIT_ORDER:
		_predator_compare_scores.erase(suit)

		_refresh_suit_score_color(suit)


func _pulse_prey_card(card_id: String) -> void:
	var card := prey_deck.get_card_by_id(card_id)
	if card:
		await card.pulse_highlight()
	else:
		await get_tree().create_timer(SCORE_REVEAL_INTERVAL).timeout


func _pulse_scoring_hand_cards(result: Dictionary) -> void:
	var first_card: CardScene

	for card in result.get("scoring_cards", []):
		if not (card is Dictionary):
			continue

		var prey_card := prey_deck.get_card_by_id(str(card.get("id", "")))
		if prey_card:
			if first_card:
				prey_card.pulse_highlight()
			else:
				first_card = prey_card

	if first_card:
		await first_card.pulse_highlight()


func _pulse_suit_matchup_cards(result: Dictionary, suit: String) -> void:
	var first_card: CardScene

	for card in result.get("scoring_cards", []):
		if not (card is Dictionary) or str(card.get("suit", "")) != suit:
			continue

		var prey_card := prey_deck.get_card_by_id(str(card.get("id", "")))
		if prey_card:
			if first_card:
				prey_card.pulse_highlight()
			else:
				first_card = prey_card

	for predator in GameState.get_predators():
		if not (predator is Dictionary):
			continue

		var predator_card := predator_deck.get_card_by_id(str(predator.get("id", "")))
		if predator_card:
			if first_card:
				predator_card.pulse_highlight()
			else:
				first_card = predator_card

	if first_card:
		await first_card.pulse_highlight()


func _set_prey_suit_score(suit: String, score: float, should_show: bool) -> void:
	var row := _get_suit_row(suit)
	row.visible = should_show
	row.get_parent().visible = should_show
	row.text = _format_score(score)
	if should_show:
		_prey_suit_scores[suit] = score
	else:
		_prey_suit_scores.erase(suit)

	_refresh_suit_score_color(suit)


func _refresh_suit_score_color(suit: String) -> void:
	var prey_row := _get_suit_row(suit)
	if (
		not prey_row.visible
		or not _prey_suit_scores.has(suit)
		or not _predator_compare_scores.has(suit)
	):
		_reset_suit_row_color(prey_row)
		return

	var prey_score := float(_prey_suit_scores[suit])
	var predator_score := float(_predator_compare_scores[suit])
	var color := _get_suit_score_color(suit) if prey_score >= predator_score else SCORE_LOWER_COLOR
	prey_row.add_theme_color_override("font_color", color)
	_refresh_score_delta_label(suit, prey_score, predator_score, color)


func _reset_suit_row_color(row: Label) -> void:
	row.remove_theme_color_override("font_color")


func _get_suit_score_color(suit: String) -> Color:
	return Color(SCORE_SUIT_COLORS.get(suit, Color.WHITE))


func _refresh_score_delta_label(
	suit: String, prey_score: float, predator_score: float, color: Color
) -> void:
	var delta := prey_score - predator_score
	var sign := "+" if delta >= 0.0 else ""
	score_delta_label.visible = true
	score_delta_label.text = "%s %s%s" % [_get_suit_label(suit), sign, _format_score(delta)]
	score_delta_label.add_theme_color_override("font_color", color)
	AudioManager.play_change_tick()


func _show_score_change_label(suit: String, amount: float) -> void:
	score_delta_label.visible = true
	var sign := "+" if amount >= 0.0 else ""
	score_delta_label.text = "%s %s%s" % [_get_suit_label(suit), sign, _format_score(amount)]
	score_delta_label.add_theme_color_override("font_color", _get_suit_score_color(suit))
	AudioManager.play_change_tick()


func _show_hand_multiplier_label(multiplier: float) -> void:
	score_delta_label.visible = true
	score_delta_label.text = "x%s" % _format_score(multiplier)
	score_delta_label.add_theme_color_override("font_color", Color.WHITE)
	AudioManager.play_change_tick()


func _show_round_result_label(score_gain: int, damage: int) -> void:
	score_delta_label.visible = true
	if damage > 0:
		score_delta_label.text = (
			"You got %s points. Predators got %s bloodlust and bit you!" % [score_gain, damage]
		)
		score_delta_label.add_theme_color_override("font_color", SCORE_LOWER_COLOR)
	else:
		score_delta_label.text = "All prey got away! You got %s points" % score_gain
		score_delta_label.add_theme_color_override("font_color", SCORE_HIGHER_COLOR)


func _shake_screen() -> void:
	if is_instance_valid(_screen_shake_tween):
		_screen_shake_tween.kill()

	var ui_offset := ui_layer.offset
	var background_offset := background_layer.offset
	var tween := create_tween()
	_screen_shake_tween = tween

	for index in range(8):
		var falloff := 1.0 - (float(index) / 8.0)
		var offset := (
			Vector2(
				randf_range(-SCREEN_SHAKE_STRENGTH, SCREEN_SHAKE_STRENGTH),
				randf_range(-SCREEN_SHAKE_STRENGTH, SCREEN_SHAKE_STRENGTH)
			)
			* falloff
		)
		tween.tween_property(ui_layer, "offset", ui_offset + offset, SCREEN_SHAKE_STEP_DURATION)
		tween.parallel().tween_property(
			background_layer, "offset", background_offset + (offset * 0.5), SCREEN_SHAKE_STEP_DURATION
		)

	tween.tween_property(ui_layer, "offset", ui_offset, SCREEN_SHAKE_STEP_DURATION)
	tween.parallel().tween_property(background_layer, "offset", background_offset, SCREEN_SHAKE_STEP_DURATION)
	await tween.finished
	if _screen_shake_tween == tween:
		_screen_shake_tween = null


func _get_suit_row(suit: String) -> Label:
	match suit:
		Cards.SUIT_WATER:
			return water_row
		Cards.SUIT_LAND:
			return land_row
		_:
			return air_row


func _get_visible_suit_row_count() -> int:
	var row_count := 0
	for suit in SUIT_ORDER:
		if _get_suit_row(suit).visible:
			row_count += 1

	return row_count


func _get_suit_label(suit: String) -> String:
	match suit:
		Cards.SUIT_WATER:
			return "Water"
		Cards.SUIT_LAND:
			return "Land"
		_:
			return "Air"


func _format_score(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))

	return "%.1f" % value


func _on_player_hand_card_move_animation_requested(
	card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float
) -> void:
	_animate_card_move(card, from_global_position, from_rotation_degrees, prey_deck)


func _on_prey_card_move_animation_requested(
	card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float
) -> void:
	_animate_card_move(card, from_global_position, from_rotation_degrees, player_hand_deck)


func _on_discard_pile_hover_changed(is_hovered: bool) -> void:
	if _is_discard_animating:
		return

	prey_deck.set_discard_hovered(is_hovered)


func _on_discard_pile_clicked() -> void:
	if _is_discard_animating:
		return

	_is_discard_animating = true
	await prey_deck.move_cards_to_discard(discard_pile.get_drop_global_position())
	_is_discard_animating = false


func _on_player_cards_discarded(
	_discarded_cards: Array, new_cards: Array, _player_discards_count: int
) -> void:
	await _draw_player_hand_cards_from_pile(new_cards)


func _on_score_changed(_score: int) -> void:
	_refresh_hud()


func _on_health_changed(_health: int) -> void:
	_refresh_hud()


func _on_predators_changed(_predators: Array) -> void:
	if _is_round_resolving:
		return

	if _is_tutorial_mode and not _tutorial_allows_score_preview:
		return

	_refresh_score_preview()


func _on_player_table_changed(_player_table: Array) -> void:
	if _is_round_resolving:
		return

	if _is_tutorial_mode and not _tutorial_allows_score_preview:
		return

	_refresh_score_preview()
	_refresh_play_button()


func _animate_card_move(
	card: Dictionary, from_global_position: Vector2, from_rotation_degrees: float, target_deck: Node
) -> void:
	var card_id := str(card.get("id", ""))
	var target_card := _get_target_card(target_deck, card_id)
	var target_modulate := Color.WHITE
	var target_mouse_filter := Control.MOUSE_FILTER_STOP
	if target_card:
		target_modulate = target_card.modulate
		target_mouse_filter = target_card.mouse_filter
		target_card.modulate.a = 0.0
		target_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var moving_card := CARD_SCENE.instantiate() as CardScene
	moving_card.configure(
		CARD_KIND,
		str(card.get("suit", "")),
		int(card.get("value", 0)),
		float(card.get("scale", moving_card.art_scale)),
		float(card.get("rotation", moving_card.art_rotation_degrees))
	)
	moving_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_add_moving_card(moving_card, target_deck, target_card)
	moving_card.pivot_offset = moving_card.size * 0.5
	moving_card.global_position = from_global_position
	moving_card.rotation_degrees = from_rotation_degrees

	for _frame_index in range(CARD_MOVE_LAYOUT_FRAMES):
		await get_tree().process_frame

		if not is_inside_tree():
			moving_card.queue_free()
			return

		moving_card.global_position = from_global_position
		moving_card.rotation_degrees = from_rotation_degrees

	var to_global_position := from_global_position
	var to_rotation_degrees := 0.0
	if is_instance_valid(target_card):
		to_global_position = target_card.global_position
		to_rotation_degrees = target_card.rotation_degrees

	var scale_tween := create_tween()
	scale_tween.set_trans(Tween.TRANS_SINE)
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(moving_card, "scale", CARD_MOVE_SCALE, CARD_MOVE_SCALE_DURATION)
	scale_tween.tween_property(
		moving_card, "scale", Vector2.ONE, CARD_MOVE_DURATION - CARD_MOVE_SCALE_DURATION
	)

	AudioManager.play_card_taken()
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(moving_card, "global_position", to_global_position, CARD_MOVE_DURATION)
	tween.parallel().tween_property(moving_card, "rotation_degrees", to_rotation_degrees, CARD_MOVE_DURATION)
	await tween.finished

	moving_card.queue_free()
	if is_instance_valid(target_card):
		target_card.modulate = target_modulate
		target_card.mouse_filter = target_mouse_filter


func _animate_round_cards_to_discard() -> void:
	var cards := _get_round_discard_cards()
	if cards.is_empty():
		return

	var move_tween: Tween
	var discard_global_position := discard_pile.get_drop_global_position()
	for index in range(cards.size()):
		var card := cards[index] as CardScene
		if not is_instance_valid(card):
			continue

		move_tween = card.tween_discard_to(
			discard_global_position,
			1000 + index,
			ROUND_DISCARD_MOVE_DURATION,
			ROUND_DISCARD_FLIP_DURATION
		)

		if index < cards.size() - 1:
			await get_tree().create_timer(ROUND_DISCARD_STAGGER_DURATION).timeout

	if move_tween:
		await move_tween.finished


func _slide_round_piles_in() -> void:
	var did_slide := discard_pile.slide_in_for_round_reset()
	did_slide = prey_pile.slide_in_for_round_reset() or did_slide
	if did_slide:
		await get_tree().create_timer(ROUND_PILE_SLIDE_DURATION).timeout


func _get_round_discard_cards() -> Array:
	var cards := []
	cards.append_array(_get_card_children(prey_deck))
	cards.append_array(_get_card_children(predator_deck))
	return cards


func _get_card_children(parent: Node) -> Array:
	var cards := []
	for child in parent.get_children():
		var card := child as CardScene
		if card:
			cards.append(card)

	return cards


func _draw_player_hand_cards_from_pile(cards: Array) -> void:
	var drawable_cards := _get_dictionary_cards(cards)
	if drawable_cards.is_empty():
		return

	prey_pile.begin_draw_animations()
	var target_states := _hide_player_hand_draw_targets(drawable_cards)
	var from_global_position := prey_pile.get_draw_global_position()
	for index in range(drawable_cards.size()):
		var card: Dictionary = drawable_cards[index]
		if index == drawable_cards.size() - 1:
			await _animate_card_draw_from_pile(card, from_global_position, target_states)
		else:
			_animate_card_draw_from_pile(card, from_global_position, target_states)

		if index < drawable_cards.size() - 1:
			await get_tree().create_timer(CARD_DRAW_STAGGER_DURATION).timeout

	prey_pile.end_draw_animations()


func _animate_card_draw_from_pile(
	card: Dictionary, from_global_position: Vector2, target_states: Dictionary = {}
) -> void:
	var card_id := str(card.get("id", ""))
	var target_card := _get_target_card(player_hand_deck, card_id)
	var target_modulate := Color.WHITE
	var target_mouse_filter := Control.MOUSE_FILTER_STOP
	if target_card:
		if target_states.has(card_id):
			var target_state = target_states[card_id]
			target_modulate = Color(target_state.get("modulate", target_card.modulate))
			target_mouse_filter = int(target_state.get("mouse_filter", target_card.mouse_filter))
		else:
			target_modulate = target_card.modulate
			target_mouse_filter = target_card.mouse_filter
			target_card.modulate.a = 0.0
			target_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var moving_card := CARD_SCENE.instantiate() as CardScene
	moving_card.configure(
		CARD_KIND,
		str(card.get("suit", "")),
		int(card.get("value", 0)),
		float(card.get("scale", moving_card.art_scale)),
		float(card.get("rotation", moving_card.art_rotation_degrees))
	)
	moving_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if is_instance_valid(target_card):
		player_hand_deck.add_child(moving_card)
		moving_card.z_index = target_card.z_index
	else:
		card_animation_layer.add_child(moving_card)
		moving_card.z_index = 1000

	moving_card.prepare_draw_from_pile(moving_card.z_index)
	moving_card.pivot_offset = moving_card.size * 0.5
	moving_card.global_position = from_global_position
	moving_card.rotation_degrees = 0.0

	for _frame_index in range(CARD_MOVE_LAYOUT_FRAMES):
		await get_tree().process_frame

		if not is_inside_tree():
			moving_card.queue_free()
			return

		moving_card.global_position = from_global_position
		moving_card.rotation_degrees = 0.0

	var to_global_position := from_global_position
	var to_rotation_degrees := 0.0
	var to_z_index := moving_card.z_index
	if is_instance_valid(target_card):
		to_global_position = target_card.global_position
		to_rotation_degrees = target_card.rotation_degrees
		to_z_index = target_card.z_index

	var tween := moving_card.tween_draw_to(
		to_global_position, to_rotation_degrees, to_z_index, CARD_DRAW_MOVE_DURATION, CARD_DRAW_FLIP_DURATION
	)
	await tween.finished

	moving_card.queue_free()
	if is_instance_valid(target_card):
		target_card.modulate = target_modulate
		target_card.mouse_filter = target_mouse_filter


func _hide_player_hand_draw_targets(cards: Array) -> Dictionary:
	var target_states := {}

	for card in cards:
		if not (card is Dictionary):
			continue

		var card_id := str(card.get("id", ""))
		if card_id.is_empty() or target_states.has(card_id):
			continue

		var target_card := _get_target_card(player_hand_deck, card_id)
		if not target_card:
			continue

		target_states[card_id] = {
			"modulate": Color.WHITE,
			"mouse_filter": target_card.mouse_filter,
		}
		target_card.modulate.a = 0.0
		target_card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	return target_states


func _get_card_ids(cards: Array) -> Dictionary:
	var card_ids := {}
	for card in cards:
		if card is Dictionary:
			card_ids[str(card.get("id", ""))] = true

	return card_ids


func _get_cards_without_ids(cards: Array, excluded_card_ids: Dictionary) -> Array:
	var next_cards := []
	for card in cards:
		if not (card is Dictionary):
			continue

		if excluded_card_ids.has(str(card.get("id", ""))):
			continue

		next_cards.append(card)

	return next_cards


func _get_dictionary_cards(cards: Array) -> Array:
	var dictionary_cards := []
	for card in cards:
		if card is Dictionary:
			dictionary_cards.append(card)

	return dictionary_cards


func _get_target_card(target_deck: Node, card_id: String) -> CardScene:
	if target_deck.has_method("get_card_by_id"):
		return target_deck.get_card_by_id(card_id) as CardScene

	return null


func _add_moving_card(moving_card: CardScene, target_deck: Node, target_card: CardScene) -> void:
	if target_deck == player_hand_deck and is_instance_valid(target_card):
		player_hand_deck.add_child(moving_card)
		moving_card.z_index = target_card.z_index
		return

	moving_card.z_index = 1000
	card_animation_layer.add_child(moving_card)

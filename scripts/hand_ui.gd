## Hand UI
## Displays cards in the player's hand and handles card selection
extends Control
class_name HandUI

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when a card is selected from the hand
signal card_selected(card: Card, hand_index: int)

## Emitted when trying to play a card that's too expensive
signal insufficient_memory(card: Card, cost: int, available: int)

# ============================================================================
# PROPERTIES
# ============================================================================

## The cards currently in this hand
var cards: Array = []

## Currently selected card index (-1 if none)
var selected_index: int = -1

## Reference to the player's available memory
var available_memory: int = 0

## Container for card displays
@onready var card_container: HBoxContainer = $CardContainer

# ============================================================================
# CARD DISPLAY
# ============================================================================

## Visual representation of a card in hand
class CardDisplay extends Control:
	var card: Card
	var index: int
	
	# Visual components
	var card_panel: Panel
	var artwork: TextureRect
	var name_label: Label
	var cost_label: Label
	var stats_label: Label
	var stage_label: Label
	var click_detector: Button
	
	func _init(c: Card, idx: int):
		card = c
		index = idx
		custom_minimum_size = Vector2(120, 180)
		
		# Create visual structure
		create_visuals()
		update_display()
	
	func create_visuals():
		# Background panel
		card_panel = Panel.new()
		card_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(card_panel)
		
		# Artwork
		artwork = TextureRect.new()
		artwork.position = Vector2(5, 25)
		artwork.size = Vector2(110, 110)
		artwork.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		add_child(artwork)
		
		# Card name
		name_label = Label.new()
		name_label.position = Vector2(5, 5)
		name_label.size = Vector2(110, 20)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.clip_text = true
		add_child(name_label)
		
		# Memory cost (top-right corner)
		cost_label = Label.new()
		cost_label.position = Vector2(90, 5)
		cost_label.size = Vector2(25, 20)
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_label.add_theme_font_size_override("font_size", 14)
		add_child(cost_label)
		
		# Stats (bottom)
		stats_label = Label.new()
		stats_label.position = Vector2(5, 140)
		stats_label.size = Vector2(110, 20)
		stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stats_label.add_theme_font_size_override("font_size", 13)
		add_child(stats_label)
		
		# Stage indicator
		stage_label = Label.new()
		stage_label.position = Vector2(5, 5)
		stage_label.size = Vector2(25, 20)
		stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stage_label.add_theme_font_size_override("font_size", 12)
		add_child(stage_label)
		
		# Invisible button for click detection
		click_detector = Button.new()
		click_detector.set_anchors_preset(Control.PRESET_FULL_RECT)
		click_detector.flat = true
		click_detector.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(click_detector)
	
	func update_display():
		if not is_node_ready():
			return
		
		# Set card name
		name_label.text = card.card_name
		
		# Set artwork if available
		if card.artwork:
			artwork.texture = card.artwork
		else:
			# Use a colored rectangle if no artwork
			artwork.modulate = card.get_system_color()
		
		# Set memory cost
		cost_label.text = str(card.memory_cost)
		cost_label.add_theme_color_override("font_color", Color.GOLD)
		
		# Set stats (Power/Health)
		stats_label.text = "%d / %d" % [card.power, card.health]
		
		# Set stage
		stage_label.text = "★%d" % card.stage
		
		# Set background color based on system
		var style = StyleBoxFlat.new()
		style.bg_color = card.get_system_color()
		style.border_width_all = 2
		style.border_color = Color.BLACK
		style.corner_radius_all = 5
		card_panel.add_theme_stylebox_override("panel", style)
	
	func set_affordable(can_afford: bool):
		if can_afford:
			modulate = Color.WHITE
		else:
			modulate = Color(0.6, 0.6, 0.6)
	
	func set_selected(is_selected: bool):
		if is_selected:
			var style = StyleBoxFlat.new()
			style.bg_color = card.get_system_color()
			style.border_width_all = 4
			style.border_color = Color.YELLOW
			style.corner_radius_all = 5
			card_panel.add_theme_stylebox_override("panel", style)
		else:
			var style = StyleBoxFlat.new()
			style.bg_color = card.get_system_color()
			style.border_width_all = 2
			style.border_color = Color.BLACK
			style.corner_radius_all = 5
			card_panel.add_theme_stylebox_override("panel", style)

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	if not card_container:
		card_container = HBoxContainer.new()
		card_container.name = "CardContainer"
		add_child(card_container)
	
	card_container.alignment = BoxContainer.ALIGNMENT_CENTER

# ============================================================================
# HAND MANAGEMENT
# ============================================================================

## Add a card to the hand
func add_card(card: Card) -> void:
	cards.append(card)
	refresh_display()

## Remove a card from the hand by index
func remove_card(index: int) -> Card:
	if index < 0 or index >= cards.size():
		return null
	
	var card = cards[index]
	cards.remove_at(index)
	
	# Deselect if this was selected
	if selected_index == index:
		selected_index = -1
	elif selected_index > index:
		selected_index -= 1
	
	refresh_display()
	return card

## Get the currently selected card
func get_selected_card() -> Card:
	if selected_index >= 0 and selected_index < cards.size():
		return cards[selected_index]
	return null

## Clear selection
func clear_selection() -> void:
	selected_index = -1
	refresh_display()

## Update available memory (affects card affordability display)
func set_available_memory(amount: int) -> void:
	available_memory = amount
	refresh_display()

# ============================================================================
# DISPLAY UPDATE
# ============================================================================

## Rebuild the entire hand display
func refresh_display() -> void:
	# Clear existing displays
	for child in card_container.get_children():
		child.queue_free()
	
	# Create new displays for each card
	for i in range(cards.size()):
		var card = cards[i]
		var display = CardDisplay.new(card, i)
		
		# Set affordability
		var can_afford = available_memory >= card.memory_cost
		display.set_affordable(can_afford)
		
		# Set selection
		display.set_selected(i == selected_index)
		
		# Connect click detector button
		display.click_detector.pressed.connect(_on_card_clicked.bind(i))
		
		# Add to container
		card_container.add_child(display)

# ============================================================================
# INPUT HANDLING
# ============================================================================

func _on_card_clicked(index: int) -> void:
	var card = cards[index]
	
	# Check if affordable
	if available_memory < card.memory_cost:
		insufficient_memory.emit(card, card.memory_cost, available_memory)
		return
	
	# Toggle selection
	if selected_index == index:
		selected_index = -1
	else:
		selected_index = index
	
	refresh_display()
	
	if selected_index >= 0:
		card_selected.emit(card, selected_index)
	else:
		card_selected.emit(null, -1)

# ============================================================================
# UTILITY
# ============================================================================

## Get number of cards in hand
func get_card_count() -> int:
	return cards.size()

## Check if hand is empty
func is_empty() -> bool:
	return cards.is_empty()

## Get all cards (for debugging/AI)
func get_all_cards() -> Array:
	return cards.duplicate()

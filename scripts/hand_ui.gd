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
class CardDisplay:
	var card: Card
	var button: Button
	var index: int
	
	func _init(c: Card, idx: int):
		card = c
		index = idx
		button = Button.new()
		button.custom_minimum_size = Vector2(100, 140)
		update_display()
	
	func update_display():
		var cost_color = "white"
		button.text = "%s\n[%d]\n%d/%d\nCost: %d" % [
			card.card_name,
			card.stage,
			card.power,
			card.health,
			card.memory_cost
		]
	
	func set_affordable(can_afford: bool):
		if can_afford:
			button.modulate = Color.WHITE
		else:
			button.modulate = Color(0.5, 0.5, 0.5)
	
	func set_selected(is_selected: bool):
		if is_selected:
			button.add_theme_color_override("font_color", Color.YELLOW)
		else:
			button.remove_theme_color_override("font_color")

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
		
		# Connect button
		display.button.pressed.connect(_on_card_clicked.bind(i))
		
		# Add to container
		card_container.add_child(display.button)

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

## Grid Slot
## Represents a single position on the 3x3 battle grid
## Each slot can hold one Unit card and one Install (equipment)
extends Node2D
class_name GridSlot

# ============================================================================
# SIGNALS - Events this slot can emit
# ============================================================================

## Emitted when a card is placed in this slot
signal card_placed(card: Card)

## Emitted when a card is removed from this slot
signal card_removed(card: Card)

## Emitted when this slot is clicked
signal slot_clicked(slot: GridSlot)

# ============================================================================
# GRID POSITION - Where this slot is located
# ============================================================================

## Which column (0, 1, 2) from left to right
@export var column: int = 0

## Which row (0=Front, 1=Middle, 2=Back)
@export var row: int = 0

## Which player owns this slot (0 or 1)
@export var owner_id: int = 0

# ============================================================================
# SLOT CONTENTS - What's currently in this slot
# ============================================================================

## The Unit card currently in this slot (null if empty)
var unit_card: Card = null

## The Install (equipment) attached to the unit (null if none)
var install_card: Card = null

## Is this unit exhausted (already attacked this turn)?
var is_exhausted: bool = false

## Does this unit have summoning sickness (can't attack on first turn)?
var has_summoning_sickness: bool = true

# ============================================================================
# VISUAL COMPONENTS - References to child nodes (set up in _ready)
# ============================================================================

## The visual background of the slot
@onready var background: ColorRect = $Background

## Displays the unit card
@onready var card_display: Sprite2D = $CardDisplay

## Shows stat information (power/health)
@onready var stats_label: Label = $StatsLabel

## Highlight effect when hovering or selecting
@onready var highlight: ColorRect = $Highlight

# ============================================================================
# SETUP
# ============================================================================

func _ready() -> void:
	# Connect mouse signals for interaction
	background.mouse_entered.connect(_on_mouse_entered)
	background.mouse_exited.connect(_on_mouse_exited)
	background.gui_input.connect(_on_gui_input)
	
	# Start with slot empty
	update_display()

# ============================================================================
# SLOT MANAGEMENT - Adding/removing cards
# ============================================================================

## Place a unit card in this slot
func place_unit(card: Card) -> bool:
	# Check if slot is already occupied
	if unit_card != null:
		push_error("Cannot place unit - slot already occupied")
		return false
	
	# Check if this is actually a unit card
	if card.card_type != Card.CardType.UNIT:
		push_error("Can only place Unit cards in grid slots")
		return false
	
	# Place the unit
	unit_card = card
	has_summoning_sickness = true
	is_exhausted = false
	
	# Update visuals
	update_display()
	
	# Notify listeners
	card_placed.emit(card)
	
	return true

## Remove the unit from this slot
func remove_unit() -> Card:
	var removed_card = unit_card
	unit_card = null
	install_card = null  # Remove equipment too
	
	update_display()
	
	if removed_card:
		card_removed.emit(removed_card)
	
	return removed_card

## Attach an Install (equipment) to the unit in this slot
func attach_install(card: Card) -> bool:
	# Check if there's a unit to attach to
	if unit_card == null:
		push_error("Cannot attach Install - no unit in slot")
		return false
	
	# Check if already has an Install (limit 1 per unit)
	if install_card != null:
		push_error("Unit already has an Install attached")
		return false
	
	# Check if this is actually an Install card
	if card.card_type != Card.CardType.INSTALL:
		push_error("Can only attach Install cards")
		return false
	
	install_card = card
	update_display()
	return true

# ============================================================================
# COMBAT FUNCTIONS
# ============================================================================

## Returns true if this unit can attack this turn
func can_attack() -> bool:
	if unit_card == null:
		return false
	if is_exhausted:
		return false
	if has_summoning_sickness and not unit_card.has_blitz:
		return false
	return true

## Mark this unit as having attacked (exhaust it)
func exhaust() -> void:
	is_exhausted = true
	update_display()

## Refresh this unit at start of turn
func refresh() -> void:
	is_exhausted = false
	has_summoning_sickness = false
	update_display()

## Deal damage to the unit in this slot
func take_damage(amount: int) -> void:
	if unit_card == null:
		return
	
	unit_card.take_damage(amount)
	update_display()
	
	# Check if unit is defeated
	if unit_card.is_defeated():
		remove_unit()

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

## Returns true if this slot has a unit
func is_occupied() -> bool:
	return unit_card != null

## Returns true if this is a front row slot (row 0)
func is_front_row() -> bool:
	return row == 0

## Returns true if this is a back row slot (row 2)
func is_back_row() -> bool:
	return row == 2

## Get total power (including Install bonuses)
func get_total_power() -> int:
	if unit_card == null:
		return 0
	var total = unit_card.power
	if install_card != null:
		total += install_card.power  # Installs can add power
	return total

## Get total health (including Install bonuses)
func get_total_health() -> int:
	if unit_card == null:
		return 0
	var total = unit_card.health
	if install_card != null:
		total += install_card.health  # Installs can add health
	return total

# ============================================================================
# VISUAL UPDATES
# ============================================================================

## Update the visual appearance of this slot
func update_display() -> void:
	if not is_node_ready():
		return
	
	if unit_card == null:
		# Empty slot
		card_display.visible = false
		stats_label.visible = false
		background.color = Color(0.2, 0.2, 0.2, 0.5)
	else:
		# Show unit
		card_display.visible = true
		stats_label.visible = true
		
		# Display card artwork if available
		if unit_card.artwork:
			card_display.texture = unit_card.artwork
		
		# Show power/health
		var current_hp = unit_card.get_current_health()
		stats_label.text = "%d / %d" % [get_total_power(), current_hp]
		
		# Color based on system
		background.color = unit_card.get_system_color()
		
		# Dim if exhausted
		if is_exhausted:
			card_display.modulate = Color(0.5, 0.5, 0.5)
		else:
			card_display.modulate = Color.WHITE

# ============================================================================
# INPUT HANDLING
# ============================================================================

func _on_mouse_entered() -> void:
	# Show highlight when hovering
	if highlight:
		highlight.visible = true

func _on_mouse_exited() -> void:
	# Hide highlight when not hovering
	if highlight:
		highlight.visible = false

func _on_gui_input(event: InputEvent) -> void:
	# Emit signal when slot is clicked
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			slot_clicked.emit(self)

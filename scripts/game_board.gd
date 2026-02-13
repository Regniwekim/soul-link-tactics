## Game Board
## This is the main controller for Soul-Link Tactics
## It manages the 3x3 grid, all zones, and game flow
extends Node2D
class_name GameBoard

# ============================================================================
# GAME STATE
# ============================================================================

## Which player's turn it is (0 or 1)
var current_player: int = 0

## Current phase of the turn
enum Phase {
	RECHARGE,  # Ready all units and memory
	DRAW,      # Draw cards
	MEMORY,    # Place memory
	MAIN,      # Deploy units, play cards
	BATTLE,    # Combat phase
	END        # End of turn effects
}

var current_phase: Phase = Phase.RECHARGE

## Player data structure
class PlayerData:
	var deck: Deck
	var hand_ui: HandUI
	var available_memory: int = 0
	var memory_cards: int = 0  # Total memory cards placed
	
	func _init():
		deck = Deck.new()

## Player 0's data
var player_0_data: PlayerData

## Player 1's data
var player_1_data: PlayerData

# Card placement mode
var placement_mode: bool = false
var card_to_place: Card = null
var card_hand_index: int = -1

# ============================================================================
# GRID STORAGE - The 3x3 battle grid for each player
# ============================================================================

## Player 0's grid slots [column][row]
## Example: player_0_grid[0][0] = front-left slot
## Example: player_0_grid[2][2] = back-right slot
var player_0_grid: Array = []

## Player 1's grid slots [column][row]
var player_1_grid: Array = []

# ============================================================================
# ZONE REFERENCES - Will be set up in _ready()
# ============================================================================

## Player 0's zones
@onready var p0_command_zone: Node2D = $Player0/CommandZone
@onready var p0_memory_zone: Node2D = $Player0/MemoryZone
@onready var p0_core_zone: Node2D = $Player0/CoreZone

## Player 1's zones
@onready var p1_command_zone: Node2D = $Player1/CommandZone
@onready var p1_memory_zone: Node2D = $Player1/MemoryZone
@onready var p1_core_zone: Node2D = $Player1/CoreZone

## The grid container
@onready var grid_container: Node2D = $GridContainer

## UI elements
@onready var phase_label: Label = $UI/PhaseLabel
@ontml:parameter name="turn_button: Button = $UI/NextPhaseButton
@onready var p0_hand_ui: HandUI = $UI/Player0Hand
@onready var p1_hand_ui: HandUI = $UI/Player1Hand
@onready var p0_memory_label: Label = $UI/Player0MemoryLabel
@onready var p1_memory_label: Label = $UI/Player1MemoryLabel
@onready var status_label: Label = $UI/StatusLabel

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Initialize player data
	player_0_data = PlayerData.new()
	player_1_data = PlayerData.new()
	
	# Create the 3x3 grid for both players
	setup_grid()
	
	# Setup hands
	setup_hands()
	
	# Start the game
	start_game()
	
	# Connect UI
	turn_button.pressed.connect(_on_next_phase_button_pressed)

## Creates the 3x3 grid structure for both players
func setup_grid() -> void:
	print("Setting up game grid...")
	
	# Constants for grid layout
	const COLUMNS = 3
	const ROWS = 3
	const SLOT_SIZE = 150  # Size of each slot in pixels
	const SLOT_SPACING = 10  # Space between slots
	
	# Initialize grid arrays
	player_0_grid = []
	player_1_grid = []
	
	# Create slots for both players
	for col in range(COLUMNS):
		# Create column arrays
		var p0_column = []
		var p1_column = []
		
		for row in range(ROWS):
			# Create Player 0's slot (bottom half of screen)
			var p0_slot = create_grid_slot(col, row, 0)
			p0_slot.position = Vector2(
				col * (SLOT_SIZE + SLOT_SPACING),
				row * (SLOT_SIZE + SLOT_SPACING)
			)
			grid_container.add_child(p0_slot)
			p0_column.append(p0_slot)
			
			# Create Player 1's slot (top half of screen, mirrored)
			var p1_slot = create_grid_slot(col, row, 1)
			p1_slot.position = Vector2(
				col * (SLOT_SIZE + SLOT_SPACING),
				-((2 - row) * (SLOT_SIZE + SLOT_SPACING) + SLOT_SIZE + 100)  # Flip and offset
			)
			grid_container.add_child(p1_slot)
			p1_column.append(p1_slot)
		
		player_0_grid.append(p0_column)
		player_1_grid.append(p1_column)
	
	# Center the grid on screen
	var grid_width = COLUMNS * (SLOT_SIZE + SLOT_SPACING) - SLOT_SPACING
	grid_container.position = Vector2(
		(get_viewport_rect().size.x - grid_width) / 2,
		get_viewport_rect().size.y / 2
	)
	
	print("Grid setup complete!")

## Setup hand UI and connect signals
func setup_hands() -> void:
	print("Setting up hands...")
	
	# Connect hand signals
	p0_hand_ui.card_selected.connect(_on_card_selected.bind(0))
	p0_hand_ui.insufficient_memory.connect(_on_insufficient_memory.bind(0))
	
	p1_hand_ui.card_selected.connect(_on_card_selected.bind(1))
	p1_hand_ui.insufficient_memory.connect(_on_insufficient_memory.bind(1))
	
	# Store hand references
	player_0_data.hand_ui = p0_hand_ui
	player_1_data.hand_ui = p1_hand_ui
	
	print("Hands setup complete!")

## Factory function to create a grid slot with all necessary components
func create_grid_slot(col: int, row: int, player_owner: int) -> GridSlot:
	# Create the slot node
	var slot = GridSlot.new()
	slot.column = col
	slot.row = row
	slot.owner_id = player_owner
	
	# Create visual components
	var background = ColorRect.new()
	background.name = "Background"
	background.size = Vector2(140, 140)
	background.color = Color(0.2, 0.2, 0.2, 0.5)
	background.mouse_filter = Control.MOUSE_FILTER_PASS
	slot.add_child(background)
	
	var card_display = Sprite2D.new()
	card_display.name = "CardDisplay"
	card_display.position = Vector2(70, 70)
	card_display.visible = false
	slot.add_child(card_display)
	
	var stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.position = Vector2(5, 110)
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.visible = false
	slot.add_child(stats_label)
	
	var highlight = ColorRect.new()
	highlight.name = "Highlight"
	highlight.size = Vector2(140, 140)
	highlight.color = Color(1, 1, 1, 0.3)
	highlight.visible = false
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(highlight)
	
	# Connect slot signals
	slot.slot_clicked.connect(_on_slot_clicked)
	
	return slot

# ============================================================================
# GAME FLOW
# ============================================================================

## Initialize a new game
func start_game() -> void:
	print("Starting Soul-Link Tactics!")
	current_player = 0
	current_phase = Phase.RECHARGE
	
	# Create test decks for both players
	create_test_decks()
	
	# Draw starting hands (5 cards each)
	for i in range(5):
		player_0_data.hand_ui.add_card(player_0_data.deck.draw_card())
		player_1_data.hand_ui.add_card(player_1_data.deck.draw_card())
	
	# Give starting memory
	player_0_data.memory_cards = 3
	player_0_data.available_memory = 3
	
	player_1_data.memory_cards = 3
	player_1_data.available_memory = 3
	
	update_ui()
	print("Game started! Draw 2 cards and play!")

## Progress to the next phase or next turn
func next_phase() -> void:
	match current_phase:
		Phase.RECHARGE:
			phase_recharge()
			current_phase = Phase.DRAW
		
		Phase.DRAW:
			phase_draw()
			current_phase = Phase.MEMORY
		
		Phase.MEMORY:
			# Allow player to place memory (handled by UI)
			current_phase = Phase.MAIN
		
		Phase.MAIN:
			# Main phase for playing cards
			current_phase = Phase.BATTLE
		
		Phase.BATTLE:
			phase_battle()
			current_phase = Phase.END
		
		Phase.END:
			phase_end()
			# Switch players
			current_player = 1 - current_player
			current_phase = Phase.RECHARGE
	
	update_ui()

## RECHARGE PHASE: Ready all units and memory
func phase_recharge() -> void:
	print("Recharge Phase - Player %d" % current_player)
	
	var grid = get_current_player_grid()
	var player_data = get_current_player_data()
	
	# Refresh all units
	for column in grid:
		for slot in column:
			slot.refresh()
	
	# Refresh memory
	player_data.available_memory = player_data.memory_cards
	print("Memory refreshed: %d/%d" % [player_data.available_memory, player_data.memory_cards])

## DRAW PHASE: Draw cards
func phase_draw() -> void:
	print("Draw Phase - Player %d" % current_player)
	
	var player_data = get_current_player_data()
	
	# Draw 2 cards
	for i in range(2):
		var card = player_data.deck.draw_card()
		if card:
			player_data.hand_ui.add_card(card)
			print("Drew: %s" % card.card_name)
		else:
			print("Deck is empty!")

## BATTLE PHASE: Process attacks
func phase_battle() -> void:
	print("Battle Phase - Player %d" % current_player)
	
	var attacker_grid = get_current_player_grid()
	var defender_grid = get_opponent_grid()
	
	# Process each column
	for col in range(3):
		var attacking_column = attacker_grid[col]
		var defending_column = defender_grid[col]
		
		# Find attacking units in this column
		for slot in attacking_column:
			if slot.is_occupied() and slot.can_attack():
				process_attack(slot, defending_column, col)

## END PHASE: Cleanup and end of turn effects
func phase_end() -> void:
	print("End Phase - Player %d" % current_player)
	# TODO: Trigger end-of-turn effects

# ============================================================================
# COMBAT SYSTEM
# ============================================================================

## Process an attack from one slot into a column
func process_attack(attacker_slot: GridSlot, defending_column: Array, column_index: int) -> void:
	var attacker = attacker_slot.unit_card
	if not attacker:
		return
	
	print("Unit attacking from column %d" % column_index)
	
	# Find the target based on attack type
	var target_slot = find_attack_target(attacker, defending_column)
	
	if target_slot and target_slot.is_occupied():
		# Unit vs Unit combat
		var damage = attacker_slot.get_total_power()
		print("Dealing %d damage to enemy unit" % damage)
		target_slot.take_damage(damage)
		
		# Simultaneous damage (defender hits back if still alive)
		if target_slot.is_occupied():
			var return_damage = target_slot.get_total_power()
			print("Taking %d return damage" % return_damage)
			attacker_slot.take_damage(return_damage)
	else:
		# Attack hits empty column - damage Firewall or Core
		print("Attack hits empty column - TODO: Damage Firewall/Core")
		# TODO: Implement Firewall and Core damage
	
	# Mark unit as exhausted
	attacker_slot.exhaust()

## Find the target for an attack based on attack type
func find_attack_target(attacker: Card, defending_column: Array) -> GridSlot:
	match attacker.attack_type:
		Card.AttackType.MELEE, Card.AttackType.RANGED:
			# Hits first enemy in column (front to back)
			for slot in defending_column:
				if slot.is_occupied():
					return slot
		
		Card.AttackType.FLYER, Card.AttackType.SNIPER:
			# Can target any unit - for now, target first found
			# TODO: Implement targeting system for player choice
			for slot in defending_column:
				if slot.is_occupied():
					return slot
	
	return null

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

## Get the current player's grid
func get_current_player_grid() -> Array:
	if current_player == 0:
		return player_0_grid
	else:
		return player_1_grid

## Get the opponent's grid
func get_opponent_grid() -> Array:
	if current_player == 0:
		return player_1_grid
	else:
		return player_0_grid

## Get a specific slot
func get_slot(player: int, column: int, row: int) -> GridSlot:
	if player == 0:
		return player_0_grid[column][row]
	else:
		return player_1_grid[column][row]

## Get current player's data
func get_current_player_data() -> PlayerData:
	if current_player == 0:
		return player_0_data
	else:
		return player_1_data

## Get opponent's data
func get_opponent_data() -> PlayerData:
	if current_player == 0:
		return player_1_data
	else:
		return player_0_data

# ============================================================================
# UI UPDATES
# ============================================================================

func update_ui() -> void:
	var phase_name = Phase.keys()[current_phase]
	phase_label.text = "Player %d - %s Phase" % [current_player + 1, phase_name]
	
	# Update memory labels
	p0_memory_label.text = "P1 Memory: %d/%d" % [player_0_data.available_memory, player_0_data.memory_cards]
	p1_memory_label.text = "P2 Memory: %d/%d" % [player_1_data.available_memory, player_1_data.memory_cards]
	
	# Update hand memory displays
	p0_hand_ui.set_available_memory(player_0_data.available_memory)
	p1_hand_ui.set_available_memory(player_1_data.available_memory)
	
	# Show/hide hands based on current player
	p0_hand_ui.visible = (current_player == 0)
	p1_hand_ui.visible = (current_player == 1)
	
	# Update status
	if placement_mode and card_to_place:
		status_label.text = "Click a slot to place: %s" % card_to_place.card_name
	else:
		status_label.text = "Select a card from your hand to play"

# ============================================================================
# INPUT HANDLERS
# ============================================================================

func _on_next_phase_button_pressed() -> void:
	next_phase()

## Called when a card is selected from hand
func _on_card_selected(card: Card, hand_index: int, player: int) -> void:
	if player != current_player:
		return
	
	if card == null:
		# Deselected
		placement_mode = false
		card_to_place = null
		card_hand_index = -1
		status_label.text = "Card deselected"
	else:
		# Selected a card
		placement_mode = true
		card_to_place = card
		card_hand_index = hand_index
		status_label.text = "Click a slot to place: %s (Cost: %d)" % [card.card_name, card.memory_cost]
	
	update_ui()

## Called when trying to select a card that's too expensive
func _on_insufficient_memory(card: Card, cost: int, available: int, player: int) -> void:
	if player != current_player:
		return
	
	status_label.text = "Not enough memory! Need %d, have %d" % [cost, available]
	print("Cannot afford %s - Need %d memory, have %d" % [card.card_name, cost, available])

func _on_slot_clicked(slot: GridSlot) -> void:
	print("Slot clicked: Column %d, Row %d, Owner %d" % [slot.column, slot.row, slot.owner_id])
	
	# Only allow interaction on your own grid during MAIN phase
	if current_phase != Phase.MAIN:
		print("Can only play cards during MAIN phase!")
		return
	
	if slot.owner_id != current_player:
		print("That's not your grid!")
		return
	
	# If we're in placement mode, try to place the card
	if placement_mode and card_to_place:
		if place_card_on_slot(slot):
			# Successfully placed - exit placement mode
			placement_mode = false
			card_to_place = null
			card_hand_index = -1
			get_current_player_data().hand_ui.clear_selection()
		update_ui()
	else:
		# Just inspecting a slot
		if slot.is_occupied():
			print("  Unit: %s (%d/%d)" % [slot.unit_card.card_name, 
										   slot.get_total_power(), 
										   slot.unit_card.get_current_health()])

## Try to place a card on a slot
func place_card_on_slot(slot: GridSlot) -> bool:
	if not card_to_place:
		return false
	
	# Check if slot is empty
	if slot.is_occupied():
		print("Slot already occupied!")
		status_label.text = "Slot already occupied!"
		return false
	
	var player_data = get_current_player_data()
	
	# Check if we can afford it
	if player_data.available_memory < card_to_place.memory_cost:
		print("Not enough memory!")
		status_label.text = "Not enough memory! Need %d, have %d" % [card_to_place.memory_cost, player_data.available_memory]
		return false
	
	# Place the card
	if slot.place_unit(card_to_place):
		# Pay the cost
		player_data.available_memory -= card_to_place.memory_cost
		
		# Remove from hand
		player_data.hand_ui.remove_card(card_hand_index)
		
		print("Placed %s! Memory: %d/%d" % [card_to_place.card_name, player_data.available_memory, player_data.memory_cards])
		status_label.text = "Placed %s!" % card_to_place.card_name
		
		update_ui()
		return true
	
	return false

# ============================================================================
# TEST / DEBUG FUNCTIONS
# ============================================================================

## Create test decks for both players
func create_test_decks() -> void:
	print("Creating test decks...")
	
	# Create a variety of test cards
	var test_cards_p0 = []
	var test_cards_p1 = []
	
	# Player 0 - INFERNO themed deck
	for i in range(10):
		var card = Card.new()
		card.card_name = "Fire Unit %d" % (i + 1)
		card.card_type = Card.CardType.UNIT
		card.systems = [Card.System.INFERNO]
		card.stage = 1 if i < 6 else 2
		card.memory_cost = 1 if i < 4 else (2 if i < 8 else 3)
		card.power = 1 + (i % 3)
		card.health = 2 + (i % 3)
		card.attack_type = Card.AttackType.MELEE
		test_cards_p0.append(card)
	
	# Player 1 - FLOW themed deck
	for i in range(10):
		var card = Card.new()
		card.card_name = "Water Unit %d" % (i + 1)
		card.card_type = Card.CardType.UNIT
		card.systems = [Card.System.FLOW]
		card.stage = 1 if i < 6 else 2
		card.memory_cost = 1 if i < 4 else (2 if i < 8 else 3)
		card.power = 1 + (i % 3)
		card.health = 2 + (i % 3)
		card.attack_type = Card.AttackType.RANGED if i % 2 == 0 else Card.AttackType.MELEE
		test_cards_p1.append(card)
	
	# Build decks
	player_0_data.deck.build_from_cards(test_cards_p0)
	player_0_data.deck.shuffle_deck()
	
	player_1_data.deck.build_from_cards(test_cards_p1)
	player_1_data.deck.shuffle_deck()
	
	print("Test decks created! P0: %d cards, P1: %d cards" % [
		player_0_data.deck.get_card_count(),
		player_1_data.deck.get_card_count()
	])

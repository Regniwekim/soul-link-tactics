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
@onready var turn_button: Button = $UI/NextPhaseButton

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Create the 3x3 grid for both players
	setup_grid()
	
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
	update_ui()
	
	# TODO: Initialize decks, draw starting hands, set up Core Files
	# For now, we'll create some test units
	create_test_units()

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
	
	# Refresh all units
	for column in grid:
		for slot in column:
			slot.refresh()

## DRAW PHASE: Draw cards
func phase_draw() -> void:
	print("Draw Phase - Player %d" % current_player)
	# TODO: Implement drawing from deck
	# For now, just announce the phase

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

# ============================================================================
# UI UPDATES
# ============================================================================

func update_ui() -> void:
	var phase_name = Phase.keys()[current_phase]
	phase_label.text = "Player %d - %s Phase" % [current_player + 1, phase_name]

# ============================================================================
# INPUT HANDLERS
# ============================================================================

func _on_next_phase_button_pressed() -> void:
	next_phase()

func _on_slot_clicked(slot: GridSlot) -> void:
	print("Slot clicked: Column %d, Row %d, Owner %d" % [slot.column, slot.row, slot.owner_id])
	if slot.is_occupied():
		print("  Unit: %s (%d/%d)" % [slot.unit_card.card_name, 
									   slot.get_total_power(), 
									   slot.unit_card.get_current_health()])

# ============================================================================
# TEST / DEBUG FUNCTIONS
# ============================================================================

## Create some test units to demonstrate the system
func create_test_units() -> void:
	print("Creating test units...")
	
	# Create a test INFERNO unit for Player 0
	var test_unit_1 = Card.new()
	test_unit_1.card_name = "Flame Drake"
	test_unit_1.card_type = Card.CardType.UNIT
	test_unit_1.systems = [Card.System.INFERNO]
	test_unit_1.power = 3
	test_unit_1.health = 4
	test_unit_1.attack_type = Card.AttackType.MELEE
	
	# Place it in front-left slot
	player_0_grid[0][0].place_unit(test_unit_1)
	
	# Create a test FLOW unit for Player 1
	var test_unit_2 = Card.new()
	test_unit_2.card_name = "Aqua Warrior"
	test_unit_2.card_type = Card.CardType.UNIT
	test_unit_2.systems = [Card.System.FLOW]
	test_unit_2.power = 2
	test_unit_2.health = 5
	test_unit_2.attack_type = Card.AttackType.RANGED
	
	# Place it in front-center slot
	player_1_grid[1][0].place_unit(test_unit_2)
	
	print("Test units created!")

## Card Database
## Loads and manages all card resources from the card_data folder
extends Node
class_name CardDatabase

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when all cards are loaded
signal cards_loaded(total_count: int)

# ============================================================================
# CARD STORAGE
# ============================================================================

## All loaded cards by system
var cards_by_system: Dictionary = {
	"inferno": [],
	"flow": [],
	"aero": [],
	"spark": [],
	"helix": [],
	"terra": [],
	"psy": [],
	"void": []
}

## All cards in one array
var all_cards: Array = []

## Cards by stage (for filtering)
var cards_by_stage: Dictionary = {
	1: [],
	2: [],
	3: []
}

# ============================================================================
# LOADING
# ============================================================================

## Load all card resources from the card_data folder
func load_all_cards() -> void:
	print("Loading cards from card_data folder...")
	
	var total_loaded = 0
	
	# Load from each system folder
	for system_name in cards_by_system.keys():
		var path = "res://resources/card_data/units/%s/" % system_name
		var cards_loaded = load_cards_from_folder(path, system_name)
		total_loaded += cards_loaded
		print("  Loaded %d %s cards" % [cards_loaded, system_name.to_upper()])
	
	# Build stage index
	index_cards_by_stage()
	
	print("Card loading complete! Total: %d cards" % total_loaded)
	cards_loaded.emit(total_loaded)

## Load all .tres files from a folder
func load_cards_from_folder(folder_path: String, system_name: String) -> int:
	var dir = DirAccess.open(folder_path)
	
	if not dir:
		print("  Warning: Could not open folder: %s" % folder_path)
		return 0
	
	var count = 0
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		# Only load .tres files
		if file_name.ends_with(".tres"):
			var full_path = folder_path + file_name
			var card = load(full_path)
			
			if card and card is Card:
				cards_by_system[system_name].append(card)
				all_cards.append(card)
				count += 1
			else:
				print("  Warning: Failed to load card: %s" % full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return count

## Index cards by stage for easier filtering
func index_cards_by_stage() -> void:
	for card in all_cards:
		if card.stage in cards_by_stage:
			cards_by_stage[card.stage].append(card)

# ============================================================================
# CARD RETRIEVAL
# ============================================================================

## Get all cards from a specific system
func get_cards_by_system(system_name: String) -> Array:
	if system_name in cards_by_system:
		return cards_by_system[system_name].duplicate()
	return []

## Get all cards of a specific stage
func get_cards_by_stage(stage: int) -> Array:
	if stage in cards_by_stage:
		return cards_by_stage[stage].duplicate()
	return []

## Get a random card from all cards
func get_random_card() -> Card:
	if all_cards.is_empty():
		return null
	return all_cards[randi() % all_cards.size()]

## Get random cards from a specific system
func get_random_cards_from_system(system_name: String, count: int) -> Array:
	var system_cards = get_cards_by_system(system_name)
	if system_cards.is_empty():
		return []
	
	system_cards.shuffle()
	return system_cards.slice(0, min(count, system_cards.size()))

## Get random cards from any system
func get_random_cards(count: int) -> Array:
	if all_cards.is_empty():
		return []
	
	var shuffled = all_cards.duplicate()
	shuffled.shuffle()
	return shuffled.slice(0, min(count, shuffled.size()))

## Build a balanced deck with mix of stages
func build_balanced_deck(system_name: String, deck_size: int = 30) -> Array:
	var deck = []
	var system_cards = get_cards_by_system(system_name)
	
	if system_cards.is_empty():
		print("Warning: No cards found for system: %s" % system_name)
		return []
	
	# Target distribution: 50% stage 1, 30% stage 2, 20% stage 3
	var stage_1_count = int(deck_size * 0.5)
	var stage_2_count = int(deck_size * 0.3)
	var stage_3_count = deck_size - stage_1_count - stage_2_count
	
	# Separate by stage
	var stage_1_cards = []
	var stage_2_cards = []
	var stage_3_cards = []
	
	for card in system_cards:
		match card.stage:
			1: stage_1_cards.append(card)
			2: stage_2_cards.append(card)
			3: stage_3_cards.append(card)
	
	# Add cards from each stage
	stage_1_cards.shuffle()
	stage_2_cards.shuffle()
	stage_3_cards.shuffle()
	
	for i in range(stage_1_count):
		if not stage_1_cards.is_empty():
			deck.append(stage_1_cards[i % stage_1_cards.size()])
	
	for i in range(stage_2_count):
		if not stage_2_cards.is_empty():
			deck.append(stage_2_cards[i % stage_2_cards.size()])
	
	for i in range(stage_3_count):
		if not stage_3_cards.is_empty():
			deck.append(stage_3_cards[i % stage_3_cards.size()])
	
	deck.shuffle()
	return deck

## Build a deck with multiple systems
func build_multi_system_deck(system_names: Array, deck_size: int = 30) -> Array:
	var deck = []
	var cards_per_system = deck_size / system_names.size()
	
	for system_name in system_names:
		var system_deck = build_balanced_deck(system_name, cards_per_system)
		deck.append_array(system_deck)
	
	deck.shuffle()
	return deck

# ============================================================================
# UTILITY
# ============================================================================

## Get total number of loaded cards
func get_total_card_count() -> int:
	return all_cards.size()

## Get count of cards in a system
func get_system_card_count(system_name: String) -> int:
	if system_name in cards_by_system:
		return cards_by_system[system_name].size()
	return 0

## Check if any cards are loaded
func has_cards() -> bool:
	return not all_cards.is_empty()

## Get list of all available systems
func get_available_systems() -> Array:
	var available = []
	for system_name in cards_by_system.keys():
		if not cards_by_system[system_name].is_empty():
			available.append(system_name)
	return available

## Print card database statistics
func print_stats() -> void:
	print("=== Card Database Statistics ===")
	print("Total cards: %d" % all_cards.size())
	print("\nBy System:")
	for system_name in cards_by_system.keys():
		var count = cards_by_system[system_name].size()
		if count > 0:
			print("  %s: %d cards" % [system_name.to_upper(), count])
	
	print("\nBy Stage:")
	for stage in [1, 2, 3]:
		if stage in cards_by_stage:
			print("  Stage %d: %d cards" % [stage, cards_by_stage[stage].size()])
	print("================================")

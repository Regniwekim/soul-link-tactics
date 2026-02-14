## Deck Configuration
## Simple configuration for choosing deck systems
extends Node
class_name DeckConfig

# ============================================================================
# CONFIGURATION
# ============================================================================

## Configuration for Player 0's deck
static var player_0_config = {
	"systems": ["inferno"],  # Can add multiple: ["inferno", "spark"]
	"deck_size": 30
}

## Configuration for Player 1's deck
static var player_1_config = {
	"systems": ["flow"],  # Can add multiple: ["flow", "aero"]
	"deck_size": 30
}

# ============================================================================
# HELPERS
# ============================================================================

## Get deck for a player using their config
static func build_deck_for_player(player_id: int, card_database: CardDatabase) -> Array:
	var config = player_0_config if player_id == 0 else player_1_config
	var systems = config["systems"]
	var deck_size = config["deck_size"]
	
	if systems.size() == 1:
		# Single system deck
		return card_database.build_balanced_deck(systems[0], deck_size)
	else:
		# Multi-system deck
		return card_database.build_multi_system_deck(systems, deck_size)

## Set player deck configuration
static func set_player_systems(player_id: int, systems: Array):
	if player_id == 0:
		player_0_config["systems"] = systems
	else:
		player_1_config["systems"] = systems

## Set deck size for a player
static func set_player_deck_size(player_id: int, size: int):
	if player_id == 0:
		player_0_config["deck_size"] = size
	else:
		player_1_config["deck_size"] = size

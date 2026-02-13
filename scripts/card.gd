## Base Card Class
## This is the foundation for all card types in Soul-Link Tactics
## All specific card types (Unit, Linker, Item, etc.) will extend this class
extends Resource
class_name Card

# ============================================================================
# ENUMS - These define the possible values for card properties
# ============================================================================

## The eight factions/systems from your GDD
enum System {
	INFERNO,   # Vermilion - Fire/Dragon
	FLOW,      # Dark Blue - Water/Fighting
	AERO,      # Sky Blue - Flying/Ice
	SPARK,     # Yellow - Electric/Steel
	HELIX,     # Teal - Grass/Bug/Poison
	TERRA,     # Orange - Ground/Rock
	PSY,       # Magenta - Psychic/Fairy
	VOID       # Charcoal - Ghost/Dark
}

## Different types of cards in the game
enum CardType {
	LINKER,    # Commander card (stays in Command Zone)
	UNIT,      # Monsters that fight on the grid
	INSTALL,   # Equipment attached to units
	FIREWALL,  # Defensive structures in columns
	ITEM,      # Single-use spells
	TRAP       # Face-down triggered effects
}

## Attack types determine how a unit can attack on the grid
enum AttackType {
	MELEE,     # Front row only, hits first enemy in column
	RANGED,    # Any row, hits first enemy in column
	FLYER,     # Any row, can target any unit in column
	SNIPER     # Back row only, can target any unit in column
}

# ============================================================================
# BASIC CARD PROPERTIES - Every card has these
# ============================================================================

## The card's name (e.g., "Blazewing Dragon")
@export var card_name: String = ""

## Which system(s) this card belongs to
@export var systems: Array = []

## What type of card this is
@export var card_type: CardType = CardType.UNIT

## How much Memory it costs to play this card
@export var memory_cost: int = 0

## The card's description/flavor text
@export var description: String = ""

## Visual representation of the card
@export var artwork: Texture2D

# ============================================================================
# UNIT-SPECIFIC PROPERTIES - Only used by Unit cards
# ============================================================================

## Unit's attack power
@export var power: int = 0

## Unit's health points
@export var health: int = 0

## Current damage on this unit (tracked during battle)
var current_damage: int = 0

## The unit's evolution stage (level)
@export var stage: int = 1

## How this unit attacks
@export var attack_type: AttackType = AttackType.MELEE

# ============================================================================
# KEYWORDS - Special abilities cards can have
# ============================================================================

## Triggers when the card is first played
@export var on_play_effect: String = ""

## Triggers when a unit evolves onto this card
@export var on_evo_effect: String = ""

## Triggers when revealed from Core Files (HP damage)
@export var burst_effect: String = ""

## Can this unit block attacks to units behind it?
@export var has_blocker: bool = false

## Can this unit attack/activate the turn it's played?
@export var has_blitz: bool = false

## Does excess damage pierce through to units behind?
@export var has_piercing: bool = false

## Can't be targeted while in back row?
@export var has_stealth: bool = false

# ============================================================================
# LINKER-SPECIFIC PROPERTIES - Only used by Linker cards
# ============================================================================

## How many trap slots this Linker has
@export var trap_slots: int = 2

## Condition for gaining Sync Points (e.g., "Gain 1 Sync when you Evolve")
@export var sync_condition: String = ""

## Current Sync Points accumulated
var current_sync: int = 0

## The Linker's Ultimate ability description
@export var sync_override_effect: String = ""

## Cost in Sync Points to activate Ultimate
@export var sync_override_cost: int = 5

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

## Returns the current HP of a unit (max HP - damage taken)
func get_current_health() -> int:
	return health - current_damage

## Returns true if this unit is defeated
func is_defeated() -> bool:
	return current_damage >= health

## Heal damage on this unit (used when evolving)
func heal(amount: int) -> void:
	current_damage = max(0, current_damage - amount)

## Deal damage to this unit
func take_damage(amount: int) -> void:
	current_damage += amount

## Get the color associated with this card's primary system
func get_system_color() -> Color:
	if systems.is_empty():
		return Color.WHITE
	
	# Returns colors from Wong/Okabe-Ito Palette for color-blind accessibility
	match systems[0]:
		System.INFERNO:
			return Color.from_string("#E64B35", Color.RED)  # Vermilion
		System.FLOW:
			return Color.from_string("#00468B", Color.BLUE)  # Dark Blue
		System.AERO:
			return Color.from_string("#42B4E6", Color.CYAN)  # Sky Blue
		System.SPARK:
			return Color.from_string("#F2B134", Color.YELLOW)  # Yellow
		System.HELIX:
			return Color.from_string("#009F87", Color.GREEN)  # Teal
		System.TERRA:
			return Color.from_string("#F39B7F", Color.ORANGE)  # Orange
		System.PSY:
			return Color.from_string("#BC5090", Color.MAGENTA)  # Magenta
		System.VOID:
			return Color.from_string("#4A4A4A", Color.DIM_GRAY)  # Charcoal
		_:
			return Color.WHITE

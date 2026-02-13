## Deck
## Manages a deck of cards with draw and shuffle functionality
extends Node
class_name Deck

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when trying to draw from an empty deck
signal deck_empty()

# ============================================================================
# PROPERTIES
# ============================================================================

## Cards remaining in the deck
var cards: Array = []

## Cards that have been drawn (discard pile)
var discard_pile: Array = []

# ============================================================================
# DECK BUILDING
# ============================================================================

## Create a deck from an array of cards
func build_from_cards(card_array: Array) -> void:
	cards = card_array.duplicate()
	discard_pile.clear()

## Add a single card to the deck
func add_card(card: Card) -> void:
	cards.append(card)

## Shuffle the deck
func shuffle_deck() -> void:
	cards.shuffle()

# ============================================================================
# DRAWING CARDS
# ============================================================================

## Draw a card from the top of the deck
func draw_card() -> Card:
	if cards.is_empty():
		# Try to reshuffle discard pile
		if not discard_pile.is_empty():
			print("Deck empty! Reshuffling discard pile...")
			cards = discard_pile.duplicate()
			discard_pile.clear()
			shuffle_deck()
		else:
			deck_empty.emit()
			return null
	
	return cards.pop_front()

## Draw multiple cards
func draw_cards(amount: int) -> Array:
	var drawn = []
	for i in range(amount):
		var card = draw_card()
		if card:
			drawn.append(card)
		else:
			break
	return drawn

# ============================================================================
# DISCARD
# ============================================================================

## Add a card to the discard pile
func discard_card(card: Card) -> void:
	discard_pile.append(card)

# ============================================================================
# UTILITY
# ============================================================================

## Get number of cards remaining
func get_card_count() -> int:
	return cards.size()

## Get total cards (deck + discard)
func get_total_cards() -> int:
	return cards.size() + discard_pile.size()

## Check if deck is empty
func is_empty() -> bool:
	return cards.is_empty()

## Peek at top card without drawing
func peek_top() -> Card:
	if cards.is_empty():
		return null
	return cards[0]

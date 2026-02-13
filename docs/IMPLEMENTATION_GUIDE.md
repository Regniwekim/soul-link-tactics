# Soul-Link Tactics - Implementation Guide

## Quick Reference for Core Mechanics

This guide helps you understand how to implement the remaining features from the GDD.

---

## Turn Structure Implementation

### Current State: ✅ Basic structure exists
### What's Left: Flesh out each phase

```gdscript
# RECHARGE PHASE - ✅ DONE
# - Ready all exhausted units (already implemented)
# - Ready all Memory cards (TODO: implement Memory)

# DRAW PHASE - ⚠️ NEEDS IMPLEMENTATION
# - Draw 2 cards from deck
# - Add them to hand
func phase_draw():
    for i in range(2):
        var card = deck.draw_card()
        hand.add_card(card)

# MEMORY PHASE - ⚠️ NEEDS IMPLEMENTATION  
# - Player may place 1 card face-down as Memory
func place_as_memory(card: Card):
    memory_zone.add_card(card)
    hand.remove_card(card)
    available_memory += 1

# MAIN PHASE - ⚠️ NEEDS IMPLEMENTATION
# - Alternating actions between players
# - Pay Memory to deploy/evolve/install/etc.
func can_afford(cost: int) -> bool:
    return available_memory >= cost

func play_card(card: Card) -> bool:
    if can_afford(card.memory_cost):
        available_memory -= card.memory_cost
        # Execute card effect
        return true
    return false

# BATTLE PHASE - ✅ MOSTLY DONE
# - Units attack (already implemented)
# - TODO: Add Firewall damage
# - TODO: Add Core Files reveal

# END PHASE - ⚠️ NEEDS IMPLEMENTATION
# - Trigger "End of turn" effects
# - Clean up temporary buffs
```

---

## Combat System Details

### Unit vs Unit Combat: ✅ DONE

Current implementation handles:
- Simultaneous damage
- Damage persistence
- Unit defeat

### Empty Column Attack: ⚠️ NEEDS IMPLEMENTATION

```gdscript
func attack_empty_column(damage: int, column: int, defender_player: int):
    # Check for Firewall
    var firewall = get_firewall(defender_player, column)
    
    if firewall:
        # Damage the firewall
        firewall.take_damage(damage)
        if firewall.is_destroyed():
            remove_firewall(defender_player, column)
    else:
        # Hit Core Files (HP)
        var revealed_card = reveal_core_file(defender_player)
        
        # Check for BURST effect
        if revealed_card.burst_effect:
            execute_burst(revealed_card)
        
        # Add card to hand
        add_to_hand(defender_player, revealed_card)
        
        # Check for defeat
        if get_core_count(defender_player) == 0:
            player_defeated(defender_player)
```

### Attack Types Implementation

```gdscript
# MELEE - Front row only, hits first enemy
# RANGED - Any row, hits first enemy
# Current implementation: ✅ DONE

# FLYER - Any row, can choose any unit (skips Blocker)
# SNIPER - Back row only, can choose any unit
# Current implementation: ⚠️ Targets first found, needs player choice UI

func find_attack_target_with_choice(attacker: Card, column: Array) -> GridSlot:
    if attacker.attack_type in [Card.AttackType.FLYER, Card.AttackType.SNIPER]:
        # Show targeting UI
        var valid_targets = []
        for slot in column:
            if slot.is_occupied():
                valid_targets.append(slot)
        
        # Let player choose
        return await show_target_selection(valid_targets)
    else:
        # Auto-target first unit (current implementation)
        return find_first_occupied(column)
```

---

## Firewall System

### Structure

```gdscript
class_name Firewall extends Node2D

var health: int = 5
var current_damage: int = 0
var column: int = 0
var owner: int = 0

# Lane Buff - affects all units in this column
var lane_buff_power: int = 0
var lane_buff_health: int = 0

func take_damage(amount: int):
    current_damage += amount
    if is_destroyed():
        queue_free()  # Remove from game

func is_destroyed() -> bool:
    return current_damage >= health

func apply_lane_buff(unit: Card):
    unit.power += lane_buff_power
    unit.health += lane_buff_health
```

### Integration with Game Board

```gdscript
# In GameBoard class:
var player_0_firewalls: Array = [null, null, null]  # One per column
var player_1_firewalls: Array = [null, null, null]

func place_firewall(player: int, column: int, firewall: Firewall):
    if player == 0:
        player_0_firewalls[column] = firewall
    else:
        player_1_firewalls[column] = firewall

func get_firewall(player: int, column: int) -> Firewall:
    if player == 0:
        return player_0_firewalls[column]
    else:
        return player_1_firewalls[column]
```

---

## Core Files (HP System)

### Setup

```gdscript
class PlayerData:
    var core_files: Array[Card] = []  # 5 cards, face-down
    var revealed_cards: Array[Card] = []
    
    func setup_core_files(deck: Array[Card]):
        for i in range(5):
            core_files.append(deck.pop_front())
    
    func reveal_core_file() -> Card:
        if core_files.is_empty():
            return null
        
        var revealed = core_files.pop_front()
        revealed_cards.append(revealed)
        return revealed
    
    func get_core_count() -> int:
        return core_files.size()
    
    func is_defeated() -> bool:
        return core_files.is_empty()
```

### BURST Effect

```gdscript
func execute_burst(card: Card):
    if card.burst_effect.is_empty():
        return
    
    print("BURST! %s" % card.burst_effect)
    
    # Parse and execute the effect
    # Example effects:
    # - "Draw 2 cards"
    # - "Destroy all units in front row"
    # - "Gain 3 Memory"
    
    match card.burst_effect:
        "draw_2":
            for i in range(2):
                draw_card()
        "destroy_front_row":
            destroy_front_row_units()
        # Add more as needed
```

---

## Linker System (Commander)

### Linker Card Setup

```gdscript
class LinkerCard extends Card:
    var trap_slots_available: int
    var trap_slots_used: int = 0
    var set_traps: Array[Card] = []
    
    func can_set_trap() -> bool:
        return trap_slots_used < trap_slots_available
    
    func set_trap(trap_card: Card) -> bool:
        if not can_set_trap():
            return false
        
        set_traps.append(trap_card)
        trap_slots_used += 1
        return true
```

### Sync Gauge System

```gdscript
class PlayerData:
    var linker: Card
    var sync_points: int = 0
    
    func check_sync_condition(event: String, data: Dictionary):
        # Example: "Gain 1 Sync when you Evolve"
        if linker.sync_condition == "on_evolve" and event == "unit_evolved":
            gain_sync(1)
        
        # Example: "Gain 1 Sync when a unit is destroyed"
        if linker.sync_condition == "on_unit_destroyed" and event == "unit_destroyed":
            gain_sync(1)
    
    func gain_sync(amount: int):
        sync_points += amount
        print("Sync +%d (Total: %d)" % [amount, sync_points])
    
    func can_use_ultimate() -> bool:
        return sync_points >= linker.sync_override_cost
    
    func use_ultimate():
        if not can_use_ultimate():
            return
        
        sync_points -= linker.sync_override_cost
        execute_ultimate_effect(linker.sync_override_effect)
```

---

## Trap System

### Trap Card

```gdscript
class TrapCard extends Card:
    var trigger_condition: String  # e.g., "when_attacked", "when_unit_played"
    var trigger_cost: int = 0  # Memory needed to activate
    
    func check_trigger(event: String, context: Dictionary) -> bool:
        # Check if this trap should trigger
        match trigger_condition:
            "when_attacked":
                return event == "unit_attacked"
            "when_unit_played":
                return event == "unit_played"
            "on_damage":
                return event == "player_damaged"
        return false
```

### Trap Integration

```gdscript
func set_trap(trap_card: Card, memory_cost: int = 2):
    if available_memory < memory_cost:
        return false
    
    available_memory -= memory_cost
    current_player_data.linker.set_trap(trap_card)
    hand.remove_card(trap_card)
    return true

func check_traps(event: String, context: Dictionary):
    for trap in current_player_data.linker.set_traps:
        if trap.check_trigger(event, context):
            # Ask player if they want to activate
            if await ask_activate_trap(trap):
                activate_trap(trap, context)

func activate_trap(trap: Card, context: Dictionary):
    if available_memory < trap.trigger_cost:
        print("Not enough memory to activate trap!")
        return
    
    available_memory -= trap.trigger_cost
    execute_trap_effect(trap, context)
    current_player_data.linker.set_traps.erase(trap)
```

---

## Evolution System

```gdscript
func evolve_unit(base_slot: GridSlot, evo_card: Card) -> bool:
    if not base_slot.is_occupied():
        return false
    
    var base_unit = base_slot.unit_card
    
    # Check if evolution is valid
    if evo_card.stage <= base_unit.stage:
        print("Can only evolve to higher stage!")
        return false
    
    # Evolution benefits:
    # 1. Heals all damage
    base_unit.current_damage = 0
    
    # 2. Removes summoning sickness
    base_slot.has_summoning_sickness = false
    
    # 3. Trigger [On Play] effect of evolution
    if evo_card.on_play_effect:
        execute_effect(evo_card.on_play_effect)
    
    # 4. Replace with new card
    base_slot.unit_card = evo_card
    base_slot.update_display()
    
    # 5. Trigger Sync condition
    emit_event("unit_evolved", {"slot": base_slot, "card": evo_card})
    
    return true
```

---

## Memory System (Resource Management)

### Basic Implementation

```gdscript
class PlayerData:
    var memory_cards: Array[Card] = []  # Face-down cards used as resources
    var available_memory: int = 0
    
    func ready_memory():
        available_memory = memory_cards.size()
    
    func place_memory(card: Card):
        memory_cards.append(card)
        # Immediately available (no "tapping")
        available_memory += 1
    
    func spend_memory(amount: int) -> bool:
        if available_memory < amount:
            return false
        available_memory -= amount
        return true
```

### "Any Card is a Resource"

Key benefit: No mana screw! Players can always play cards as memory.

```gdscript
# In the UI, every card in hand should have two options:
# 1. "Play" - Play the card normally (costs memory)
# 2. "Memory" - Place face-down as memory (always available)

func on_card_right_clicked(card: Card):
    show_card_menu(card, [
        {"label": "Play", "action": func(): play_card(card)},
        {"label": "Place as Memory", "action": func(): place_as_memory(card)}
    ])
```

---

## Keyword Effects Reference

```gdscript
# BLOCKER - Must be attacked first in column
func find_attack_target(column: Array) -> GridSlot:
    # First, check for Blockers
    for slot in column:
        if slot.is_occupied() and slot.unit_card.has_blocker:
            return slot
    
    # Then normal targeting
    return find_first_occupied(column)

# BLITZ - Can attack immediately
# Already implemented via has_summoning_sickness check

# PIERCING - Excess damage hits unit behind
func apply_piercing_damage(attacker_slot: GridSlot, defender_slot: GridSlot, damage: int):
    var defender_hp = defender_slot.unit_card.get_current_health()
    defender_slot.take_damage(damage)
    
    if attacker_slot.unit_card.has_piercing and damage > defender_hp:
        var excess = damage - defender_hp
        var behind_slot = get_slot_behind(defender_slot)
        if behind_slot and behind_slot.is_occupied():
            behind_slot.take_damage(excess)

# STEALTH - Can't be targeted in back row
func can_target_unit(target_slot: GridSlot) -> bool:
    if target_slot.unit_card.has_stealth and target_slot.is_back_row():
        return false
    return true
```

---

## Example: Complete Turn Flow

```gdscript
# === PLAYER'S TURN ===

# 1. RECHARGE PHASE
phase_recharge()
# - All units refresh
# - All memory becomes available

# 2. DRAW PHASE  
draw_cards(2)
# - Player draws 2 cards

# 3. MEMORY PHASE
# - Player chooses to place 1 card as memory (or skip)
if player_chooses_to_place_memory:
    place_as_memory(selected_card)

# 4. MAIN PHASE (Alternating Actions)
while not player_passes:
    # Player can:
    # - Deploy Unit (pay memory cost)
    # - Evolve Unit (pay memory cost, heals unit)
    # - Attach Install (pay memory cost)
    # - Build Firewall (pay memory cost)
    # - Play Item (pay memory cost, one-time effect)
    # - Set Trap (pay 2 memory, face-down)
    
    # After each action, opponent can respond
    await opponent_action()

# 5. BATTLE PHASE
phase_battle()
# - Each unit attacks in its column
# - Damage Firewalls or Core Files if column empty

# 6. END PHASE
phase_end()
# - Trigger end-of-turn effects
# - Pass turn to opponent
```

---

## UI Recommendations

### Hand Display
```
[Card 1] [Card 2] [Card 3] [Card 4] [Card 5]
   ↑ Click to play, Right-click for memory
```

### Memory Counter
```
Memory: 5/7 (5 available out of 7 total cards)
```

### Core Files Display
```
Core Files: ■ ■ ■ □ □ (3 remaining)
```

### Sync Gauge
```
Sync: ●●●○○ (3/5) - Ultimate Ready!
```

---

This guide should help you implement the remaining features systematically. Start with the deck/hand system, then add memory, then build up to the more complex systems like Linkers and Traps!

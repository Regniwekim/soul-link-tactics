# Card Data

This directory will contain card resource files (.tres) that define individual cards.

## Creating New Cards

Cards can be created as Godot Resources:

### Method 1: In Godot Editor

1. Right-click in this folder
2. Create New > Resource
3. Select `res://scripts/card.gd` as the script
4. Fill in the card properties in the Inspector
5. Save with a descriptive name (e.g., `flame_drake.tres`)

### Method 2: In Code

```gdscript
# Example: Creating a new card
var flame_drake = Card.new()
flame_drake.card_name = "Flame Drake"
flame_drake.card_type = Card.CardType.UNIT
flame_drake.systems = [Card.System.INFERNO]
flame_drake.power = 4
flame_drake.health = 5
flame_drake.stage = 1
flame_drake.attack_type = Card.AttackType.MELEE
flame_drake.memory_cost = 3
flame_drake.description = "A fierce dragon born from volcanic flames."
flame_drake.on_play_effect = "deal_2_damage_to_target"
flame_drake.has_blitz = false

# Save as resource (optional)
ResourceSaver.save(flame_drake, "res://resources/card_data/flame_drake.tres")
```

## Card Templates

### Basic Unit
```
Name: [Card Name]
Type: UNIT
System: [INFERNO/FLOW/AERO/etc.]
Cost: [Memory Cost]
Power: [Attack]
Health: [HP]
Stage: [1-3]
Attack Type: [MELEE/RANGED/FLYER/SNIPER]
```

### Linker (Commander)
```
Name: [Linker Name]
Type: LINKER
Systems: [Up to 2 colors]
Trap Slots: [Usually 2-4]
Sync Condition: [How to gain Sync Points]
Sync Override: [Ultimate ability]
Sync Cost: [Usually 5-7]
```

### Install (Equipment)
```
Name: [Equipment Name]
Type: INSTALL
System: [Matching unit's system]
Cost: [Memory Cost]
Power Bonus: [+Power]
Health Bonus: [+Health]
Effect: [Special ability]
```

## Planned Card Sets

- **Starter Set** - Basic cards for learning (TODO)
- **INFERNO Set** - Fire/Dragon themed cards (TODO)
- **FLOW Set** - Water/Fighting themed cards (TODO)
- **AERO Set** - Flying/Ice themed cards (TODO)
- **SPARK Set** - Electric/Steel themed cards (TODO)
- **HELIX Set** - Grass/Bug/Poison themed cards (TODO)
- **TERRA Set** - Ground/Rock themed cards (TODO)
- **PSY Set** - Psychic/Fairy themed cards (TODO)
- **VOID Set** - Ghost/Dark themed cards (TODO)

## Organization

Consider organizing cards into subdirectories:

```
card_data/
├── units/
│   ├── inferno/
│   ├── flow/
│   └── ...
├── linkers/
├── installs/
├── firewalls/
├── items/
└── traps/
```

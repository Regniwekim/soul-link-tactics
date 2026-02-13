# Soul-Link Tactics - Generated Card Library

🎴 **192 unique cards** automatically generated from your monster sprite collection!

## 📊 Card Distribution

### By System (Faction)

| System | Color | Count | Description |
|--------|-------|-------|-------------|
| **INFERNO** | Vermilion | 20 | Fire & Dragon themed units |
| **FLOW** | Dark Blue | 24 | Water & Fighting themed units |
| **AERO** | Sky Blue | 11 | Flying & Ice themed units |
| **SPARK** | Yellow | 27 | Electric & Steel/Mecha themed units |
| **HELIX** | Teal | 13 | Grass, Bug & Poison themed units |
| **TERRA** | Orange | 10 | Ground & Rock themed units |
| **PSY** | Magenta | 16 | Psychic & Fairy themed units |
| **VOID** | Charcoal | 71 | Ghost & Dark themed units |

### By Stage (Evolution Level)

- **Stage 1**: 93 cards - Basic units (1-2 cost)
- **Stage 2**: 30 cards - Mid-tier units (3-4 cost)  
- **Stage 3**: 69 cards - Boss units (7+ cost)

## 🚀 Quick Install

1. Copy this entire `generated_cards` folder to:
   ```
   your-project/resources/card_data/units/
   ```

2. Copy all .png sprites to:
   ```
   your-project/assets/monster_sprites/
   ```

3. Restart Godot and you're ready to play!

## 📝 Using Cards in Code

```gdscript
# Load a specific card
var dragon = load("res://resources/card_data/units/inferno/dragon_oriental_dragon.tres")

# Place on grid
player_grid[0][0].place_unit(dragon)
```

See full README inside the folder for detailed documentation!

---

**Total Cards**: 192 | **Systems**: 8 | **Ready**: ✅

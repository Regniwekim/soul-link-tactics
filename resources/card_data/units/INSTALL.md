# Installing Your Generated Cards

## 📦 What You Have

- **192 card resource files** (.tres format)
- **8 system folders** (inferno, flow, aero, spark, helix, terra, psy, void)
- **JSON summary** with all card data
- **Ready to use** in Godot

## 🎯 Installation Steps

### Step 1: Prepare Your Project

Make sure your Soul-Link Tactics project has these folders:

```
soul-link-tactics/
├── assets/
│   └── monster_sprites/     ← Create this folder
└── resources/
    └── card_data/
        └── units/           ← Copy card folders here
```

### Step 2: Copy Monster Sprites

1. Copy **all .png files** from your download to:
   ```
   soul-link-tactics/assets/monster_sprites/
   ```

2. You should have 192 PNG files in this folder

### Step 3: Copy Card Resources

1. Copy **all system folders** (inferno, flow, etc.) to:
   ```
   soul-link-tactics/resources/card_data/units/
   ```

2. Your structure should look like:
   ```
   resources/card_data/units/
   ├── inferno/
   ├── flow/
   ├── aero/
   ├── spark/
   ├── helix/
   ├── terra/
   ├── psy/
   └── void/
   ```

### Step 4: Restart Godot

1. Close your Godot project if it's open
2. Reopen it
3. Godot will import all the new resources
4. Check the FileSystem panel to verify everything loaded

## ✅ Verify Installation

### Quick Test

1. Open `scripts/game_board.gd`
2. Find the `create_test_units()` function
3. Replace the test unit code with:

```gdscript
func create_test_units() -> void:
	print("Creating test units...")
	
	# Load a card from your new collection!
	var dragon = load("res://resources/card_data/units/inferno/dragon_oriental_dragon.tres")
	player_0_grid[0][0].place_unit(dragon)
	
	var automaton = load("res://resources/card_data/units/spark/boss_ancient_automaton.tres")
	player_1_grid[1][0].place_unit(automaton)
	
	print("Test units created!")
```

4. Press F5 to run
5. You should see your new cards with artwork!

## 🎮 Using Cards in Your Game

### Load a Single Card

```gdscript
var card = load("res://resources/card_data/units/spark/clockwork_mini_a.tres")
```

### Load All Cards from a System

```gdscript
func load_all_inferno_cards() -> Array:
	var cards = []
	var dir = DirAccess.open("res://resources/card_data/units/inferno/")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tres"):
				var card = load("res://resources/card_data/units/inferno/" + file_name)
				cards.append(card)
			file_name = dir.get_next()
	
	return cards
```

### Build a Random Deck

```gdscript
func create_random_deck(size: int = 30) -> Array:
	var all_cards = []
	
	# Load cards from all systems
	var systems = ["inferno", "flow", "aero", "spark", "helix", "terra", "psy", "void"]
	
	for system in systems:
		var path = "res://resources/card_data/units/%s/" % system
		var dir = DirAccess.open(path)
		
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			
			while file_name != "":
				if file_name.ends_with(".tres"):
					all_cards.append(load(path + file_name))
				file_name = dir.get_next()
	
	# Shuffle and pick random cards
	all_cards.shuffle()
	return all_cards.slice(0, size)
```

## 🔧 Customizing Cards

### Edit in Godot Inspector

1. Navigate to a card in the FileSystem panel
2. Click on any `.tres` file
3. View/edit properties in the Inspector panel
4. Changes save automatically

### Edit Card Stats

```gdscript
# Load card
var card = load("res://resources/card_data/units/inferno/fire_bull.tres")

# Modify stats
card.power = 5
card.health = 6
card.memory_cost = 4
card.has_blitz = true

# Save changes (if you want to persist them)
ResourceSaver.save(card, "res://resources/card_data/units/inferno/fire_bull.tres")
```

## 📊 Card Database

Check `cards_summary.json` for a complete list of all cards with their stats!

```json
{
  "name": "Dragon Oriental Dragon",
  "safe_name": "dragon_oriental_dragon",
  "image_file": "Dragon_Oriental_Dragon.png",
  "system": "Card.System.INFERNO",
  "stage": 2,
  "cost": 4,
  "power": 3,
  "health": 3,
  "attack_type": "Card.AttackType.FLYER",
  "description": "A Dragon Oriental Dragon from the digital realm.",
  "is_boss": false
}
```

## ❓ Troubleshooting

### Cards Don't Show Artwork

**Problem**: Cards load but show no image  
**Solution**: Make sure PNG files are in `assets/monster_sprites/` with exact filenames

### Can't Find Card Files

**Problem**: Godot can't locate .tres files  
**Solution**: Check that folders are in `resources/card_data/units/` not `resources/card_data/`

### Import Errors

**Problem**: Godot shows import errors  
**Solution**: Close and reopen Godot, wait for reimport to complete

## 🎯 Next Steps

1. ✅ Install cards (you're here!)
2. 📝 Test with the verification code above
3. 🎮 Create a deck builder system
4. ⚖️ Balance card stats through playtesting
5. 🎨 Add special effects and abilities
6. 🏆 Build an AI opponent

---

**Need Help?** Check the main project README or create an issue on GitHub!

# Quick Start Guide

Get Soul-Link Tactics running in under 5 minutes!

## Prerequisites

1. **Download Godot Engine 4.6 or later**
   - Go to https://godotengine.org/download
   - Download the Standard version (not .NET unless you need C#)
   - Extract and run

## Installation

### Option 1: Clone from GitHub

```bash
git clone https://github.com/yourusername/soul-link-tactics.git
cd soul-link-tactics
```

### Option 2: Download ZIP

1. Click the green "Code" button on GitHub
2. Select "Download ZIP"
3. Extract to your preferred location

## Opening the Project

1. **Launch Godot Engine**
2. Click **"Import"** on the project manager
3. Navigate to the `soul-link-tactics` folder
4. Select `project.godot`
5. Click **"Import & Edit"**

## Running the Game

1. Press **F5** or click the **Play** button (▶️) in the top-right
2. The game will start with the battle grid displayed
3. Two test units are already placed for testing

## First Steps

### 1. Explore the Grid (30 seconds)
- Click on grid slots to see unit information in the console
- Notice the two test units: Flame Drake (P1) and Aqua Warrior (P2)

### 2. Test Turn Progression (1 minute)
- Click **"Next Phase"** button to advance through phases
- Watch the phase label change
- See combat happen during Battle Phase

### 3. Open the Scripts (2 minutes)
- In Godot's FileSystem panel, navigate to `scripts/`
- Double-click `game_board.gd` to see the main game logic
- Read the comments to understand how it works

### 4. Modify a Test Unit (2 minutes)
```gdscript
# In game_board.gd, find the create_test_units() function (around line 355)

# Try changing the Flame Drake's stats:
test_unit_1.power = 5  # Change from 3 to 5
test_unit_1.health = 8  # Change from 4 to 8
test_unit_1.has_blitz = true  # Add the Blitz keyword!
```

Save and press F5 to test your changes!

## Understanding the UI

```
┌─────────────────────────────────────┐
│ Player 1 - Recharge Phase           │ ← Current phase
│ [Next Phase]                         │ ← Advance turn
└─────────────────────────────────────┘

     P2 Grid (Top)
    ┌───┬───┬───┐
    │   │ A │   │  A = Aqua Warrior (2/5)
    ├───┼───┼───┤
    │   │   │   │
    ├───┼───┼───┤
    │   │   │   │
    └───┴───┴───┘

    ┌───┬───┬───┐
    │ F │   │   │  F = Flame Drake (3/4)
    ├───┼───┼───┤
    │   │   │   │
    ├───┼───┼───┤
    │   │   │   │
    └───┴───┴───┘
     P1 Grid (Bottom)

┌─────────────────────┐
│ Game Info Panel     │ ← Instructions
│ • Click slots       │
│ • Next Phase        │
│ • ...               │
└─────────────────────┘
```

## Testing Combat

1. Start the game (F5)
2. Click "Next Phase" **4 times** to reach the **Battle Phase**
3. Watch the console output as units attack
4. See damage applied to units
5. Click slots to verify new health values

## Project Structure

```
soul-link-tactics/
├── scripts/
│   ├── card.gd           ← All card types defined here
│   ├── grid_slot.gd      ← Grid position logic
│   └── game_board.gd     ← Main game controller (START HERE)
├── scenes/
│   └── game_board.tscn   ← Main scene
└── docs/
    ├── IMPLEMENTATION_GUIDE.md  ← How to add features
    └── GDD.txt                  ← Full game design
```

## Next Steps

Choose your path:

### Path 1: Learn the Code (Recommended for Beginners)
1. Read through `scripts/card.gd` - understand the card system
2. Read through `scripts/grid_slot.gd` - see how positions work
3. Read through `scripts/game_board.gd` - see how it all connects
4. Check the console output while playing to understand the flow

### Path 2: Add a Feature
1. Read `docs/IMPLEMENTATION_GUIDE.md`
2. Pick a feature (start with "Deck & Hand UI")
3. Implement it following the guide
4. Test thoroughly

### Path 3: Create Cards
1. Go to `resources/card_data/`
2. Create new card resources
3. Load them in `create_test_units()` function
4. Test your custom cards!

## Common Issues

### "Failed to load script" error
- Make sure all `.gd` files are in the `scripts/` folder
- Check that `game_board.tscn` references the correct script path

### Grid doesn't appear
- Check the Output panel for errors
- Verify `game_board.tscn` is set as the main scene

### Can't click slots
- Ensure you're clicking the colored square area
- Check console for "Slot clicked" messages

## Getting Help

- **Documentation**: Read `README.md` and `IMPLEMENTATION_GUIDE.md`
- **Issues**: Check existing [GitHub Issues](https://github.com/yourusername/soul-link-tactics/issues)
- **Discussions**: Ask in [GitHub Discussions](https://github.com/yourusername/soul-link-tactics/discussions)

## What's Working Now

✅ 3x3 Grid for both players
✅ Card system (all types defined)
✅ Turn phases (6 phases)
✅ Basic combat
✅ Click to inspect units
✅ Test units demonstrate gameplay

## What's Next

🚧 Deck & hand system
🚧 Memory/resource management
🚧 Card database
🚧 AI opponent
🚧 More features! (see CHANGELOG.md)

---

**Ready to start coding?** Open `scripts/game_board.gd` and start reading the comments! Every function is documented to help you learn.

**Just want to play?** Press F5 and start clicking "Next Phase" to watch combat unfold!

Happy coding! 🎮

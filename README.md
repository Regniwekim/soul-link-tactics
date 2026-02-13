# Soul-Link Tactics

<div align="center">

![Soul-Link Tactics](icon.svg)

**A tactical monster battler card game built with Godot 4.6**

[![Godot Engine](https://img.shields.io/badge/Godot-4.6-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

[Features](#features) • [Getting Started](#getting-started) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---

## 🎮 About

Soul-Link Tactics is a tactical monster battler TCG where players synchronize with digital monsters called "Anima" to compete on a holographic 3x3 combat grid. Drawing inspiration from Magic: The Gathering Commander, Star Wars Unlimited, and Pokémon, this game combines strategic positioning with the excitement of card battling.

### The Commander Hook

Players choose a **Linker** card (similar to a Commander in MTG) that:
- Stays off-field in the Command Zone
- Determines your deck's color identity
- Provides passive buffs
- Holds Trap cards
- Builds energy for game-changing Ultimate Moves

## ✨ Features

### Currently Implemented

- ✅ **3x3 Battle Grid System** - Fully functional tactical grid for both players
- ✅ **8 Unique Factions** - Color-blind friendly system using Wong/Okabe-Ito Palette
- ✅ **Complete Card Framework** - All card types, attack types, and keywords
- ✅ **Turn Structure** - 6-phase turn system (Recharge, Draw, Memory, Main, Battle, End)
- ✅ **Combat System** - Simultaneous damage, exhaustion, summoning sickness
- ✅ **Modular Architecture** - Easy to extend and customize

### Roadmap

- 🚧 Deck & Hand Management
- 🚧 Memory/Resource System
- 🚧 Firewall (Defense Structures)
- 🚧 Core Files (HP System) with BURST effects
- 🚧 Linker Ultimate Abilities
- 🚧 Trap Cards
- 🚧 Evolution System
- 🚧 Card Database & Deckbuilding
- 🚧 AI Opponent
- 🚧 Multiplayer Support

## 🚀 Getting Started

### Prerequisites

- [Godot Engine 4.6 or later](https://godotengine.org/download)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/soul-link-tactics.git
   cd soul-link-tactics
   ```

2. **Open in Godot**
   - Launch Godot Engine
   - Click "Import"
   - Navigate to the cloned directory
   - Select `project.godot`
   - Click "Import & Edit"

3. **Run the game**
   - Press `F5` or click the Play button
   - The game starts with test units to demonstrate combat

## 🎯 The 8 Systems (Factions)

Each system uses accessibility-friendly colors and represents different elemental types:

| System | Color | Types | Playstyle |
|--------|-------|-------|-----------|
| **INFERNO** | Vermilion | Fire / Dragon | Boss Monsters, High Damage |
| **FLOW** | Dark Blue | Water / Fighting | Combo, Fluid Movement |
| **AERO** | Sky Blue | Flying / Ice | Evasion, Back-row Disruption |
| **SPARK** | Yellow | Electric / Steel | Energy Generation, Defense |
| **HELIX** | Teal | Grass / Bug / Poison | Swarm, Evolution, Poison |
| **TERRA** | Orange | Ground / Rock | Lane Control, High HP |
| **PSY** | Magenta | Psychic / Fairy | Rule-bending, Mind Control |
| **VOID** | Charcoal | Ghost / Dark | Graveyard Recursion, Debuffs |

## 📚 Documentation

- **[README.md](README.md)** - Project overview and setup
- **[IMPLEMENTATION_GUIDE.md](docs/IMPLEMENTATION_GUIDE.md)** - Detailed guide for implementing features
- **[GDD.txt](docs/GDD.txt)** - Complete Game Design Document
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute to the project

## 🏗️ Project Structure

```
soul-link-tactics/
├── assets/              # Game assets
│   └── icons/          # Card artwork and icons
├── docs/               # Documentation
│   ├── GDD.txt        # Game Design Document
│   └── IMPLEMENTATION_GUIDE.md
├── resources/          # Godot resources
│   └── card_data/     # Card definitions
├── scenes/             # Godot scenes
│   └── game_board.tscn
├── scripts/            # GDScript files
│   ├── card.gd        # Base card class
│   ├── grid_slot.gd   # Grid position logic
│   └── game_board.gd  # Main game controller
├── .gitignore
├── CONTRIBUTING.md
├── LICENSE
├── project.godot      # Godot project file
└── README.md
```

## 🎮 Controls

- **Click** on grid slots to inspect units
- **Next Phase** button to advance through turns
- Units automatically attack during the Battle Phase

## 🛠️ Development

### Creating New Cards

Cards are defined as Godot Resources:

```gdscript
var my_card = Card.new()
my_card.card_name = "Flame Drake"
my_card.card_type = Card.CardType.UNIT
my_card.systems = [Card.System.INFERNO]
my_card.power = 5
my_card.health = 6
my_card.attack_type = Card.AttackType.FLYER
my_card.has_blitz = true
```

### Extending the System

The codebase is extensively commented for beginners. Check the [IMPLEMENTATION_GUIDE.md](docs/IMPLEMENTATION_GUIDE.md) for step-by-step instructions on adding new features.

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Development Priorities

1. Deck & Hand UI
2. Memory System
3. Card Database
4. Firewall Implementation
5. Core Files & BURST
6. Linker Ultimates
7. Trap Cards

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Magic: The Gathering (Commander), Star Wars Unlimited, Gundam TCG, Pixel Tactics, and Pokémon
- Uses the Wong/Okabe-Ito color palette for accessibility
- Built with [Godot Engine](https://godotengine.org/)

## 📞 Contact

- **Issues**: [GitHub Issues](https://github.com/yourusername/soul-link-tactics/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/soul-link-tactics/discussions)

---

<div align="center">

**Made with ❤️ for tactical card game enthusiasts**

[⬆ Back to Top](#soul-link-tactics)

</div>

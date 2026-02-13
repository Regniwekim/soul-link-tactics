# Contributing to Soul-Link Tactics

Thank you for your interest in contributing to Soul-Link Tactics! This document provides guidelines and instructions for contributing.

## 🌟 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Description**: Clear description of the bug
- **Steps to Reproduce**: Detailed steps to reproduce the behavior
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Screenshots**: If applicable
- **Environment**: 
  - Godot version
  - OS and version
  - Any relevant hardware info

**Use this template:**

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
 - Godot Version: [e.g., 4.3]
 - OS: [e.g., Windows 11]
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title** describing the enhancement
- **Detailed description** of the proposed functionality
- **Use case**: Why this would be useful
- **Possible implementation**: If you have ideas on how to implement it

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Follow the code style** (see below)
3. **Test your changes** thoroughly
4. **Update documentation** if needed
5. **Write clear commit messages**
6. **Create a pull request** with a clear description

## 💻 Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/soul-link-tactics.git
   ```

2. Create a feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. Make your changes and commit:
   ```bash
   git commit -m "Add amazing feature"
   ```

4. Push to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```

5. Open a Pull Request

## 📋 Code Style

### GDScript Guidelines

- **Use tabs** for indentation (Godot default)
- **PascalCase** for class names: `GridSlot`, `GameBoard`
- **snake_case** for variables and functions: `current_player`, `place_unit()`
- **SCREAMING_SNAKE_CASE** for constants: `MAX_HEALTH`, `DEFAULT_MEMORY`
- **Comment extensively** - This is a learning project!

### Comment Style

```gdscript
## Documentation comment for classes/functions
## Visible in Godot's help system
func my_function() -> void:
	# Regular comment for implementation details
	var my_var = 0
```

### Code Organization

```gdscript
# 1. Class definition and signals
class_name MyClass
extends Node2D

signal my_signal(param)

# 2. Enums
enum MyEnum { VALUE_A, VALUE_B }

# 3. Constants
const MAX_VALUE = 100

# 4. Exported variables
@export var my_export: int = 0

# 5. Public variables
var public_var: int = 0

# 6. Private variables (prefix with _)
var _private_var: int = 0

# 7. Onready variables
@onready var my_node: Node = $MyNode

# 8. Built-in virtual methods (_ready, _process, etc.)
func _ready() -> void:
	pass

# 9. Public methods
func public_method() -> void:
	pass

# 10. Private methods (prefix with _)
func _private_method() -> void:
	pass
```

## 🎯 Development Priorities

Current focus areas (in order):

1. **Deck & Hand System** - Card drawing and hand management
2. **Memory System** - Resource management implementation
3. **Card Database** - Create actual card definitions
4. **Firewall System** - Defensive structures
5. **Core Files** - HP system with BURST effects
6. **Linker System** - Commander abilities and Ultimates
7. **Trap Cards** - Face-down triggered effects
8. **Evolution** - Unit upgrade system
9. **AI Opponent** - Basic computer player
10. **Multiplayer** - Network play

## 📝 Commit Message Guidelines

Use conventional commits format:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(combat): add piercing damage mechanic
fix(grid): correct slot positioning calculation
docs(readme): update installation instructions
```

## 🧪 Testing

Before submitting a PR:

1. Test your changes in Godot
2. Ensure no errors in the Output console
3. Test edge cases
4. Verify with both test units

## 📖 Documentation

When adding new features:

1. **Update code comments** - Explain what and why
2. **Update README.md** if user-facing
3. **Update IMPLEMENTATION_GUIDE.md** for complex systems
4. **Add inline examples** where helpful

## 🤔 Questions?

- Open a [Discussion](https://github.com/yourusername/soul-link-tactics/discussions)
- Check existing [Issues](https://github.com/yourusername/soul-link-tactics/issues)
- Review the [Documentation](docs/)

## 🎨 Design Philosophy

Keep these principles in mind:

- **Beginner-Friendly**: Code should be educational
- **Modular**: Easy to extend and customize
- **Well-Documented**: Comments explain the "why", not just the "what"
- **Accessible**: Follow color-blind friendly design
- **Strategic**: Positioning matters as much as cards

## ✅ Pull Request Checklist

Before submitting your PR, ensure:

- [ ] Code follows the style guidelines
- [ ] Comments are clear and helpful
- [ ] No errors or warnings in Godot console
- [ ] Documentation updated if needed
- [ ] Commit messages are clear
- [ ] PR description explains what and why
- [ ] Tested in Godot 4.6+

## 🏆 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to Soul-Link Tactics! 🎮

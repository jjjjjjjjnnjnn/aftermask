# Aftermask

> Every life leaves a mask on the world.

A reincarnation simulation where your actions permanently change the world. Die, be reborn, and witness how your legacy shapes the future.

---

## What is Aftermask?

Aftermask is a single-player reincarnation simulation built with Godot 4. You live one life, make choices, die — and then see how those choices echo through generations.

Your legacy isn't just remembered. It **changes the world**.

- Build a school → 100 years later, it's a university
- Save a village → your statue stands in the town square  
- Betray a friend → their descendants hunt you down
- Create a sect → it might become a cult 7 generations later

## Core Loop

```
Live → Die → Reborn → Witness consequences → Change the world → Repeat
```

## What Makes This Different

| Feature | Description |
|---------|-------------|
| **Legacy System** | Your actions create permanent, evolving changes in the world |
| **Dynamic Consequences** | Legacies can be twisted, forgotten, or celebrated over time |
| **Cross-life Impact** | What you do in Life 1 affects Life 10 |
| **Emergent Stories** | Every player creates a unique multi-generational history |
| **Jianghu Aesthetic** | Eastern martial arts world with global accessibility |

## Tech Stack

- **Engine**: Godot 4.x + GDScript
- **Architecture**: ECS-inspired, Event-driven
- **Save Format**: JSON
- **Target Platform**: Steam (Windows, Linux, macOS)
- **AI**: Local inference (Phase 2)

## Project Status

🚧 **In early development**

Current phase: Validating core loop with text prototypes.

| Phase | Status | Goal |
|-------|--------|------|
| Phase 0 | ✅ Complete | Paper Prototype v0 |
| Phase 0.5 | ✅ Complete | Legacy Prototype v1 |
| Phase 1 | 🔄 In Progress | Legacy Retention Rate testing |
| Phase 2 | ⏳ Pending | Godot prototype |
| Phase 3 | ⏳ Pending | Full game development |

## Project Structure

```
src/
├── autoloads/       Global singletons (EventBus, GameManager, etc.)
├── core/            Core data structures (Entity, Character, Memory)
├── systems/         Game systems (Legacy, Reincarnation, World, etc.)
├── entities/        Player and NPC controllers
└── ui/              UI scripts

docs/
├── architecture/    Technical architecture documents
├── design/          Game design (public portions only)
└── logs/            Development logs

tests/               Paper and Legacy text prototypes
```

## Getting Started

### Prerequisites

- [Godot 4.x](https://godotengine.org/download)

### Run the Project

1. Clone the repository
2. Open `project.godot` in Godot 4
3. Press F5 to run

### Try the Text Prototypes

No engine required — just read:

- `tests/paper_prototype_v0.md` (15 minutes)
- `tests/legacy_prototype_v1.md` (30 minutes)

## Development Log

| Date | Milestone |
|------|-----------|
| 2026-06-18 | Project initialized, architecture designed |
| 2026-06-18 | Paper Prototype v0 created |
| 2026-06-18 | Legacy Prototype v1 created |
| 2026-06-18 | Legacy System v0 designed (20 case studies) |
| 2026-06-18 | Full project audit completed |
| 2026-06-18 | Risk register, ADRs, and approval process established |

## Contributing

This is currently a solo project. Contributions are not yet open.

If you're interested in playtesting, check out the [Test Plan](docs/TEST_PLAN.md).

## License

- **Code**: [MIT License](LICENSE)
- **Game Design & Content**: All Rights Reserved — see [COPYRIGHT.md](COPYRIGHT.md)

## Contact

For inquiries about the game, playtesting, or collaboration:

- GitHub Issues: [Create an issue](../../issues)

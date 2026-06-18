# Aftermask — AI Development Guide / KI-Entwicklungsleitfaden / AI开发指南

## Project Overview / Projekübersicht / 项目概述

**Aftermask** is a reincarnation simulation game built with Godot 4.

**Aftermask** ist eine Reinkarnationssimulation, entwickelt mit Gottot 4.

**Aftermask** 是一款基于Godot 4的轮回模拟器游戏。

**Core Principle**: Every life leaves a mask on the world.

**Kernprinzip**: Jede Leben hinterlässt eine Maske auf der Welt.

**核心原则**: 每一世都在世界留下一张面具。

---

## Language Convention / Sprachkonvention / 语言规范

This project uses **three languages**:

Dieses Projekt verwendet **drei Sprachen**:

本项目使用**三种语言**：

| Language | Usage | Verwendung | 用途 |
|----------|-------|------------|------|
| **English** | Primary code comments, documentation, UI | Primäre Codekommentare, Dokumentation, UI | 主要代码注释、文档、UI |
| **Deutsch** | Secondary documentation, legal texts | Sekundäre Dokumentation, rechtliche Texte | 辅助文档、法律文本 |
| **中文** | Design documents, business strategy | Designdokumente, Geschäftsstrategie | 设计文档、商业策略 |

### Code Comments / Codekommentare / 代码注释

```gdscript
## English comment (primary)
## Deutscher Kommentar (sekundär)
## 中文注释（设计文档中使用）
```

### Commit Messages / Commit-Nachrichten / 提交信息

```
feat(scope): description in English
```

---

## Coding Standards / Kodierungsstandards / 编码规范

### GDScript Style

- **Indentation**: Tabs (not spaces)
- **Class names**: PascalCase (`CharacterData`)
- **Variables**: snake_case (`player_health`)
- **Functions**: snake_case (`calculate_legacy_impact`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_LEGACY_IMPACT`)
- **Signals**: snake_case (`legacy_created`)
- **Comments**: English (primary), Chinese for design notes
- **No emojis** in code or comments
- **No `var` without type** when possible

### File Naming

- GDScript: `snake_case.gd` (`legacy_system.gd`)
- Scenes: `snake_case.tscn` (`title_screen.tscn`)
- Resources: `snake_case.tres` (`character_data.tres`)
- Documentation: `UPPER_CASE.md` (`README.md`)

---

## Architecture / Architektur / 架构

### Autoloads (Global Singletons)

| Name | Purpose | Zweck | 职责 |
|------|---------|-------|------|
| `EventBus` | Signal routing | Signalvermittlung | 信号路由 |
| `GameManager` | Game lifecycle | Spielzyklus | 游戏生命周期 |
| `WorldManager` | World state | Weltzustand | 世界状态 |
| `SaveManager` | Persistence | Speicherverwaltung | 存档管理 |
| `AudioManager` | Sound | Audioverwaltung | 音频管理 |

### System Priority / Systempriorität / 系统优先级

```
Legacy → Reincarnation → World → Character → AI → Faction → Economy → Combat
```

### Dependency Rules / Abhängigkeitsregeln / 依赖规则

- ✅ Systems may depend on Core and Autoloads
- ✅ Systems may depend on EventBus for communication
- ❌ No circular dependencies between systems
- ❌ No God Objects (single scripts > 500 lines)
- ❌ No direct game state in prompts

---

## Feature Approval / Funktionsgenehmigung / 功能审批

Every new feature must answer:

Jede neue Funktion muss beantworten:

每个新功能必须回答：

1. Does it strengthen the Legacy Loop?
   - Stärkt es den Legacy-Loop?
   - 它是否强化Legacy循环？

2. Is it perceptible to the player?
   - Ist es für den Spieler wahrnehmbar?
   - 玩家是否能感知？

3. Can it be shown in a Steam screenshot?
   - Kann es in einem Steam-Screenshot gezeigt werden?
   - 能否在Steam截图中体现？

4. Does it increase maintenance cost?
   - Erhöht es die Wartungskosten?
   - 是否增加维护成本？

5. Is it part of the MVP?
   - Ist es Teil des MVP?
   - 是否属于MVP？

If Q1 = No → Reject immediately.

Wenn Q1 = Nein → Sofort ablehnen.

如果Q1=否 → 直接拒绝。

---

## Never Build / Niemals bauen / 禁止构建

See [NEVER_BUILD_LIST.md](docs/NEVER_BUILD_LIST.md).

Siehe [NEVER_BUILD_LIST.md](docs/NEVER_BUILD_LIST.md).

详见 [NEVER_BUILD_LIST.md](docs/NEVER_BUILD_LIST.md)。

---

## Testing / Testen / 测试

### Text Prototypes

- `tests/paper_prototype_v0.md` — 15 min, first life
- `tests/legacy_prototype_v1.md` — 30 min, two lives with legacy

### Validation Metric

**Legacy Retention Rate (LRR)**:

```
LRR = Players who want to start Life 3 / Total test players
```

- LRR ≥ 80% → Core loop validated
- LRR 50-79% → Needs optimization
- LRR < 50% → Redesign required

---

## Git Conventions / Git-Konventionen / Git规范

### Branches

- `main` — Stable, release-ready
- `master` — Development (current)
- `feature/*` — New features
- `fix/*` — Bug fixes
- `docs/*` — Documentation only

### Commit Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

---

## References / Referenzen / 参考

- [Project Constitution](AGENTS.md)
- [Architecture Decisions](docs/ARCHITECTURE_DECISIONS.md)
- [Risk Register](docs/RISK_REGISTER.md)
- [Test Plan](docs/TEST_PLAN.md)

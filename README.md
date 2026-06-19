# Aftermask

> **Every life leaves a mask on the world.**
> **Jedes Leben hinterlässt eine Maske auf der Welt.**
> **每一世都在世界留下一张面具。**

---

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4](https://img.shields.io/badge/Godot-4.x-blue.svg)](https://godotengine.org)
[![Platform: Steam](https://img.shields.io/badge/Platform-Steam-black.svg)](https://store.steampowered.com)
[![Status: In Development](https://img.shields.io/badge/Status-In%20Development-orange.svg)](#project-status)

A reincarnation simulation where your actions permanently change the world. Die, be reborn, and witness how your legacy shapes the future.

Eine Reinkarnationssimulation, in der deine Handlungen die Welt dauerhaft verändern. Stirb, werde wiedergeboren und sieh, wie dein Vermächtnis die Zukunft formt.

一个轮回模拟器，你的行为会永久改变世界。死亡、转生，见证你的遗产如何塑造未来。

---

## Table of Contents

- [About](#about)
- [Core Loop](#core-loop)
- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [Project Status](#project-status)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Development Log](#development-log)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## About

### English

Aftermask is a single-player reincarnation simulation built with Godot 4. You live one life, make choices, die — and then see how those choices echo through generations.

Your legacy isn't just remembered. It **changes the world**.

- Build a school → 100 years later, it's a university
- Save a village → your statue stands in the town square
- Betray a friend → their descendants hunt you down
- Create a sect → it might become a cult 7 generations later

### Deutsch

Aftermask ist eine Einzelspieler-Reinkarnationssimulation, entwickelt mit Godot 4. Du lebst ein Leben, triffst Entscheidungen, stirbst — und siehst dann, wie diese Entscheidungen durch Generationen widerhallen.

Dein Vermächtnis wird nicht nur erinnert. Es **verändert die Welt**.

- Baue eine Schule → 100 Jahre später ist sie eine Universität
- Rette ein Dorf → deine Statue steht auf dem Marktplatz
- Verrate einen Freund → seine Nachkommen jagen dich
- Gründe eine Sekte → sie könnte in 7 Generationen zu einem Kult werden

### 中文

Aftermask 是一款基于 Godot 4 的单人轮回模拟器。你活过一生，做出选择，死亡——然后看到这些选择如何在世代间回响。

你的遗产不仅仅是被记住。它**改变了世界**。

- 建造一所学校 → 100年后，它成为大学
- 拯救一个村庄 → 你的雕像矗立在广场
- 背叛一个朋友 → 他的后代追杀你
- 创建一个门派 → 7代后可能变成邪教

---

## Core Loop

```
Live → Die → Reborn → Witness consequences → Change the world → Repeat
Leben → Sterben → Wiedergeboren → Folgen erleben → Welt verändern → Wiederholen
活过 → 死亡 → 转生 → 见证后果 → 改变世界 → 循环
```

---

## Key Features

| Feature | English | Deutsch | 中文 |
|---------|---------|---------|------|
| **Legacy System** | Your actions create permanent, evolving changes | Deine Handlungen erzeugen dauerhafte, sich entwickelnde Veränderungen | 你的行为创造永久的、演变的变化 |
| **Dynamic Consequences** | Legacies can be twisted, forgotten, or celebrated | Vermächtnisse können verfälscht, vergessen oder gefeiert werden | 遗产可能被扭曲、遗忘或颂扬 |
| **Cross-life Impact** | What you do in Life 1 affects Life 10 | Was du in Leben 1 tust, beeinflusst Leben 10 | 你在第一世做的事影响第十世 |
| **Emergent Stories** | Every player creates a unique history | Jeder Spieler erschafft eine einzigartige Geschichte | 每个玩家创造独特的历史 |
| **Jianghu Aesthetic** | Eastern martial arts world, globally accessible | Östliche Kampfkunstwelt, global zugänglich | 东方武侠世界，全球可及 |

---

## Tech Stack

| Component | Technology | Description |
|-----------|------------|-------------|
| **Engine** | Godot 4.x + GDScript | Game engine and scripting |
| **Architecture** | ECS-inspired, Event-driven | Modular system design |
| **Save Format** | JSON | Cross-platform save files |
| **Target Platform** | Steam | Windows, Linux, macOS |
| **AI** | Local inference (Phase 2) | llama.cpp / ONNX Runtime |

---

## Project Status

🚧 **In early development — validating core loop with text prototypes.**

| Phase | Status | Goal | Zeitrahmen |
|-------|--------|------|------------|
| Phase 0 | ✅ Abgeschlossen | Paper Prototype v0 | — |
| Phase 0.5 | ✅ Abgeschlossen | Legacy Prototype v1 | — |
| Phase 1 | 🔄 In Bearbeitung | Legacy Retention Rate Testing | Q3 2026 |
| Phase 2 | ⏳ Ausstehend | Godot Prototype | Q4 2026 |
| Phase 3 | ⏳ Ausstehend | Full Game Development | 2027 |

---

## Getting Started

### Voraussetzungen / Prerequisites / 前置条件

- [Godot 4.x](https://godotengine.org/download) (4.4 or later)

### Installation

```bash
# Clone the repository / Repository klonen / 克隆仓库
git clone https://github.com/jjjjjjjjnnjnn/aftermask.git

# Open in Godot 4 / In Godot 4 öffnen / 在Godot 4中打开
# Open project.godot and press F5 to run
```

### Text Prototypes (No Engine Required)

Experience the core loop without any software:

| Prototype | Duration | Description |
|-----------|----------|-------------|
| `tests/paper_prototype_v0.md` | 15 min | First life: beggar to sect master |
| `tests/legacy_prototype_v1.md` | 30 min | Two lives: create and witness legacy |

---

## Project Structure

```
aftermask/
├── src/
│   ├── autoloads/       Global singletons (EventBus, GameManager, etc.)
│   ├── core/            Core data structures (Entity, Character, Memory)
│   ├── systems/         Game systems (Legacy, Reincarnation, World, etc.)
│   ├── entities/        Player and NPC controllers
│   └── ui/              UI scripts
├── docs/
│   ├── architecture/    Technical architecture documents
│   └── logs/            Development logs
├── scenes/
│   ├── ui/              UI scenes
│   ├── entities/        Entity scenes
│   └── world/           World scenes
├── tests/               Text prototypes for core loop validation
├── AGENTS.md            Project constitution
├── CLAUDE.md            AI development guide
├── LICENSE              MIT License
└── COPYRIGHT.md         Copyright notice
```

---

## Development Log

| Datum | Meilenstein | 里程碑 |
|-------|-------------|--------|
| 2026-06-18 | Project initialized, architecture designed | 项目初始化，架构设计 |
| 2026-06-18 | Paper Prototype v0 created | 创建纸面原型 v0 |
| 2026-06-18 | Legacy Prototype v1 created | 创建遗产原型 v1 |
| 2026-06-18 | Legacy System v0 designed (20 case studies) | 设计遗产系统 v0（20个案例） |
| 2026-06-18 | Full project audit completed | 完成项目全面审计 |
| 2026-06-18 | Risk register, ADRs, approval process established | 建立风险登记、架构决策、审批流程 |
| 2026-06-18 | GitHub repository published | GitHub仓库发布 |

---

## Contributing / Mitwirken / 贡献

This is currently a solo project. Contributions are not yet open.

Dies ist derzeit ein Solo-Projekt. Beiträge sind noch nicht geöffnet.

目前是独立项目，暂不开放贡献。

If you're interested in playtesting, please [open an issue](../../issues) with the label `playtest`.

Wenn du an einem Playtest interessiert bist, eröffne bitte ein [Issue](../../issues) mit dem Label `playtest`.

如果对试玩测试感兴趣，请[创建Issue](../../issues)并标记 `playtest`。

---

## License / Lizenz / 许可证

| Scope | License | Description |
|-------|---------|-------------|
| **Code** | [MIT License](LICENSE) | Free to use, modify, distribute |
| **Game Design** | All Rights Reserved | See [COPYRIGHT.md](COPYRIGHT.md) |
| **World Building** | All Rights Reserved | See [COPYRIGHT.md](COPYRIGHT.md) |

---

## Contact / Kontakt / 联系方式

| Channel | Link |
|---------|------|
| GitHub Issues | [Create an issue](../../issues) |
| Email | [Contact via GitHub profile](https://github.com/jjjjjjjjnnjnn) |

---

<p align="center">
  <em>Built with Godot 4 · Made with determination</em><br>
  <em>Entwickelt mit Godot 4 · Mit Entschlossenheit gemacht</em><br>
  <em>基于Godot 4 · 用心打造</em>
</p>

# Aftermask | Project Constitution / Projektverfassung / 项目宪法 v2

---

## Mission / Mission / 项目使命

**Codename**: Aftermask (百世江湖)
**Genre**: Reincarnation Simulation / Reinkarnationssimulation / 轮回模拟器
**Platform**: Steam (Windows, Linux, macOS)
**Engine**: Godot 4.x + GDScript

**Tagline**: Every life leaves a mask on the world.
**Lebensdevise**: Jedes Leben hinterlässt eine Maske auf der Welt.
**核心口号**: 每一世都在世界留下一张面具。

**Goal**: Create a reincarnation simulator where player actions permanently change the world.

**Ziel**: Einen Reinkarnationssimulator entwickeln, in dem Spielerhandlungen die Welt dauerhaft verändern.

**目标**: 创造一个玩家行为会永久改变世界的轮回模拟器。

---

## Design Principles / Designprinzipien / 设计原则

### 1. Consequences Over Memory / Konsequenzen über Erinnerung / 后果优先于记忆

Players continue not because they are remembered, but because they **changed the world**.

Spieler setzen fort, nicht weil sie erinnert werden, sondern weil sie die Welt **verändert haben**.

玩家不是因为「被记住」而继续，而是因为「改变世界」而继续。

### 2. Systems Over Graphics / Systeme über Grafik / 系统深度优先于画面

RimWorld path, not Genshin Impact path.

RimWorld-Weg, nicht Genshin-Impact-Weg.

RimWorld路线，不是原神路线。

### 3. Replayability Over Content / Spielbarkeit über Inhalt / 可重复游玩优先于一次性内容

Every life is different.

Jedes Leben ist anders.

每一世都不同。

### 4. Rules Over LLM / Regeln über KI / 规则驱动优先于LLM驱动

AI as world simulator, not chatbot.

KI als Weltsimulator, nicht Chatbot.

AI作为世界模拟器，不是聊天机器人。

### 5. Global Mechanism, Chinese Culture / Globaler Mechanismus, chinesische Kultur / 机制国际化，文化中国化

Sell Legacy, Choice, Consequence — not "Wuxia".

Verkaufe Vermächtnis, Wahl, Konsequenz — nicht "Wuxia".

卖 Legacy、Choice、Consequence，不卖「武侠」。

### 6. Solo Maintainable / Solo wartbar / 单人开发可维护

Don't build what can't be maintained.

Baue nicht, was nicht gewartet werden kann.

不做做不到的事。

### 7. Steam First / Steam zuerst / Steam优先

Consider Steam ecosystem from day one.

Berücksichtige das Steam-Ökosystem von Tag eins an.

从第一天就考虑Steam生态。

### 8. Local AI / Lokale KI / 本地AI推理

Local inference by default, cloud optional.

Lokale Inferenz als Standard, Cloud optional.

默认本地推理，云端可选。

---

## Globalization Strategy / Globalisierungsstrategie / 全球化策略

### Core Principle / Kernprinzip / 核心原则

> **Global mechanism, Chinese culture.**
> **Globaler Mechanismus, chinesische Kultur.**
> **机制国际化，文化中国化。**

- Sell Legacy, Choice, Consequence — not "Wuxia"
  - Verkaufe Vermächtnis, Wahl, Konsequenz — nicht "Wuxia"
  - 卖 Legacy、Choice、Consequence，不卖「武侠」

- Explain Eastern elements in ways global players understand
  - Erkläre östliche Elemente so, dass globale Spieler sie verstehen
  - 用全球玩家能理解的方式解释东方元素

- Keep Jianghu, Sects, Master-Disciple, Feuds, Reincarnation
  - Behalte Jianghu, Sekten, Meister-Schüler, Fehden, Reinkarnation
  - 保留江湖、门派、师徒、恩怨、轮回

- Don't堆砌武侠术语
  - Keine Wuxia-Terminologie anhäufen
  - 不堆砌武侠术语

### Steam Tags (Global) / Steam-Tags (global) / Steam标签（全球版）

Roguelike / Simulation / Narrative / Choices Matter / Dark Fantasy / Atmospheric / Indie

### One-Line Pitch / Einzeiler / 一句话定位

> "A reincarnation simulation where every life leaves a mark on the world."
> "Eine Reinkarnationssimulation, in der jedes Leben eine Spur in der Welt hinterlässt."
> "一个轮回模拟器，每一世都在世界留下痕迹。"

---

## Forbidden / Verboten / 禁止偏离

- ❌ Multiplayer / Mehrspieler / 多人
- ❌ PvP
- ❌ Guilds / Gilden / 公会
- ❌ Shop / Laden / 商城
- ❌ Open World (MVP phase) / Offene Welt (MVP-Phase) / 开放世界（MVP阶段）
- ❌ Complex Combat (MVP phase) / Komplexer Kampf (MVP-Phase) / 复杂战斗（MVP阶段）
- ❌ Full LLM drive / Volle KI-Steuerung / 全LLM驱动
- ❌ API per NPC dialogue / API pro NPC-Dialog / NPC每句话调用API
- ❌ Cloud inference dependency / Cloud-Inferenz-Abhängigkeit / 依赖云端推理
- ❌ High GPU requirements / Hohe GPU-Anforderungen / 高GPU需求
- ❌ Wuxia term dumping / Wuxia-Termini anhäufen / 堆砌武侠术语
- ❌ Pure Chinese context / Reiner chinesischer Kontext / 纯中国语境

---

## Tech Stack / Technologie-Stack / 技术栈

| Layer / Schicht / 层级 | Technology / Technologie / 技术 | Responsibility / Verantwortung / 职责 |
|------------------------|--------------------------------|--------------------------------------|
| Game Layer / Spielschicht / 游戏层 | Godot 4 + GDScript | UI, Scenes, Animation, Game Flow |
| Core Layer / Kernschicht / 核心层 | GDScript (Rust optional later) | World Simulation, Data Management |
| AI Runtime / KI-Laufzeitumgebung / AI运行时 | llama.cpp / GGUF / ONNX | Local Inference (Phase 2) |
| Data Layer / Datenschicht / 数据层 | Resources + JSON | Config, Saves, NPC Data |

---

## Architecture Principles / Architekturprinzipien / 架构原则

- ECS-inspired (Entity-Component-System)
  - ECS-inspiriert
  - 采用ECS思想

- Modular design, each system independent
  - Modulares Design, jedes System unabhängig
  - 模块化设计，每个系统独立

- System priority: Legacy → Reincarnation → World → Character → AI → Faction → Economy → Combat
  - Systempriorität: Legacy → Reincarnation → World → Character → AI → Faction → Economy → Combat
  - 系统优先级：Legacy → Reincarnation → World → Character → AI → Faction → Economy → Combat

- No circular dependencies / Keine zirkulären Abhängigkeiten / 禁止循环依赖
- No God Objects / Keine Gott-Objekte / 禁止God Object
- No game state in prompts / Kein Spielzustand in Prompts / 禁止把游戏状态直接塞进Prompt

---

## MVP Goals / MVP-Ziele / MVP目标

### Core Validation / Kernvalidierung / 核心验证

Verify one core question:

Eine Kernfrage verifizieren:

验证一个核心问题：

> Do players continue reincarnating because they are remembered, or because they changed the world?
> Setzen Spieler die Reinkarnation fort, weil sie erinnert werden, oder weil sie die Welt verändert haben?
> 玩家究竟是因为「被记住」而继续轮回，还是因为「改变世界」而继续轮回？

### MVP Scope / MVP-Umfang / MVP范围

1. **Legacy System**: Player actions permanently change the world
   - **Legacy-System**: Spielerhandlungen verändern die Welt dauerhaft
   - **Legacy系统**: 玩家行为永久改变世界

2. **Reincarnation System**: Death → Choose Legacy → Reborn → Witness Consequences
   - **Reinkarnationssystem**: Tod → Vermächtnis wählen → Wiedergeboren → Folgen erleben
   - **转生系统**: 死亡→选择遗产→重生→见证后果

3. **World Simulation**: Faction evolution, NPC relationships, legend propagation
   - **Weltsimulation**: Fraktionsevolution, NPC-Beziehungen, Legendenverbreitung
   - **世界模拟**: 势力演化、NPC关系、传说传播

4. **Minimalist Visuals**: Cultist Simulator style
   - **Minimalistische Grafik**: Cultist-Stil
   - **简约视觉**: Cultist Simulator风格

5. **English Localization P0**
   - **Englische Lokalisierung P0**
   - **英文本地化P0**

---

## Feature Approval / Funktionsgenehmigung / 功能审批

Every new feature must answer:

Jede neue Funktion muss beantworten:

每个新功能必须回答：

1. Does it increase legacy value? (Can player actions permanently change the world?)
   - Erhöht es den Vermächtniswert? (Können Spielerhandlungen die Welt dauerhaft verändern?)
   - 它是否增加遗产价值？

2. Does it increase reincarnation motivation? (Does the player want to start the next life?)
   - Erhöht es die Reinkarnationsmotivation? (Will der Spieler das nächste Leben beginnen?)
   - 它是否增加轮回动力？

3. Does it increase shareability? (Does the player want to share their story?)
   - Erhöht es die Sharing-Fähigkeit? (Will der Spieler seine Geschichte teilen?)
   - 它是否增加传播性？

4. Does it increase long-term retention?
   - Erhöht es die langfristige Bindung?
   - 它是否增加长期留存？

If all answers are No: Reject development.

Wenn alle Antworten Nein sind: Entwicklung ablehnen.

如果答案都是否：拒绝开发。

---

## Development Phases / Entwicklungsphasen / 开发阶段

| Phase | Time / Zeit / 时间 | Goal / Ziel / 目标 | Technology / Technologie / 技术 |
|-------|-------------------|-------------------|-------------------------------|
| Phase 0 | Now / Jetzt / 现在 | Paper Prototype Validation | Text only / Nur Text / 纯文本 |
| Phase 1 | 0-3 months / Monate / 月 | Legacy Loop Prototype | Godot + GDScript |
| Phase 2 | 3-6 months / Monate / 月 | AI Integration | llama.cpp / ONNX Runtime |
| Phase 3 | 6+ months / Monate / 月 | Model Training | Jianghu-1B custom model |

---

## Agent Work Rules / Agent-Arbeitsregeln / Agent工作规则

- All code changes must pass architecture review
  - Alle Codeänderungen müssen eine Architekturprüfung bestehen
  - 所有代码修改必须经过架构审查

- New systems must have design docs first
  - Neue Systeme müssen zuerst Designdokumente haben
  - 新增系统必须先写设计文档

- Never modify core systems without understanding global architecture
  - Verändere niemals Kernsysteme ohne Verständnis der globalen Architektur
  - 禁止在没有理解全局架构的情况下修改核心系统

- Each PR must include: design doc link, test results, performance impact
  - Jeder PR muss enthalten: Designdoc-Link, Testergebnisse, Performance-Auswirkung
  - 每个PR必须包含：设计文档链接、测试结果、性能影响评估

- Code style follows official GDScript standards
  - Code-Stil folgt offiziellen GDScript-Standards
  - 代码风格遵循GDScript官方规范

- Priority: Legacy > Memory > Combat > UI > Art
  - Priorität: Legacy > Erinnerung > Kampf > UI > Kunst
  - 优先级：Legacy > Memory > Combat > UI > 美术

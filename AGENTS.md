# 百世江湖 | Project Constitution v2

## 项目使命

**代号**: 百世江湖 (Hundred Lives Jianghu)
**类型**: 独立游戏 · 轮回模拟器 · 东方沙盒
**平台**: Steam (Windows, Linux, macOS)
**引擎**: Godot 4.x + GDScript

**核心口号**: Build a legacy that survives your death.
**中文**: 每一世都会改变未来的世界。

**核心目标**: 创造一个玩家行为会永久改变世界的轮回模拟器。

玩家每次死亡都会转生。世界会持续演化。玩家的遗产会跨越世代。玩家体验重点：成长、遗产、后果、改变历史。

## 设计原则

1. **后果优先于记忆** — 玩家不是因为「被记住」而继续，而是因为「改变世界」而继续
2. **系统深度优先于画面表现** — RimWorld路线，不是原神路线
3. **可重复游玩优先于一次性内容** — 每一世都不同
4. **规则驱动优先于LLM驱动** — AI作为世界模拟器，不是聊天机器人
5. **机制国际化，文化中国化** — 全球概念 + 东方包装
6. **单人开发可维护** — 不做做不到的事
7. **Steam优先** — 从第一天就考虑Steam生态
8. **支持本地AI推理** — 默认本地，云端可选

## 全球化策略

### 核心原则

> **机制国际化，文化中国化。**

- 卖 Legacy、Choice、Consequence，不卖「武侠」
- 用全球玩家能理解的方式解释东方元素
- 核心卖点放在「遗产与后果」「轮回与改变世界」
- 保留江湖、门派、师徒、恩怨、轮回这些东方元素
- 但不堆砌武侠术语

### Steam标签（全球版）

Roguelike / Simulation / Narrative / Choices Matter / Dark Fantasy / Atmospheric / Indie

### 一句话定位（全球版）

> "A reincarnation simulation where every life leaves a mark on the world."

### 中国元素的全球翻译

| 中文概念 | 英文表达 | 全球理解度 |
|---------|---------|-----------|
| 轮回 | Reincarnation / Rebirth | ★★★★★ |
| 世界改变 | World Legacy | ★★★★★ |
| 门派 | Sect / Clan / School | ★★★★☆ |
| 师徒 | Master-Disciple | ★★★★☆ |
| 江湖 | Jianghu (Martial World) | ★★★☆☆ |
| 恩怨 | Feud / Vendetta | ★★★★☆ |
| 修炼 | Cultivation / Training | ★★★☆☆ |
| 境界 | Realm / Stage | ★★★☆☆ |

## 禁止偏离

- 不做多人
- 不做PVP
- 不做公会
- 不做商城
- 不做开放世界（MVP阶段）
- 不做复杂战斗（MVP阶段）
- 不做全LLM驱动
- 不做NPC每句话调用API
- 不做依赖云端推理
- 不做高GPU需求
- 不堆砌武侠术语
- 不做纯中国语境（不解释就用）

## 技术栈

| 层级 | 技术 | 职责 |
|------|------|------|
| Game Layer | Godot 4 + GDScript | UI、场景、动画、游戏流程 |
| Core Layer | GDScript (后期可迁Rust) | World Simulation、数据管理 |
| AI Runtime | llama.cpp / GGUF / ONNX | 本地推理（第二阶段引入） |
| Data Layer | Resource文件 + JSON | 配置、存档、NPC数据 |

## 架构原则

- 采用ECS思想（Entity-Component-System）
- 模块化设计，每个系统独立
- 系统优先级：Legacy → Reincarnation → World → Character → AI → Faction → Economy → Combat
- 禁止循环依赖
- 禁止God Object
- 禁止把游戏状态直接塞进Prompt

## MVP目标

### 核心验证（纸面原型阶段）

验证一个核心问题：
> 玩家究竟是因为「被记住」而继续轮回，还是因为「改变世界」而继续轮回？

### MVP范围

1. **Legacy系统**: 玩家行为永久改变世界
2. **转生系统**: 死亡→选择遗产→重生→见证后果
3. **世界模拟**: 势力演化、NPC关系、传说传播
4. **简约视觉**: Cultist Simulator风格
5. **英文本地化P0**

## 功能审查标准

每次新增功能必须回答：
1. 它是否增加遗产价值？（玩家行为是否能永久改变世界）
2. 它是否增加轮回动力？（玩家是否想开下一世）
3. 它是否增加传播性？（玩家是否想分享故事）
4. 它是否增加长期留存？

如果答案都是否：拒绝开发。

## 研发模式

像资深游戏技术总监一样工作。当我提出需求时：
1. 先进行需求分析、风险分析、架构分析、性能分析
2. 提出多个方案，说明优缺点
3. 最后再编码
4. 如果发现需求违背项目目标：必须指出

## AI架构（长期目标）

超低成本AI架构：
- 10000个NPC同时存在
- 本地运行
- 普通PC可运行
- 优先考虑：Embedding、Memory Compression、Distillation、LoRA、QLoRA、GGUF、ONNX
- 每个NPC拥有人格、关系、目标、长期记忆
- 总内存占用最低

## 开发阶段

| 阶段 | 时间 | 目标 | 技术 |
|------|------|------|------|
| Phase 0 | 现在 | 纸面原型验证 | 纯文本 |
| Phase 1 | 0-3月 | Legacy Loop原型 | Godot + GDScript |
| Phase 2 | 3-6月 | 引入AI | llama.cpp / ONNX Runtime |
| Phase 3 | 6月+ | 训练模型 | Jianghu-1B 专用模型 |

## Agent工作规则

- 所有代码修改必须经过架构审查
- 新增系统必须先写设计文档
- 禁止在没有理解全局架构的情况下修改核心系统
- 每个PR必须包含：设计文档链接、测试结果、性能影响评估
- 代码风格遵循GDScript官方规范
- 优先级：Legacy > Memory > Combat > UI > 美术

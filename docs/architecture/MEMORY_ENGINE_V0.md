# Memory Engine v0 架构设计

## 设计目标

设计一个支持以下能力的记忆系统：
1. NPC记忆玩家行为
2. 跨世代记忆继承
3. 世界历史记录
4. 支持100世轮回
5. 本地存储
6. 支持未来AI扩展

## 核心概念

### 记忆层次模型

```
┌─────────────────────────────────────────┐
│           Legend Memory (传说记忆)        │  ← 跨世代传播，口口相传
│  重要事件被世界记住，影响所有后续世代       │
├─────────────────────────────────────────┤
│           Long-term Memory (长期记忆)     │  ← 单NPC终身记忆
│  重要交互、情感事件、关键选择              │
├─────────────────────────────────────────┤
│           Short-term Memory (短期记忆)    │  ← 最近7天事件
│  日常交互、简单对话、路过                  │
├─────────────────────────────────────────┤
│           Working Memory (工作记忆)       │  ← 当前情境
│  正在发生的事件、当前对话                  │
└─────────────────────────────────────────┘
```

### 记忆衰减机制

```
记忆强度 = 初始强度 × e^(-λ × 时间) × 重要性加权

其中：
- 初始强度: 1-10（由事件重要性决定）
- λ: 衰减率（短期=0.3, 长期=0.01, 传说=0.001）
- 时间: 以"天"为单位
- 重要性加权: 情感事件×2, 生死事件×5, 背叛事件×3
```

### 记忆类型定义

```gdscript
enum MemoryType {
    ENCOUNTER,      # 遇见
    DIALOGUE,       # 对话
    TRADE,          # 交易
    COMBAT,         # 战斗
    GIFT,           # 送礼
    BETRAYAL,       # 背叛
    AID,            # 帮助
    THEFT,          # 偷窃
    MURDER,         # 杀害
    DEFEAT,         # 击败
    RESCUE,         # 救命
    LEGEND,         # 传说（跨世代）
    REINCARNATION   # 转生识别
}
```

## 架构设计

### 数据结构

```gdscript
# 记忆条目
class_name MemoryEntry
extends Resource

@export var id: int                          # 记忆ID
@export var type: MemoryType                 # 记忆类型
@export var subject_id: int                  # 主体（谁的记忆）
@export var target_id: int                   # 客体（关于谁）
@export var era: int                         # 发生在哪一世
@export var world_time: Dictionary           # 发生时间
@export var intensity: float                 # 记忆强度 0.0-1.0
@export var emotional_valence: float         # 情感倾向 -1.0(负面) ~ 1.0(正面)
@export var description: String              # 记忆描述
@export var decay_rate: float                # 衰减率
@export var is_legend: bool                  # 是否为传说记忆
@export var related_entities: Array[int]     # 相关实体
@export var tags: Array[String]              # 标签

# NPC记忆数据库
class_name NPCMemory
extends Resource

@export var entity_id: int
@export var short_term: Array[MemoryEntry]   # 短期记忆（最近7天）
@export var long_term: Array[MemoryEntry]    # 长期记忆（重要事件）
@export var legends: Array[MemoryEntry]      # 传说记忆（跨世代）

# 世界历史
class_name WorldHistory
extends Resource

@export var events: Array[Dictionary]        # 世界事件日志
@export var legends: Array[Dictionary]       # 世界传说
@export var eras: Array[Dictionary]          # 各世代摘要
```

### 记忆处理流程

```
事件发生
    ↓
MemoryEngine.record_event(event_data)
    ↓
┌─────────────────────────────────────┐
│ Step 1: 判断记忆类型和强度           │
│   - 事件类型 → MemoryType           │
│   - 情感价值 → emotional_valence    │
│   - 初始强度 → intensity            │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 2: 写入NPC短期记忆             │
│   - 所有在场NPC获得记忆             │
│   - 根据距离衰减强度                │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 3: 判断是否升级为长期记忆       │
│   - intensity > 0.7 → 长期          │
│   - 情感事件 → 强制长期             │
│   - 生死事件 → 强制长期             │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 4: 判断是否升级为传说           │
│   - intensity > 0.9 + era > 3       │
│   - 被多个NPC同时记住               │
│   - 世界事件级别                     │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 5: 写入世界历史                 │
│   - 重要事件记录到WorldHistory       │
│   - 传说事件永久保存                 │
└─────────────────────────────────────┘
```

### 跨世代记忆继承

```
玩家死亡
    ↓
┌─────────────────────────────────────┐
│ 转生算法:                           │
│                                     │
│ 1. 选择前世记忆碎片（1-3个）         │
│    - 优先选择 intensity 最高的       │
│    - 优先选择 emotional_valence 极端 │
│    - 传说记忆自动继承                │
│                                     │
│ 2. NPC对新角色的态度                 │
│    - 查找是否有前世记忆              │
│    - 根据前世行为调整初始关系        │
│    - 触发"认出你"对话               │
│                                     │
│ 3. 世界状态继承                      │
│    - 势力关系保留                    │
│    - 经济状态保留                    │
│    - 地理变化保留                    │
└─────────────────────────────────────┘
```

### NPC记忆查询API

```gdscript
# 查询NPC对某个玩家的记忆
func query_memories(npc_id: int, target_id: int) -> Array[MemoryEntry]:
    # 从短期到长期到传说，按时间倒序返回
    
# 查询NPC对某个玩家的情感态度
func get_sentiment(npc_id: int, target_id: int) -> float:
    # 基于所有记忆的emotional_valence加权平均
    
# 查询NPC是否有前世识别记忆
func check_reincarnation_recognition(npc_id: int, target_id: int) -> Dictionary:
    # 检查是否有传说级别的前世记忆
    # 返回：是否认出、具体记忆、情感反应
    
# 生成NPC对话上下文
func generate_dialogue_context(npc_id: int, target_id: int) -> Dictionary:
    # 返回：当前情感、相关记忆、对话建议
```

## 存储方案

### 本地存储格式

```json
{
  "npc_memories": {
    "0": {
      "entity_id": 0,
      "short_term": [...],
      "long_term": [...],
      "legends": [...]
    }
  },
  "world_history": {
    "events": [...],
    "legends": [...],
    "eras": [...]
  },
  "player_memories": {
    "fragments": [...],
    "recognized_by": [...]
  }
}
```

### 内存优化

- 短期记忆：内存缓存，最多100条/NPC
- 长期记忆：磁盘存储，按需加载
- 传说记忆：全局缓存，永久保存
- 总内存预算：10000 NPC × 平均50条短期 + 10条长期 = ~50MB

## 未来AI扩展点

### Phase 2: 本地AI增强
- 用LLM生成记忆描述文本
- 用Embedding计算记忆相似度
- 用LLM生成NPC对话

### Phase 3: 专用模型
- Jianghu-1B: 专门学习江湖恩怨、门派关系、忠义背叛
- 用LoRA微调，专门处理记忆相关的文本生成

## 实现优先级

| 功能 | 优先级 | 预计时间 |
|------|--------|---------|
| MemoryEntry数据结构 | P0 | 1天 |
| NPCMemory存储 | P0 | 1天 |
| 记忆衰减算法 | P0 | 1天 |
| 记录事件API | P0 | 1天 |
| 查询记忆API | P0 | 1天 |
| 情感态度计算 | P1 | 1天 |
| 跨世代继承 | P1 | 2天 |
| 世界历史记录 | P1 | 1天 |
| 转生识别系统 | P1 | 2天 |
| 对话上下文生成 | P2 | 2天 |
| 存档系统集成 | P1 | 1天 |

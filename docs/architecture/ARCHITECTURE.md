# 百世江湖 技术架构文档

## 系统总览

```
┌─────────────────────────────────────────────────────┐
│                    Godot 4 Scene Tree                 │
├─────────────────────────────────────────────────────┤
│  Autoloads (全局单例)                                 │
│  ├── EventBus.gd        全局事件总线                   │
│  ├── GameManager.gd     游戏生命周期管理               │
│  ├── WorldManager.gd    世界状态管理                   │
│  ├── SaveManager.gd     存档系统                      │
│  └── AudioManager.gd    音频管理                      │
├─────────────────────────────────────────────────────┤
│  Core Systems (核心系统)                              │
│  ├── WorldSystem        世界模拟 (时间/天气/地点)       │
│  ├── CharacterSystem    角色管理 (属性/状态/行为)       │
│  ├── MemorySystem       记忆系统 (NPC记忆/历史事件)     │
│  ├── FactionSystem      势力系统 (门派/关系网)          │
│  ├── CombatSystem       战斗系统 (回合制/策略)          │
│  ├── EconomySystem      经济系统 (货币/物品/交易)       │
│  ├── ReincarnationSystem 转生系统 (死亡/转世/传承)      │
│  └── AISystem           AI系统 (人格/决策/对话)         │
├─────────────────────────────────────────────────────┤
│  Data Layer (数据层)                                  │
│  ├── Resources (.tres)  配置数据                      │
│  ├── Save Files (.json) 存档数据                      │
│  └── NPC Templates      NPC模板数据                    │
└─────────────────────────────────────────────────────┘
```

## 数据流

```
玩家输入
    ↓
EventBus (事件分发)
    ↓
┌──────────┬──────────┬──────────┐
│ System A │ System B │ System C │  (各系统独立处理)
└──────────┴──────────┴──────────┘
    ↓
WorldState (世界状态更新)
    ↓
MemorySystem (记录事件)
    ↓
AISystem (NPC反应)
    ↓
EventBus (触发新事件)
    ↓
渲染更新
```

## 核心数据结构

### Entity (实体)
```gdscript
# 每个游戏对象都是一个Entity
# 通过Component组合获得能力
class_name Entity
var id: int
var components: Dictionary = {}  # { "position": PositionComponent, ... }
```

### Component (组件)
```gdscript
# 纯数据容器，无逻辑
class_name PositionComponent
var x: float
var y: float

class_name CharacterComponent
var name: String
var age: int
var realm: String  # 境界
var stats: Dictionary  # { strength: 10, agility: 8, ... }
```

### System (系统)
```gdscript
# 纯逻辑，操作Component
class_name MovementSystem
func update(delta: float):
    for entity in world.query(["PositionComponent", "VelocityComponent"]):
        var pos = entity.get("PositionComponent")
        var vel = entity.get("VelocityComponent")
        pos.x += vel.dx * delta
        pos.y += vel.dy * delta
```

## Autoload架构

### EventBus.gd
全局事件总线。所有跨系统通信通过信号完成。

关键信号：
- `entity_spawned(entity_id, entity_type)`
- `entity_died(entity_id, cause)`
- `reincarnation_triggered(old_id, new_id)`
- `memory_recorded(entity_id, event_data)`
- `faction_relation_changed(faction_a, faction_b, delta)`
- `world_event_triggered(event_data)`
- `game_saved()`
- `game_loaded()`

### GameManager.gd
游戏生命周期：初始化、暂停、恢复、退出。

### WorldManager.gd
世界状态：当前时间、天气、地点、活跃事件。

### SaveManager.gd
存档系统：自动存档、手动存档、存档验证。

## 文件结构

```
ai江湖/
├── project.godot
├── AGENTS.md                 ← 项目宪法
├── docs/
│   ├── architecture/         ← 架构文档
│   ├── design/               ← 设计文档
│   └── logs/                 ← 开发日志
├── src/
│   ├── autoloads/            ← 全局单例脚本
│   ├── core/                 ← 核心工具类
│   ├── systems/              ← 各系统实现
│   │   ├── world/
│   │   ├── character/
│   │   ├── memory/
│   │   ├── faction/
│   │   ├── combat/
│   │   ├── economy/
│   │   ├── reincarnation/
│   │   └── ai/
│   ├── ui/                   ← UI脚本
│   ├── entities/             ← 实体定义
│   └── data/                 ← 数据定义(Resources)
├── scenes/                   ← 场景文件
│   ├── ui/
│   ├── entities/
│   └── world/
├── assets/                   ← 资源文件
│   ├── sprites/
│   ├── tiles/
│   ├── audio/
│   ├── fonts/
│   └── ui/
└── tests/                    ← 测试文件
```

## 状态管理

### GameState (全局状态)
```gdscript
# 通过WorldManager管理
var current_world: WorldData
var current_time: GameTime  # { day: 1, hour: 8, season: "spring" }
var active_era: int  # 当前轮回纪元
var player_id: int
```

### Save Format
```json
{
  "version": "0.1.0",
  "era": 1,
  "world_time": { "day": 1, "hour": 8, "season": "spring" },
  "player": { "id": 0, "name": "无名", "realm": "乞丐", "stats": {} },
  "entities": [],
  "relationships": [],
  "history": [],
  "npc_memories": {}
}
```

# Reincarnation System v0 架构设计

## 设计目标

转生系统是百世江湖的第二个核心。它必须回答一个核心问题：

> **玩家为什么想开启下一世？**

答案不是"因为死了"，而是：
- "我想看看如果当初选了另一条路会怎样"
- "我想带着前世的经验再挑战一次"
- "我想看看NPC还认不认得我"

## 核心机制

### 转生触发

```
死亡触发（3种）：
1. 自然死亡 — 寿命耗尽，平静离世
2. 意外死亡 — 战斗、事故、中毒等
3. 主动选择 — 修行者可以选择"兵解"转世

每种死亡触发不同的转生效果：
- 自然死亡：完整转生，保留最多记忆
- 意外死亡：部分转生，可能丢失记忆碎片
- 主动选择：特殊转生，可选择保留特定记忆
```

### 转生流程

```
┌─────────────────────────────────────┐
│ Step 1: 一世总结                     │
│   - 统计本世成就                     │
│   - 计算轮回奖励                     │
│   - 生成"一世传记"                   │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 2: 记忆选择                     │
│   - 展示前世重要记忆（按intensity排序）│
│   - 玩家选择1-3个记忆碎片保留         │
│   - 传说记忆自动保留                  │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 3: 转生分配                     │
│   - 随机出生地点                     │
│   - 随机出生身份（受前世影响）         │
│   - 属性继承/变异                    │
│   - 天赋继承                         │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 4: 世界反应                     │
│   - NPC检查前世记忆                  │
│   - 触发"认出你"事件                │
│   - 世界状态更新                     │
└─────────────────────────────────────┘
```

### 一世总结

```gdscript
class_name LifeSummary
extends Resource

@export var era: int                          # 第几世
@export var character_name: String            # 角色名
@export var birth_place: String               # 出生地
@export var death_place: String               # 死亡地
@export var cause_of_death: String            # 死因
@export var age_at_death: int                 # 死亡年龄
@export var realm_reached: String             # 达到的境界
@export var achievements: Array[String]       # 成就列表
@export var relationships_formed: int         # 建立的关系数
@export var enemies_made: int                 # 树敌数
@export var legends_created: int              # 创建的传说数
@export var total_playtime: float             # 总游戏时间
@export var key_choices: Array[Dictionary]    # 关键选择记录
```

### 属性继承规则

```
基础继承：
- 力量: 前世最高力量 × 0.1（最低+1）
- 敏捷: 前世最高敏捷 × 0.1
- 悟性: 前世最高悟性 × 0.15（悟性传承最强）
- 魅力: 前世最高魅力 × 0.1

成就加成（可叠加）：
- 达到武师境界: +2 悟性
- 建立势力: +1 所有属性
- 帮助10人: +2 魅力
- 杀害无辜: -1 魅力, +1 力量
- 寿终正寝: +5 寿命上限
- 背叛他人: -1 所有社交属性

轮回天赋（解锁条件）：
- "记忆碎片": 保留3个前世记忆（默认1个）
- "似曾相识": NPC初始好感+10
- "江湖传说": 传说记忆传播范围×2
- "宿命之子": 特定前世解锁特殊剧情
```

### 轮回奖励系统

```gdscript
# 根据一世成就计算轮回奖励
func calculate_reincarnation_rewards(summary: LifeSummary) -> Dictionary:
    var rewards = {
        "stat_bonuses": {},
        "memory_slots": 1,  # 默认1个记忆碎片槽
        "talents": [],
        "reputation_effects": {},
        "special_unlocks": []
    }
    
    # 境界成就
    if REALM_ORDER.find(summary.realm_reached) >= REALM_ORDER.find("武师"):
        rewards.stat_bonuses["comprehension"] = 2
        rewards.talents.append("修行者之心")
    
    # 社交成就
    if summary.relationships_formed >= 10:
        rewards.stat_bonuses["charisma"] = 2
        rewards.talents.append("社交达人")
    
    # 战斗成就
    if summary.enemies_made >= 5:
        rewards.stat_bonuses["strength"] = 1
        rewards.stat_bonuses["agility"] = 1
    
    # 传说成就
    if summary.legends_created >= 1:
        rewards.memory_slots += 1
        rewards.talents.append("传说之源")
    
    # 寿终正寝
    if summary.cause_of_death == "自然死亡":
        rewards.stat_bonuses["max_hp"] = 10
        rewards.talents.append("善终者")
    
    return rewards
```

### NPC转生识别

```
玩家转生后，NPC检查是否能认出：

1. 查找传说记忆
   - NPC是否有传说级别的前世记忆
   - 如果有，100%认出

2. 查找长期记忆
   - NPC是否有高强度的前世记忆
   - 根据记忆强度计算认出概率
   - 公式: P = min(1.0, intensity × 0.8)

3. 触发识别对话
   - 如果认出: "你...你长得很像我认识的一个人..."
   - 如果不确定: "我们是不是在哪里见过？"
   - 如果完全不认识: 正常对话

4. 情感反应
   - 正面记忆: 初始好感+记忆强度×10
   - 负面记忆: 初始好感-记忆强度×10
   - 混合记忆: 按比例计算
```

### 世界历史系统

```
世界历史记录以下类型的事件：

1. 个人传说（个人级别的传奇事件）
   - "张三在野猪林独杀十人"
   - "李四创建了铁掌门"

2. 世界事件（影响整个世界的事件）
   - "百年前的大战"
   - "门派兴衰"

3. 时代标记（每个时代的特征）
   - "第一世：乞丐崛起"
   - "第二世：铁掌门的黄金时代"

这些历史会：
- 影响NPC的对话
- 影响世界的状态
- 影响新玩家的出生环境
- 成为Steam成就的基础
```

## 验证闭环

```
第一世：玩家是乞丐，被张铁匠收留
    ↓
玩家选择偷窃，被张铁匠发现，关系破裂
    ↓
玩家死亡，转生
    ↓
第二世：玩家遇到张铁匠
    ↓
张铁匠说："你长得像我以前认识的一个人...他让我很失望"
    ↓
玩家感受到：选择有重量，世界记得我
    ↓
✅ 核心体验验证通过
```

## 实现优先级

| 功能 | 优先级 | 预计时间 |
|------|--------|---------|
| LifeSummary数据结构 | P0 | 0.5天 |
| 属性继承算法 | P0 | 1天 |
| 记忆碎片选择UI | P0 | 1天 |
| 轮回奖励计算 | P0 | 1天 |
| NPC转生识别 | P1 | 2天 |
| 一世传记生成 | P1 | 1天 |
| 世界历史记录 | P1 | 1天 |
| 轮回天赋系统 | P2 | 2天 |
| 特殊转生类型 | P2 | 1天 |

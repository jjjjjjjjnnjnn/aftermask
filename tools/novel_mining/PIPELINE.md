# Novel Mining Pipeline 架构设计

## 设计目标

从用户的小说库中自动提取结构化知识，用于百世江湖的世界生成。

**输入**: 22+ 部小说（txt/docx/md），总计约100万字
**输出**: 结构化JSON数据库，供游戏和AI使用

## 小说库盘点

| 项目 | 类型 | 内容 | 游戏价值 |
|------|------|------|---------|
| 踹掉PUA系统 | 玄幻/系统流 | 33章+详细大纲 | 系统机制、打脸事件、势力对抗 |
| 理综73的我 | 异世界/知识流 | 完整世界观+7神殿 | 知识体系、学科拟人、成长路线 |
| 被设计的人生 | 悬疑/都市 | 三部曲大纲 | 身份认同、选择悖论、阴谋事件 |
| 电梯里的约定 | 都市 | 短篇 | 人际关系、日常事件 |
| 界限 | 未知 | 大纲 | 规则系统、边界设定 |
| 金线缝相思 | 言情 | 大纲 | 情感系统、关系网络 |
| 镜子 | 悬疑 | 大纲 | 身份分裂、自我认知 |
| 生成 | 科幻 | 60章大纲 | 世界观构建、力量体系 |
| 投资者 | 都市 | 大纲 | 经济系统、商业逻辑 |
| 异乡校园 | 都市/异能 | 已有游戏实现 | NPC交互、日常循环 |
| ... | ... | ... | ... |

## 提取层次

### Layer 1: 人物原型 (Character Archetypes)

**提取内容**:
- 角色类型（掌门/镖师/乞丐/商人/...）
- 性格维度（五大人格）
- 行为倾向（忠诚/背叛/贪婪/复仇/...）
- 关系模式（师徒/敌对/恋人/...）

**输出格式**:
```json
{
  "archetype_id": "iron_fist_master",
  "name": "铁血掌门",
  "source": "踹掉PUA系统",
  "personality": {
    "openness": 5,
    "conscientiousness": 8,
    "extraversion": 6,
    "agreeableness": 4,
    "neuroticism": 3
  },
  "traits": ["protect_disciples", "value_honor", "strict"],
  "behavior_tendencies": {
    "loyalty": 90,
    "greed": 20,
    "vengeance": 60,
    "compassion": 40
  },
  "typical_dialogue_style": "严厉但关心",
  "conflict_resolution": "武力解决",
  "death_preference": "战死"
}
```

### Layer 2: 事件模板 (Event Templates)

**提取内容**:
- 事件类型（拜师/背叛/复仇/比武/...）
- 触发条件
- 参与者角色
- 结果分支
- 情感影响

**输出格式**:
```json
{
  "event_id": "betray_master",
  "name": "背叛师门",
  "source": "踹掉PUA系统",
  "trigger": {
    "conditions": ["弟子忠诚度 < 30", "外部诱惑 > 70"],
    "probability": 0.3
  },
  "participants": {
    "required": ["master", "disciple"],
    "optional": ["witness"]
  },
  "outcomes": [
    {
      "condition": "master战斗力 > disciple战斗力",
      "result": "expulsion",
      "effects": {
        "sect_reputation": -50,
        "master_honor": -30,
        "disciplefreedom": +100
      }
    },
    {
      "condition": "master战斗力 < disciple战斗力",
      "result": "coup",
      "effects": {
        "sect_reputation": -80,
        "new_leader": "disciple"
      }
    }
  ],
  "emotional_impact": {
    "witnesses": "shock + anger",
    "sect_members": "fear + loyalty_test"
  }
}
```

### Layer 3: 势力体系 (Faction Systems)

**提取内容**:
- 势力类型（门派/帮会/官府/商帮/...）
- 势力关系（同盟/敌对/中立）
- 势力规则（入派条件/晋升路径/退出代价）
- 势力文化（价值观/行为准则）

**输出格式**:
```json
{
  "faction_id": "iron_gate_sect",
  "name": "铁掌门",
  "source": "综合提取",
  "type": "martial_sect",
  "values": ["honor", "strength", "loyalty"],
  "hierarchy": [
    {"rank": "掌门", "authority": 100},
    {"rank": "长老", "authority": 70},
    {"rank": "真传弟子", "authority": 50},
    {"rank": "内门弟子", "authority": 30},
    {"rank": "外门弟子", "authority": 10}
  ],
  "join_conditions": {
    "strength_min": 5,
    "reputation_min": 0,
    "recommendation": true
  },
  "relations": {
    "poison_snake_gang": "enemy",
    "government": "neutral",
    "wandering_heroes": "friendly"
  }
}
```

### Layer 4: 世界规则 (World Rules)

**提取内容**:
- 价值体系（什么是正派/邪派/灰色）
- 社会规则（江湖礼仪/禁忌/潜规则）
- 因果逻辑（背叛的代价/复仇的规则/恩情的偿还）
- 物理规则（力量体系/修炼逻辑/死亡机制）

**输出格式**:
```json
{
  "rule_id": "honor_code",
  "name": "江湖道义",
  "source": "综合提取",
  "category": "social_norms",
  "rules": [
    {
      "rule": "师徒如父子",
      "enforcement": "social_ostracism",
      "violations": ["背叛师门", "弑师"],
      "consequences": {
        "reputation": -100,
        "faction_relations": "all_sects_hostile",
        "personal": "终身追杀"
      }
    },
    {
      "rule": "恩怨分明",
      "enforcement": "personal_honor",
      "description": "受恩必报，结怨必了",
      "game_mechanic": "karma_system"
    }
  ]
}
```

### Layer 5: 事件库 (Event Library)

**提取内容**:
- 小说中的具体事件
- 事件的起因-经过-结果
- 事件中的选择点
- 事件的情感曲线

### Layer 6: 武学体系 (Martial Arts System)

**提取内容**:
- 功法分类（内功/外功/轻功/暗器/...）
- 境界划分
- 突破条件
- 克制关系

### Layer 7: 社会阶层 (Social Hierarchy)

**提取内容**:
- 阶层划分（乞丐/平民/武者/官员/...）
- 阶层流动规则
- 阶层特权
- 阶层冲突

## 提取流程

```
原始小说文本
    ↓
┌─────────────────────────────────────┐
│ Step 1: 文本预处理                   │
│   - 分章                             │
│   - 去除格式标记                     │
│   - 识别对话/叙述/描写               │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 2: 实体识别                     │
│   - 人名 → 角色                     │
│   - 地名 → 地点                     │
│   - 功法名 → 武学                   │
│   - 势力名 → 势力                   │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 3: 关系抽取                     │
│   - 师徒关系                         │
│   - 敌对关系                         │
│   - 恋人关系                         │
│   - 盟友关系                         │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 4: 事件抽取                     │
│   - 关键事件识别                     │
│   - 事件分类                         │
│   - 因果链构建                       │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 5: 规则归纳                     │
│   - 行为模式总结                     │
│   - 因果逻辑提取                     │
│   - 价值体系归纳                     │
└─────────────────────────────────────┘
    ↓
┌─────────────────────────────────────┐
│ Step 6: 结构化输出                   │
│   - JSON格式化                       │
│   - 去重和合并                       │
│   - 质量检查                         │
└─────────────────────────────────────┘
    ↓
/data/ (结构化知识库)
```

## 实现优先级

| 模块 | 优先级 | 预计时间 | 依赖 |
|------|--------|---------|------|
| 文本预处理 | P0 | 1天 | 无 |
| 人物原型提取 | P0 | 2天 | 预处理 |
| 事件模板提取 | P0 | 2天 | 预处理 |
| 势力体系提取 | P1 | 1天 | 人物原型 |
| 世界规则提取 | P1 | 2天 | 事件模板 |
| 武学体系提取 | P1 | 1天 | 预处理 |
| 社会阶层提取 | P2 | 1天 | 势力体系 |
| 质量检查 | P1 | 1天 | 全部 |

## 工具选择

### 方案A: 规则+LLM混合（推荐）
- 规则引擎做实体识别和关系抽取
- LLM做语义理解和规则归纳
- 优点: 准确率高，可控性强
- 缺点: 需要大量规则编写

### 方案B: 纯LLM提取
- 用Claude/GPT直接提取
- 优点: 简单快速
- 缺点: 不可控，可能遗漏

### 方案C: 本地模型提取
- 用Ollama+本地模型
- 优点: 免费，隐私
- 缺点: 质量较低

**推荐**: 方案A（规则+LLM混合），因为小说库是私有资产，需要高质量提取。

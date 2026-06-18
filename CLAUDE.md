# 百世江湖 | AI开发指南

## 项目概述

这是一个Godot 4武侠轮回RPG。玩家每次死亡转生，世界持续演化，NPC记住历史。

## 核心约束

1. **先读AGENTS.md** — 项目宪法是一切的最高指令
2. **先写设计文档，再写代码** — 每个新系统必须有设计文档
3. **遵守功能审查标准** — 新功能必须回答4个问题
4. **模块化** — 每个系统独立，禁止循环依赖
5. **MVP优先** — 6周内完成可玩版本

## 代码规范

- GDScript使用snake_case命名
- 类名使用PascalCase
- 常量使用UPPER_SNAKE_CASE
- 信号使用snake_case
- 注释使用中文

## 架构要点

- 事件通信通过EventBus单例
- 数据通过Resource文件定义
- 状态通过GameManager管理
- 存档通过SaveManager处理

## 开发流程

1. 提出需求 → 需求分析
2. 架构分析 → 多方案对比
3. 设计文档 → 审核通过
4. 编码实现 → 测试验证
5. 代码审查 → 合并

## 关键文件

| 文件 | 用途 |
|------|------|
| AGENTS.md | 项目宪法 |
| docs/architecture/ | 架构文档 |
| docs/design/ | 设计文档 |
| src/autoloads/ | 全局单例 |
| src/core/ | 核心数据结构 |
| src/systems/ | 各系统实现 |

## EventBus — 全局事件总线
## 所有跨系统通信通过此单例的信号完成
extends Node

# === 实体事件 ===
signal entity_spawned(entity_id: int, entity_type: String, position: Vector2)
signal entity_died(entity_id: int, cause: String)
signal entity_moved(entity_id: int, from: Vector2, to: Vector2)

# === 战斗事件 ===
signal combat_started(attacker_id: int, defender_id: int)
signal combat_ended(winner_id: int, loser_id: int)
signal damage_dealt(source_id: int, target_id: int, amount: int, damage_type: String)

# === 转生事件 ===
signal reincarnation_triggered(old_entity_id: int, new_entity_id: int)
signal memory_fragment_gained(entity_id: int, fragment_data: Dictionary)
signal era_advanced(new_era: int)

# === 记忆事件 ===
signal memory_recorded(entity_id: int, event_type: String, event_data: Dictionary)
signal memory_forgotten(entity_id: int, memory_id: int)
signal legend_created(entity_id: int, legend_data: Dictionary)

# === 势力事件 ===
signal faction_relation_changed(faction_a: String, faction_b: String, delta: int)
signal faction_member_joined(entity_id: int, faction_id: String)
signal faction_member_left(entity_id: int, faction_id: String)

# === 世界事件 ===
signal world_event_triggered(event_data: Dictionary)
signal time_advanced(new_time: Dictionary)
signal weather_changed(new_weather: String)

# === 经济事件 ===
signal currency_changed(entity_id: int, currency_type: String, amount: int)
signal item_acquired(entity_id: int, item_id: String)
signal item_lost(entity_id: int, item_id: String)

# === UI事件 ===
signal dialogue_started(npc_id: int, dialogue_data: Dictionary)
signal dialogue_ended()
signal notification_requested(message: String, type: String)

# === 遗产事件 ===
signal legacy_created(entity_id: int, legacy_data: Dictionary)
signal legacy_changed(legacy_id: int, change_type: String, new_state: Dictionary)
signal legacy_decayed(legacy_id: int, decay_amount: float)
signal legacy_triggered(legacy_id: int, trigger_event: Dictionary)

# === 游戏状态事件 ===
signal game_saved(save_data: Dictionary)
signal game_loaded(save_data: Dictionary)
signal game_paused()
signal game_resumed()

# === 信号文档 ===
# 所有信号定义集中在此，便于追踪和维护
# 新增信号时请在此添加注释说明用途

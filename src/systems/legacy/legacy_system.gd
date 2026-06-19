## LegacySystem — 遗产系统核心
## 管理玩家行为对世界的永久影响
class_name LegacySystem
extends Node

# === 遗产类型 ===
enum LegacyType {
	PHYSICAL,   # 物理遗产：建筑、物品、破坏
	SOCIAL,     # 社会遗产：势力、关系、地位
	LEGEND,     # 传说遗产：故事、传说、节日
	BLOODLINE   # 血脉遗产：后代、血缘、传承
}

# === 遗产数据结构 ===
class LegacyRecord:
	var id: int = -1
	var source_era: int = 0  # 来源世代
	var source_entity_id: int = -1  # 来源实体
	var legacy_type: LegacyType = LegacyType.PHYSICAL
	var target_location: String = ""  # 影响地点
	var target_faction: String = ""  # 影响势力
	var impact_value: int = 0  # 影响值 (-100 ~ +100)
	var is_permanent: bool = true  # 是否永久
	var description: String = ""  # 描述
	var decay_rate: float = 0.95  # 每世衰减率
	var current_impact: float = 0.0  # 当前影响值
	var creation_time: Dictionary = {}  # 创建时间
	
	func _init():
		current_impact = float(impact_value)
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"source_era": source_era,
			"source_entity_id": source_entity_id,
			"legacy_type": legacy_type,
			"target_location": target_location,
			"target_faction": target_faction,
			"impact_value": impact_value,
			"is_permanent": is_permanent,
			"description": description,
			"decay_rate": decay_rate,
			"current_impact": current_impact,
			"creation_time": creation_time.duplicate()
		}
	
	static func from_dict(data: Dictionary) -> LegacyRecord:
		var record = LegacyRecord.new()
		record.id = data.get("id", -1)
		record.source_era = data.get("source_era", 0)
		record.source_entity_id = data.get("source_entity_id", -1)
		record.legacy_type = data.get("legacy_type", LegacyType.PHYSICAL)
		record.target_location = data.get("target_location", "")
		record.target_faction = data.get("target_faction", "")
		record.impact_value = data.get("impact_value", 0)
		record.is_permanent = data.get("is_permanent", true)
		record.description = data.get("description", "")
		record.decay_rate = data.get("decay_rate", 0.95)
		record.current_impact = data.get("current_impact", 0.0)
		record.creation_time = data.get("creation_time", {})
		return record

# === 遗产存储 ===
var legacies: Dictionary = {}  # { legacy_id: LegacyRecord }
var next_legacy_id: int = 0
var current_era: int = 1

func _ready() -> void:
	pass

# === 创建遗产 ===
func create_legacy(source_entity_id: int, legacy_type: LegacyType, 
		target_location: String, target_faction: String,
		impact_value: int, description: String) -> int:
	var record = LegacyRecord.new()
	record.id = next_legacy_id
	next_legacy_id += 1
	record.source_era = current_era
	record.source_entity_id = source_entity_id
	record.legacy_type = legacy_type
	record.target_location = target_location
	record.target_faction = target_faction
	record.impact_value = impact_value
	record.description = description
	record.current_impact = float(impact_value)
	record.creation_time = WorldManager.world_time.duplicate()
	
	legacies[record.id] = record
	EventBus.legacy_created.emit(source_entity_id, record.to_dict())
	return record.id

# === 查询遗产 ===
func get_legacy(legacy_id: int) -> LegacyRecord:
	return legacies.get(legacy_id, null)

func get_legacies_at_location(location_name: String) -> Array[LegacyRecord]:
	var result: Array[LegacyRecord] = []
	for legacy_id in legacies:
		var legacy = legacies[legacy_id]
		if legacy.target_location == location_name:
			result.append(legacy)
	return result

func get_legacies_for_faction(faction_id: String) -> Array[LegacyRecord]:
	var result: Array[LegacyRecord] = []
	for legacy_id in legacies:
		var legacy = legacies[legacy_id]
		if legacy.target_faction == faction_id:
			result.append(legacy)
	return result

func get_legacies_by_type(legacy_type: LegacyType) -> Array[LegacyRecord]:
	var result: Array[LegacyRecord] = []
	for legacy_id in legacies:
		var legacy = legacies[legacy_id]
		if legacy.legacy_type == legacy_type:
			result.append(legacy)
	return result

func get_legacies_by_source(entity_id: int) -> Array[LegacyRecord]:
	var result: Array[LegacyRecord] = []
	for legacy_id in legacies:
		var legacy = legacies[legacy_id]
		if legacy.source_entity_id == entity_id:
			result.append(legacy)
	return result

# === 计算遗产影响 ===
func calculate_legacy_impact(legacy_id: int) -> float:
	var legacy = legacies.get(legacy_id, null)
	if legacy == null:
		return 0.0
	
	var era_gap = current_era - legacy.source_era
	var impact = legacy.impact_value * pow(legacy.decay_rate, era_gap)
	legacy.current_impact = impact
	return impact

func get_total_impact_at_location(location_name: String) -> float:
	var total: float = 0.0
	var location_legacies: Array[LegacyRecord] = get_legacies_at_location(location_name)
	for legacy: LegacyRecord in location_legacies:
		total += calculate_legacy_impact(legacy.id)
	return total

func get_total_impact_for_faction(faction_id: String) -> float:
	var total: float = 0.0
	var faction_legacies: Array[LegacyRecord] = get_legacies_for_faction(faction_id)
	for legacy: LegacyRecord in faction_legacies:
		total += calculate_legacy_impact(legacy.id)
	return total

# === 世代推进 ===
func advance_era() -> void:
	current_era += 1
	
	# 所有遗产衰减
	for legacy_id in legacies:
		var legacy = legacies[legacy_id]
		var old_impact = legacy.current_impact
		legacy.current_impact *= legacy.decay_rate
		
		# 如果影响值变化超过10%，触发变更事件
		if abs(old_impact - legacy.current_impact) > abs(old_impact) * 0.1:
			EventBus.legacy_changed.emit(legacy_id, "decay", {
				"old_impact": old_impact,
				"new_impact": legacy.current_impact
			})
	
	EventBus.era_advanced.emit(current_era)

# === 存档 ===
func save_data() -> Dictionary:
	var legacy_data = {}
	for legacy_id in legacies:
		legacy_data[legacy_id] = legacies[legacy_id].to_dict()
	
	return {
		"current_era": current_era,
		"next_legacy_id": next_legacy_id,
		"legacies": legacy_data
	}

func load_data(data: Dictionary) -> void:
	current_era = data.get("current_era", 1)
	next_legacy_id = data.get("next_legacy_id", 0)
	
	var legacy_data: Dictionary = data.get("legacies", {})
	legacies.clear()
	for legacy_id_str: String in legacy_data:
		var legacy_id_int: int = int(legacy_id_str)
		legacies[legacy_id_int] = LegacyRecord.from_dict(legacy_data[legacy_id_str])

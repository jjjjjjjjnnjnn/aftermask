## ReincarnationEngine — 转生引擎
## 核心逻辑层，处理死亡→记忆选择→轮回奖励→转生分配
## 遵循 LinguaCore 架构：所有逻辑在程序端完成，不调用模型
extends Node

signal reincarnation_started(summary: LifeSummary)
signal reincarnation_completed(new_entity_id: int, rewards: Dictionary)
signal memory_fragments_shown(fragments: Array)
signal memory_fragment_selected(fragment_index: int)

# 境界列表（从低到高）
const REALM_ORDER: Array[String] = [
	"无", "武徒", "武者", "武师", "先天", "宗师", "大宗师", "天人"
]

# 转生天赋定义
const REINCARNATION_TALENTS: Dictionary = {
	"memory_keep": {
		"name": "记忆碎片",
		"desc": "保留3个前世记忆碎片（默认1个）",
		"unlock_condition": "legends_created >= 1",
	},
	"familiar_face": {
		"name": "似曾相识",
		"desc": "NPC初始好感+10",
		"unlock_condition": "relationships_formed >= 10",
	},
	"legend_spreader": {
		"name": "江湖传说",
		"desc": "传说记忆传播范围×2",
		"unlock_condition": "legends_created >= 3",
	},
	"destined_child": {
		"name": "宿命之子",
		"desc": "特定前世解锁特殊剧情",
		"unlock_condition": "factions_founded >= 1",
	},
	"peaceful_end": {
		"name": "善终者",
		"desc": "寿命上限+5",
		"unlock_condition": "cause_of_death == 'natural'",
	},
	"warrior_spirit": {
		"name": "武者之心",
		"desc": "力量传承+50%",
		"unlock_condition": "peak_strength >= 10",
	},
}

# 出生身份池（受前世影响）
const BIRTH_IDENTITIES: Dictionary = {
	"peasant": {"name": "农家", "stat_bonus": {"max_hp": 10}},
	"merchant": {"name": "商家", "stat_bonus": {"charisma": 1}},
	"scholar": {"name": "书生", "stat_bonus": {"comprehension": 1}},
	"hunter": {"name": "猎户", "stat_bonus": {"agility": 1}},
	"beggar": {"name": "乞丐", "stat_bonus": {"strength": 1}},
	"artisan": {"name": "工匠", "stat_bonus": {"max_mp": 5}},
	"monk": {"name": "僧侣", "stat_bonus": {"comprehension": 2}},
	"noble": {"name": "贵族", "stat_bonus": {"charisma": 2}},
}


func start_reincarnation(summary: LifeSummary) -> Dictionary:
	"""
	触发一次完整的转生流程。
	返回包含记忆选择、轮回奖励、新角色的结果字典。
	"""
	emit_signal("reincarnation_started", summary)

	# 计算轮回奖励
	var rewards = _calculate_rewards(summary)
	# 计算新角色属性
	var new_stats = _calculate_inherited_stats(summary, rewards)
	# 分配出生身份
	var birth = _assign_birth(summary, rewards)
	# 解锁轮回天赋
	var talents = _unlock_talents(summary)

	var result = {
		"summary": summary.to_dict(),
		"rewards": rewards,
		"new_stats": new_stats,
		"birth": birth,
		"talents": talents,
		"memory_fragments": _get_available_fragments(summary),
		"legend_memories": summary.legend_memories,
	}
	return result


func confirm_reincarnation(era: int, stats: Dictionary, birth: Dictionary, memories: Array) -> Dictionary:
	"""
	玩家确认转生后，生成新角色数据。
	"""
	var new_entity = {
		"id": -1,  # WorldManager 会分配
		"entity_name": birth.get("name", "无名"),
		"entity_type": "player",
		"location": birth.get("location", "无名村"),
		"era": era + 1,
		"stats": stats,
		"realm": "无",
		"realm_level": 0,
		"age": 0,
		"hp": stats.get("max_hp", 100),
		"mp": stats.get("max_mp", 50),
		"memory_fragments": memories,
		"reincarnation_bonuses": {},
		"created_legacies": [],
	}
	return new_entity


func _calculate_rewards(summary: LifeSummary) -> Dictionary:
	"""
	根据一世成就计算轮回奖励。
	遵循设计文档中的奖励规则：
	- 境界成就 → 悟性+2
	- 社交成就 → 魅力+2
	- 战斗成就 → 力量+1, 敏捷+1
	- 传说成就 → 记忆槽+1
	- 寿终正寝 → 生命上限+10
	"""
	var rewards = {
		"stat_bonuses": {},
		"memory_slots": 1,
		"talents": [],
		"reputation_effects": {},
		"special_unlocks": [],
	}

	# 境界成就
	var realm_idx = REALM_ORDER.find(summary.realm_reached)
	if realm_idx >= REALM_ORDER.find("武师"):
		rewards.stat_bonuses["comprehension"] = rewards.stat_bonuses.get("comprehension", 0) + 2
		rewards.talents.append("修行者之心")

	# 社交成就
	if summary.relationships_formed >= 10:
		rewards.stat_bonuses["charisma"] = rewards.stat_bonuses.get("charisma", 0) + 2
		rewards.talents.append("社交达人")

	# 战斗成就
	if summary.enemies_made >= 5:
		rewards.stat_bonuses["strength"] = rewards.stat_bonuses.get("strength", 0) + 1
		rewards.stat_bonuses["agility"] = rewards.stat_bonuses.get("agility", 0) + 1

	# 传说成就
	if summary.legends_created >= 1:
		rewards.memory_slots += 1
		rewards.talents.append("传说之源")

	# 寿终正寝
	if summary.cause_of_death == "natural":
		rewards.stat_bonuses["max_hp"] = rewards.stat_bonuses.get("max_hp", 0) + 10
		rewards.talents.append("善终者")

	# 帮助他人
	if summary.people_helped >= 10:
		rewards.talents.append("助人为乐")
		rewards.reputation_effects["kindness"] = 20
		rewards.stat_bonuses["charisma"] = rewards.stat_bonuses.get("charisma", 0) + 1

	# 杀害无辜
	if summary.innocents_killed >= 1:
		rewards.talents.append("手上沾血")
		rewards.reputation_effects["cruelty"] = -20
		rewards.stat_bonuses["charisma"] = rewards.stat_bonuses.get("charisma", 0) - 1
		rewards.stat_bonuses["strength"] = rewards.stat_bonuses.get("strength", 0) + 1

	# 建立势力
	if summary.factions_founded >= 1:
		rewards.stat_bonuses["all"] = rewards.stat_bonuses.get("all", 0) + 1

	return rewards


func _calculate_inherited_stats(summary: LifeSummary, rewards: Dictionary) -> Dictionary:
	"""
	计算转生后的初始属性。
	基础: 前世巅峰 × 继承率 (力量0.1, 敏捷0.1, 悟性0.15, 魅力0.1)
	奖励: 轮回奖励中的 stat_bonuses
	出生: 出生身份的 stat_bonus
	"""
	var base_inheritance = {
		"strength": max(1, int(summary.peak_strength * 0.1)),
		"agility": max(1, int(summary.peak_agility * 0.1)),
		"comprehension": max(1, int(summary.peak_comprehension * 0.15)),
		"charisma": max(1, int(summary.peak_charisma * 0.1)),
	}

	# 如果轮回天赋包含"武者之心"，力量继承率翻倍
	var has_warrior_spirit = "warrior_spirit" in \
		_unlock_talents(summary).map(func(t): return t["id"])
	if has_warrior_spirit:
		base_inheritance["strength"] = max(1, int(summary.peak_strength * 0.2))

	var stats = base_inheritance
	var bonuses = rewards.get("stat_bonuses", {})
	for stat, val in bonuses:
		if stat in stats:
			stats[stat] = stats[stat] + val
		elif stat == "all":
			for s in stats:
				stats[s] = stats[s] + val
		elif stat == "max_hp" or stat == "max_mp":
			stats[stat] = val

	return stats


func _assign_birth(summary: LifeSummary, rewards: Dictionary) -> Dictionary:
	"""
	分配出生身份和地点。
	受前世影响：高魅力→可能出生贵族，高力量→猎户，高悟性→书生
	"""
	# 根据前世巅峰属性选择出生身份
	var weighted_pool = []
	var base_weight = 1.0

	# 高力量更可能出生为猎户
	if summary.peak_strength >= 8:
		weighted_pool.append({"identity": "hunter", "weight": 3.0})
	if summary.peak_strength >= 12:
		weighted_pool.append({"identity": "beggar", "weight": 2.0})

	# 高悟性更可能出生为书生/僧侣
	if summary.peak_comprehension >= 8:
		weighted_pool.append({"identity": "scholar", "weight": 3.0})
	if summary.peak_comprehension >= 12:
		weighted_pool.append({"identity": "monk", "weight": 2.0})

	# 高魅力更可能出生为商人/贵族
	if summary.peak_charisma >= 8:
		weighted_pool.append({"identity": "merchant", "weight": 3.0})
	if summary.peak_charisma >= 12:
		weighted_pool.append({"identity": "noble", "weight": 2.0})

	# 默认加入所有身份
	for id_key in BIRTH_IDENTITIES:
		var found = false
		for item in weighted_pool:
			if item["identity"] == id_key:
				found = true
				break
		if not found:
			weighted_pool.append({"identity": id_key, "weight": base_weight})

	# 按权重随机选择
	var total_weight = 0.0
	for item in weighted_pool:
		total_weight += item["weight"]

	var roll = randf() * total_weight
	var cumulative = 0.0
	var chosen = "peasant"
	for item in weighted_pool:
		cumulative += item["weight"]
		if roll <= cumulative:
			chosen = item["identity"]
			break

	var identity = BIRTH_IDENTITIES[chosen]
	return {
		"identity": chosen,
		"name": identity["name"],
		"stat_bonus": identity["stat_bonus"],
		"location": _random_birth_place(),
	}


func _random_birth_place() -> String:
	"""随机出生地点池"""
	var places = [
		"落霞村", "青风镇", "铁剑村", "杏花村",
		"江城", "云来镇", "无名谷", "桃源村",
	]
	return places[randi() % places.size()]


func _unlock_talents(summary: LifeSummary) -> Array:
	"""
	检查并解锁可用的轮回天赋。
	"""
	var unlocked = []
	for talent_id, talent_def in REINCARNATION_TALENTS:
		if _check_unlock_condition(talent_def["unlock_condition"], summary):
			unlocked.append({
				"id": talent_id,
				"name": talent_def["name"],
				"desc": talent_def["desc"],
			})
	return unlocked


func _check_unlock_condition(condition: String, summary: LifeSummary) -> bool:
	"""
	检查天赋解锁条件。
	支持简单表达式: 'field operator value'
	"""
	var parts = condition.split(" ")
	if parts.size() < 3:
		return false

	var field = parts[0]
	var op = parts[1]
	var value = parts[2]

	# 获取 summary 字段值
	var val: Variant = summary.get(field)
	if val == null:
		return false

	var target = int(value) if value.is_valid_int() else value

	match op:
		">=": return val >= target
		">": return val > target
		"<": return val < target
		"<=": return val <= target
		"==": return val == target
		"!=": return val != target
		_: return false


func _get_available_fragments(summary: LifeSummary) -> Array:
	"""
	获取可供选择的记忆碎片列表。
	按 intensity 排序，高优先。
	"""
	var fragments = summary.memory_fragments.duplicate()
	fragments.sort_custom(func(a, b): return a.get("intensity", 0) > b.get("intensity", 0))
	return fragments


func simulate_death(entity_data: CharacterData) -> LifeSummary:
	"""
	根据角色当前状态模拟一世总结。
	用于死亡时的自动总结生成。
	"""
	# TODO: 从 GameManager 获取实际游戏时间
	var summary = LifeSummary.new()
	summary.character_name = entity_data.entity_name
	summary.peak_strength = entity_data.get_stat("strength")
	summary.peak_agility = entity_data.get_stat("agility")
	summary.peak_comprehension = entity_data.get_stat("comprehension")
	summary.peak_charisma = entity_data.get_stat("charisma")
	summary.realm_reached = entity_data.realm
	summary.realm_level = entity_data.realm_level
	summary.age_at_death = entity_data.age
	# TODO: 从 WorldManager 获取更多数据
	return summary

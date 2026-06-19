## LifeSummary — 一世总结数据
## 记录玩家一世的完整经历，用于转生时的总结和奖励计算
class_name LifeSummary
extends Resource

@export var era: int = 0                       # 第几世
@export var character_name: String = "无名"      # 本世角色名
@export var birth_place: String = ""             # 出生地
@export var death_place: String = ""             # 死亡地
@export var cause_of_death: String = "unknown"   # 死因: natural, combat, accident, choice
@export var age_at_death: int = 0                # 死亡年龄
@export var realm_reached: String = "无"          # 达到的境界
@export var realm_level: int = 0                 # 境界等级

@export var achievements: Array[String] = []      # 本世成就
@export var key_choices: Array[Dictionary] = []   # 关键选择记录

@export var relationships_formed: int = 0         # 建立的关系数
@export var enemies_made: int = 0                 # 树敌数
@export var legends_created: int = 0              # 创建的传说数
@export var people_helped: int = 0                # 帮助人数
@export var innocents_killed: int = 0             # 杀害无辜数
@export var factions_founded: int = 0             # 建立势力数

@export var peak_strength: int = 5                # 前世最高力量
@export var peak_agility: int = 5                 # 前世最高敏捷
@export var peak_comprehension: int = 5           # 前世最高悟性
@export var peak_charisma: int = 5                # 前世最高魅力

@export var memory_fragments: Array[Dictionary] = []  # 保留的记忆碎片
@export var legend_memories: Array[Dictionary] = []   # 传说级记忆（自动保留）

@export var playtime_seconds: float = 0.0         # 本世总游戏时间


func to_dict() -> Dictionary:
	return {
		"era": era,
		"character_name": character_name,
		"birth_place": birth_place,
		"death_place": death_place,
		"cause_of_death": cause_of_death,
		"age_at_death": age_at_death,
		"realm_reached": realm_reached,
		"realm_level": realm_level,
		"achievements": achievements.duplicate(),
		"key_choices": key_choices.duplicate(true),
		"relationships_formed": relationships_formed,
		"enemies_made": enemies_made,
		"legends_created": legends_created,
		"people_helped": people_helped,
		"innocents_killed": innocents_killed,
		"factions_founded": factions_founded,
		"peak_strength": peak_strength,
		"peak_agility": peak_agility,
		"peak_comprehension": peak_comprehension,
		"peak_charisma": peak_charisma,
		"memory_fragments": memory_fragments.duplicate(true),
		"legend_memories": legend_memories.duplicate(true),
		"playtime_seconds": playtime_seconds,
	}


func summarize() -> String:
	## 生成一世总结文本（程序端，不调用模型）
	var lines: PackedStringArray = []
	lines.append("第 %d 世 — %s" % [era, character_name])
	lines.append("")
	lines.append("出生地: %s" % birth_place)
	lines.append("死亡地: %s | 死因: %s | 享年: %d" % [death_place, _death_cause_label(), age_at_death])
	lines.append("境界: %s (Lv.%d)" % [realm_reached, realm_level])
	lines.append("")

	if achievements.size() > 0:
		lines.append("== 本世成就 ==")
		for a in achievements:
			lines.append("  - %s" % a)
		lines.append("")

	lines.append("== 统计 ==")
	lines.append("建立关系: %d | 树敌: %d | 帮助: %d | 传说: %d | 势力: %d" % [
		relationships_formed, enemies_made, people_helped, legends_created, factions_founded
	])
	lines.append("巅峰属性: 力量%d 敏捷%d 悟性%d 魅力%d" % [
		peak_strength, peak_agility, peak_comprehension, peak_charisma
	])
	if memory_fragments.size() > 0:
		lines.append("")
		lines.append("保留记忆: %d 个碎片" % memory_fragments.size())

	return "\n".join(lines)


func _death_cause_label() -> String:
	match cause_of_death:
		"natural": return "寿终正寝"
		"combat": return "战死"
		"accident": return "意外"
		"choice": return "兵解转世"
		_: return cause_of_death

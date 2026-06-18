## CharacterData — 角色数据
class_name CharacterData
extends EntityData

@export var stats: Dictionary = {
	"strength": 5,
	"agility": 5,
	"comprehension": 5,
	"charisma": 5
}
@export var realm: String = "乞丐"
@export var realm_level: int = 1
@export var hp: int = 100
@export var max_hp: int = 100
@export var mp: int = 50
@export var max_mp: int = 50
@export var experience: int = 0
@export var age: int = 16
@export var lifespan: int = 80  # 自然寿命
@export var skills: Array[String] = []
@export var personality: Dictionary = {
	"openness": 5,
	"conscientiousness": 5,
	"extraversion": 5,
	"agreeableness": 5,
	"neuroticism": 5
}

# 前世记忆碎片
@export var memory_fragments: Array[Dictionary] = []
# 轮回奖励
@export var reincarnation_bonuses: Dictionary = {}
# 遗产数据
@export var legacy_id: int = -1  # 关联的遗产ID
@export var legacy_effects: Dictionary = {}  # 受到的遗产影响
@export var created_legacies: Array[int] = []  # 创造的遗产ID列表

func get_stat(stat_name: String) -> int:
	return stats.get(stat_name, 0)

func set_stat(stat_name: String, value: int) -> void:
	stats[stat_name] = value

func add_skill(skill_name: String) -> void:
	if not skills.has(skill_name):
		skills.append(skill_name)

func has_skill(skill_name: String) -> bool:
	return skills.has(skill_name)

func to_dict() -> Dictionary:
	var base = super.to_dict()
	base.merge({
		"stats": stats.duplicate(),
		"realm": realm,
		"realm_level": realm_level,
		"hp": hp,
		"max_hp": max_hp,
		"mp": mp,
		"max_mp": max_mp,
		"experience": experience,
		"age": age,
		"lifespan": lifespan,
		"skills": skills.duplicate(),
		"personality": personality.duplicate(),
		"memory_fragments": memory_fragments.duplicate(true),
		"reincarnation_bonuses": reincarnation_bonuses.duplicate()
	})
	return base

static func from_dict(data: Dictionary) -> CharacterData:
	var char = CharacterData.new()
	char.id = data.get("id", -1)
	char.entity_name = data.get("name", "")
	char.entity_type = data.get("type", "npc")
	char.location = data.get("location", "")
	char.stats = data.get("stats", char.stats)
	char.realm = data.get("realm", "乞丐")
	char.realm_level = data.get("realm_level", 1)
	char.hp = data.get("hp", 100)
	char.max_hp = data.get("max_hp", 100)
	char.mp = data.get("mp", 50)
	char.max_mp = data.get("max_mp", 50)
	char.experience = data.get("experience", 0)
	char.age = data.get("age", 16)
	char.lifespan = data.get("lifespan", 80)
	char.skills = data.get("skills", [])
	char.personality = data.get("personality", char.personality)
	char.memory_fragments = data.get("memory_fragments", [])
	char.reincarnation_bonuses = data.get("reincarnation_bonuses", {})
	return char

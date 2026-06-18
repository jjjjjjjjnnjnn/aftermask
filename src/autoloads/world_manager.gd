## WorldManager — 世界状态管理
extends Node

# === 世界时间 ===
var world_time: Dictionary = {
	"day": 1,
	"hour": 8,
	"minute": 0,
	"season": "spring",
	"year": 1
}

# === 世界状态 ===
var current_location: String = "落霞村"
var active_era: int = 1
var weather: String = "clear"
var world_events: Array[Dictionary] = []

# === 实体注册表 ===
var entities: Dictionary = {}  # { entity_id: entity_data }
var next_entity_id: int = 0

# === 地点定义 ===
var locations: Dictionary = {
	"落霞村": {
		"description": "一个宁静的小村庄，百世江湖的起点",
		"connections": ["官道"],
		"npcs": [],
		"danger_level": 0
	},
	"醉仙楼客栈": {
		"description": "江湖消息的汇集地，三教九流在此交汇",
		"connections": ["官道"],
		"npcs": [],
		"danger_level": 1
	},
	"铁掌门武馆": {
		"description": "正派武馆，传授基础武学",
		"connections": ["官道"],
		"npcs": [],
		"danger_level": 1
	},
	"野猪林": {
		"description": "危险的森林，有低级野兽出没",
		"connections": ["官道"],
		"npcs": [],
		"danger_level": 3
	},
	"官道": {
		"description": "连接各地的主要道路",
		"connections": ["落霞村", "醉仙楼客栈", "铁掌门武馆", "野猪林"],
		"npcs": [],
		"danger_level": 1
	}
}

func _ready() -> void:
	pass

func initialize_world() -> void:
	world_time = {"day": 1, "hour": 8, "minute": 0, "season": "spring", "year": 1}
	current_location = "落霞村"
	active_era = 1
	entities.clear()
	next_entity_id = 0
	world_events.clear()

func register_entity(entity_data: Dictionary) -> int:
	var id = next_entity_id
	next_entity_id += 1
	entities[id] = entity_data
	entities[id]["id"] = id
	EventBus.entity_spawned.emit(id, entity_data.get("type", "unknown"), entity_data.get("position", Vector2.ZERO))
	return id

func remove_entity(entity_id: int) -> void:
	if entities.has(entity_id):
		entities.erase(entity_id)

func get_entity(entity_id: int) -> Dictionary:
	return entities.get(entity_id, {})

func advance_time(minutes: int = 30) -> void:
	world_time["minute"] += minutes
	while world_time["minute"] >= 60:
		world_time["minute"] -= 60
		world_time["hour"] += 1
	while world_time["hour"] >= 24:
		world_time["hour"] -= 24
		world_time["day"] += 1
	
	# 季节变化（简化：30天一季）
	var season_index = ["spring", "summer", "autumn", "winter"].find(world_time["season"])
	if world_time["day"] > 30:
		world_time["day"] = 1
		season_index = (season_index + 1) % 4
		world_time["season"] = ["spring", "summer", "autumn", "winter"][season_index]
		if season_index == 0:
			world_time["year"] += 1
	
	EventBus.time_advanced.emit(world_time)

func change_location(location_name: String) -> bool:
	if locations.has(location_name):
		current_location = location_name
		return true
	return false

func get_npcs_at_location(location_name: String) -> Array:
	var npcs = []
	for entity_id in entities:
		var entity = entities[entity_id]
		if entity.get("type") == "npc" and entity.get("location") == location_name:
			npcs.append(entity)
	return npcs

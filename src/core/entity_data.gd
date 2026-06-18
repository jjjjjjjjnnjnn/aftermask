## EntityData — 实体数据基类
class_name EntityData
extends Resource

@export var id: int = -1
@export var entity_name: String = ""
@export var entity_type: String = ""  # "player", "npc", "item", "creature"
@export var location: String = ""

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": entity_name,
		"type": entity_type,
		"location": location
	}

static func from_dict(data: Dictionary) -> EntityData:
	var entity = EntityData.new()
	entity.id = data.get("id", -1)
	entity.entity_name = data.get("name", "")
	entity.entity_type = data.get("type", "")
	entity.location = data.get("location", "")
	return entity

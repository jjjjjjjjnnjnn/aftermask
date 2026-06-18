## MemoryRecord — 记忆记录
class_name MemoryRecord
extends Resource

@export var id: int = -1
@export var entity_id: int = -1
@export var event_type: String = ""  # "positive", "negative", "neutral", "legend"
@export var event_description: String = ""
@export var importance: int = 1  # 1-10, 影响记忆保留时间
@export var timestamp: Dictionary = {}  # 世界时间
@export var era: int = 1
@export var related_entities: Array[int] = []
@export var decay_rate: float = 0.1  # 每天衰减率

func to_dict() -> Dictionary:
	return {
		"id": id,
		"entity_id": entity_id,
		"event_type": event_type,
		"event_description": event_description,
		"importance": importance,
		"timestamp": timestamp.duplicate(),
		"era": era,
		"related_entities": related_entities.duplicate(),
		"decay_rate": decay_rate
	}

static func from_dict(data: Dictionary) -> MemoryRecord:
	var mem = MemoryRecord.new()
	mem.id = data.get("id", -1)
	mem.entity_id = data.get("entity_id", -1)
	mem.event_type = data.get("event_type", "")
	mem.event_description = data.get("event_description", "")
	mem.importance = data.get("importance", 1)
	mem.timestamp = data.get("timestamp", {})
	mem.era = data.get("era", 1)
	mem.related_entities = data.get("related_entities", [])
	mem.decay_rate = data.get("decay_rate", 0.1)
	return mem

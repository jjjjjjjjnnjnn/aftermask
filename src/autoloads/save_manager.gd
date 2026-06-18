## SaveManager — 存档系统
extends Node

const SAVE_DIR = "user://saves/"
const SAVE_VERSION = "0.1.0"

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func save_game(slot: int = 0) -> bool:
	var save_data = _collect_save_data()
	var save_path = SAVE_DIR + "save_%d.json" % slot
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("无法保存游戏: %s" % save_path)
		return false
	
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	
	EventBus.game_saved.emit(save_data)
	return true

func load_game(slot: int = 0) -> bool:
	var save_path = SAVE_DIR + "save_%d.json" % slot
	
	if not FileAccess.file_exists(save_path):
		push_error("存档不存在: %s" % save_path)
		return false
	
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		push_error("无法读取存档: %s" % save_path)
		return false
	
	var json = JSON.new()
	var parse_result = json.parse(file.get_as_text())
	file.close()
	
	if parse_result != OK:
		push_error("存档格式错误")
		return false
	
	var save_data = json.data
	if save_data.get("version") != SAVE_VERSION:
		push_warning("存档版本不匹配，可能存在问题")
	
	_apply_save_data(save_data)
	EventBus.game_loaded.emit(save_data)
	return true

func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "save_%d.json" % slot)

func delete_save(slot: int = 0) -> void:
	var save_path = SAVE_DIR + "save_%d.json" % slot
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)

func _collect_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"era": WorldManager.active_era,
		"world_time": WorldManager.world_time.duplicate(),
		"current_location": WorldManager.current_location,
		"entities": WorldManager.entities.duplicate(true),
		"next_entity_id": WorldManager.next_entity_id,
		"history": []  # TODO: 从MemorySystem获取
	}

func _apply_save_data(data: Dictionary) -> void:
	WorldManager.active_era = data.get("era", 1)
	WorldManager.world_time = data.get("world_time", WorldManager.world_time)
	WorldManager.current_location = data.get("current_location", "落霞村")
	WorldManager.entities = data.get("entities", {})
	WorldManager.next_entity_id = data.get("next_entity_id", 0)
	# TODO: 恢复MemorySystem数据

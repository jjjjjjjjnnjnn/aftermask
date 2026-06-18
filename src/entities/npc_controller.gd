## NPCController — NPC行为控制器
extends Node2D

@export var entity_id: int = -1
@export var npc_data: CharacterData

enum NPCState { IDLE, WALKING, TALKING, WORKING, SLEEPING }

var current_state: NPCState = NPCState.IDLE
var target_position: Vector2 = Vector2.ZERO
var interaction_range: float = 50.0

func _ready() -> void:
	# 连接信号
	EventBus.memory_recorded.connect(_on_memory_recorded)

func _physics_process(delta: float) -> void:
	match current_state:
		NPCState.IDLE:
			_process_idle(delta)
		NPCState.WALKING:
			_process_walking(delta)
		NPCState.TALKING:
			pass
		NPCState.WORKING:
			pass
		NPCState.SLEEPING:
			pass

func _process_idle(delta: float) -> void:
	# 简单的闲置AI：随机移动
	if randf() < 0.01:  # 1%概率开始移动
		_start_walking()

func _process_walking(delta: float) -> void:
	var direction = (target_position - position).normalized()
	position += direction * 50.0 * delta
	
	if position.distance_to(target_position) < 5.0:
		current_state = NPCState.IDLE

func _start_walking() -> void:
	target_position = position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
	current_state = NPCState.WALKING

func interact() -> void:
	if npc_data == null:
		return
	
	# 触发对话
	EventBus.dialogue_started.emit(entity_id, {
		"npc_name": npc_data.entity_name,
		"npc_id": entity_id,
		"greeting": _get_greeting()
	})
	current_state = NPCState.TALKING

func _get_greeting() -> String:
	# 根据关系值选择问候语
	var base_greeting = "你好，旅人。"
	# TODO: 根据memory系统调整问候语
	return base_greeting

func _on_memory_recorded(recorded_entity_id: int, event_type: String, event_data: Dictionary) -> void:
	# 如果是关于自己的记忆，调整行为
	if recorded_entity_id == entity_id:
		_process_memory(event_type, event_data)

func _process_memory(event_type: String, event_data: Dictionary) -> void:
	# TODO: 根据记忆调整NPC态度和行为
	pass

## MainGame — 主游戏场景控制器
extends Node2D

@onready var world_view: Node2D = %WorldView
@onready var ui_layer: CanvasLayer = %UILayer
@onready var hud: Control = %HUD
@onready var dialogue_panel: Control = %DialoguePanel
@onready var location_label: Label = %LocationLabel
@onready var time_label: Label = %TimeLabel
@onready var era_label: Label = %EraLabel

func _ready() -> void:
	EventBus.time_advanced.connect(_on_time_advanced)
	EventBus.entity_spawned.connect(_on_entity_spawned)
	EventBus.entity_died.connect(_on_entity_died)
	EventBus.world_event_triggered.connect(_on_world_event)
	_update_hud()

func _exit_tree() -> void:
	if EventBus.time_advanced.is_connected(_on_time_advanced):
		EventBus.time_advanced.disconnect(_on_time_advanced)
	if EventBus.entity_spawned.is_connected(_on_entity_spawned):
		EventBus.entity_spawned.disconnect(_on_entity_spawned)
	if EventBus.entity_died.is_connected(_on_entity_died):
		EventBus.entity_died.disconnect(_on_entity_died)
	if EventBus.world_event_triggered.is_connected(_on_world_event):
		EventBus.world_event_triggered.disconnect(_on_world_event)

func _on_time_advanced(new_time: Dictionary) -> void:
	_update_time_display(new_time)

func _on_entity_spawned(entity_id: int, entity_type: String, position: Vector2) -> void:
	# TODO: 在世界视图中创建实体可视化
	pass

func _on_entity_died(entity_id: int, cause: String) -> void:
	# TODO: 处理实体死亡
	pass

func _on_world_event(event_data: Dictionary) -> void:
	# TODO: 显示世界事件通知
	pass

func _update_hud() -> void:
	_update_location_display()
	_update_time_display(WorldManager.world_time)
	_update_era_display()

func _update_location_display() -> void:
	if location_label:
		location_label.text = WorldManager.current_location

func _update_time_display(time: Dictionary) -> void:
	if time_label:
		var season_names: Dictionary = {"spring": "春", "summer": "夏", "autumn": "秋", "winter": "冬"}
		time_label.text = "%s年 %s%d日 %02d:%02d" % [
			time.get("year", 1),
			season_names.get(time.get("season", "spring"), "春"),
			time.get("day", 1),
			time.get("hour", 8),
			time.get("minute", 0)
		]

func _update_era_display() -> void:
	if era_label:
		era_label.text = "第%d世" % WorldManager.active_era

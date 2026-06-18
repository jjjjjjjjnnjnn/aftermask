## PlayerController — 玩家控制器
extends Node2D

@export var speed: float = 200.0
@export var entity_id: int = -1

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# 获取输入
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	
	velocity = velocity.normalized() * speed
	
	# 移动
	position += velocity * delta
	
	# 发送移动事件
	if velocity.length() > 0:
		EventBus.entity_moved.emit(entity_id, position - velocity * delta, position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("open_menu"):
		_toggle_menu()

func _try_interact() -> void:
	# TODO: 检测附近NPC并触发交互
	pass

func _toggle_menu() -> void:
	# TODO: 打开/关闭菜单
	GameManager.change_state(GameManager.GameState.INVENTORY)

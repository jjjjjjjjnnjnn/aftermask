## GameManager — 游戏生命周期管理
extends Node

enum GameState { MENU, PLAYING, PAUSED, DIALOGUE, COMBAT, INVENTORY }

var current_state: GameState = GameState.MENU
var state_history: Array[GameState] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_state(new_state: GameState) -> void:
	if new_state == current_state:
		return
	state_history.append(current_state)
	current_state = new_state
	
	match new_state:
		GameState.MENU:
			get_tree().paused = false
		GameState.PLAYING:
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.DIALOGUE:
			pass
		GameState.COMBAT:
			pass
		GameState.INVENTORY:
			pass

func go_back_state() -> void:
	if state_history.size() > 0:
		current_state = state_history.pop_back()

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func start_new_game() -> void:
	WorldManager.initialize_world()
	change_state(GameState.PLAYING)

func save_game() -> void:
	SaveManager.save_game()

func load_game() -> bool:
	if SaveManager.load_game():
		change_state(GameState.PLAYING)
		return true
	return false

func quit_game() -> void:
	get_tree().quit()

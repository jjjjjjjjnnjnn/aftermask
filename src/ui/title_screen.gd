## TitleScreen — 标题画面
extends Control

@onready var new_game_button: Button = %NewGameButton
@onready var load_game_button: Button = %LoadGameButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	load_game_button.disabled = not SaveManager.has_save()
	
	# 标题动画
	_animate_title()

func _animate_title() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5)

func _on_new_game_pressed() -> void:
	GameManager.start_new_game()
	# TODO: 切换到角色创建场景

func _on_load_game_pressed() -> void:
	if SaveManager.load_game():
		# TODO: 切换到游戏场景
		pass

func _on_settings_pressed() -> void:
	# TODO: 打开设置菜单
	pass

func _on_quit_pressed() -> void:
	GameManager.quit_game()

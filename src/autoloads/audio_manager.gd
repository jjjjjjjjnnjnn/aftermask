## AudioManager — 音频管理
extends Node

var music_volume: float = 0.8
var sfx_volume: float = 1.0
var current_music: String = ""

func _ready() -> void:
	pass

func play_sfx(sfx_name: String) -> void:
	# TODO: 实现音效播放
	pass

func play_music(track_name: String, fade_time: float = 1.0) -> void:
	if track_name == current_music:
		return
	current_music = track_name
	# TODO: 实现音乐淡入淡出

func stop_music(fade_time: float = 1.0) -> void:
	current_music = ""
	# TODO: 实现音乐淡出

func set_music_volume(vol: float) -> void:
	music_volume = clamp(vol, 0.0, 1.0)

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)

## MMLClient — Minimal Model Loader Client
##
## Godot 侧 LLM 客户端，与 BWKI Python 侧共用同一 TaskRequest/TaskResponse 协议。
##
## 调用方式（注册为 Autoload 后全局可用）:
##   var response = MMLClient.generate("npc_dialogue", "你好，勇士！")
##   if response.success:
##       print("NPC 说: ", response.raw_text)
##   else:
##       printerr("模型不可用: ", response.error)
##
## 底层: 直接调用 llama-cli.exe (进程级)，无 HTTP/服务/Ollama 中间层。
extends Node

# ============================================================
# 任务类型 (与 Python TaskType 对应)
# ============================================================
enum TaskType {
	CONCEPT_EXTRACTION,    # 概念提取
	NPC_DIALOGUE,          # NPC 对话
	BIOGRAPHY,             # 一世传记
	TRANSLATION,            # 翻译
	ANNOTATION_ASSIST,     # 标注辅助
}

# ============================================================
# 响应结构 (与 Python TaskResponse 对应)
# ============================================================
class MMLResponse:
	var task: int           # TaskType enum
	var raw_text: String    # 生成的文本
	var confidence: float   # 置信度 0-1
	var latency_ms: float   # 延迟毫秒
	var error: String       # 错误信息，成功时为空

	var _success: bool = false

	func _init(p_task: int, p_raw: String, p_latency: float, p_error: String = ""):
		task = p_task
		raw_text = p_raw
		latency_ms = p_latency
		error = p_error
		_success = p_error.is_empty()

	func is_success() -> bool:
		return _success


# ============================================================
# 配置 — 自动发现，优先使用纯 ASCII 路径
# ============================================================
const DEFAULT_MODEL: String = "res://ai-runtime/models/qwen2.5-0.5b-q4_k_m.gguf"
const DEFAULT_CLI: String = "res://ai-runtime/llama/llama-cli.exe"

# 纯 ASCII 路径（无中文，避免编码问题）
const FALLBACK_MODEL: String = "C:/Users/rongj/Desktop/mml-runtime/models/qwen2.5-0.5b-q4_k_m.gguf"
const FALLBACK_CLI: String = "C:/Users/rongj/Desktop/mml-runtime/llama/llama-cli.exe"

const DEFAULT_THREADS: int = 4
const DEFAULT_CTX: int = 2048

# 运行时缓存 — 避免每次重新加载
var _last_response: MMLResponse = null
var _total_calls: int = 0
var _total_latency_ms: float = 0.0


# ============================================================
# 核心 API
# ============================================================

## 生成文本 — 同步调用（阻塞直到推理完成）
##
## task_type: TaskType enum
## prompt: 输入文本
## system_prompt: 可选系统提示
## max_tokens: 最大生成长度
## temperature: 生成温度 (0.0-1.0)
func generate(
	task_type: int = TaskType.NPC_DIALOGUE,
	prompt: String = "",
	system_prompt: String = "",
	max_tokens: int = 128,
	temperature: float = 0.3
) -> MMLResponse:
	_total_calls += 1
	var start_time = Time.get_ticks_usec()

	# 1. 构建模型输入
	var full_prompt = _build_prompt(prompt, system_prompt)

	# 2. 自动发现模型和 llama-cli 路径
	var model_path = _find_model()
	var cli_path = _find_cli()

	if model_path.is_empty() or cli_path.is_empty():
		var elapsed = (Time.get_ticks_usec() - start_time) / 1000.0
		var err_msg = "模型或 llama-cli 未找到。请检查项目内 ai-runtime/models/ 或 共享 mml-runtime/ 目录。"
		push_warning("[MML] " + err_msg)
		return MMLResponse.new(task_type, "", elapsed, err_msg)

	# 3. 调用 llama-cli
	var args: PackedStringArray = [
		"-m", model_path,
		"-p", full_prompt,
		"-n", str(max_tokens),
		"--temp", str(temperature),
		"--threads", str(DEFAULT_THREADS),
		"--ctx-size", str(DEFAULT_CTX),
		"--no-display-prompt",
		"--silent-prompt",
	]

	var output: Array = []
	var exit_code: int = OS.execute(cli_path, args, output, true)
	var elapsed = (Time.get_ticks_usec() - start_time) / 1000.0
	_total_latency_ms += elapsed

	# 4. 处理输出
	if exit_code != 0:
		var err_msg = "llama-cli 退出码: %d" % exit_code
		push_warning("[MML] " + err_msg)
		return MMLResponse.new(task_type, "", elapsed, err_msg)

	if output.is_empty():
		return MMLResponse.new(task_type, "", elapsed, "模型无输出")

	var raw = _clean_output(output[0])
	if raw.is_empty():
		raw = "(模型返回空)"

	_last_response = MMLResponse.new(task_type, raw, elapsed)
	return _last_response


## 检查模型是否可用
func is_available() -> bool:
	return not _find_model().is_empty() and not _find_cli().is_empty()


## 统计信息
func stats() -> Dictionary:
	var model_path = _find_model()
	var model_size = 0.0
	if not model_path.is_empty():
		var file = FileAccess.open(model_path, FileAccess.READ)
		if file:
			model_size = file.get_length() / (1024.0 * 1024.0)
			file.close()

	return {
		"total_calls": _total_calls,
		"total_latency_ms": _total_latency_ms,
		"avg_latency_ms": _total_latency_ms / max(_total_calls, 1),
		"model_size_mb": model_size,
	}


# ============================================================
# 内部方法
# ============================================================

func _build_prompt(prompt: String, system: String) -> String:
	## Qwen2.5 ChatML 格式
	var sys = system if not system.is_empty() else "You are a helpful assistant."
	return "<|system|>\n%s\n<|user|>\n%s\n<|assistant|>\n" % [sys, prompt]


func _clean_output(raw: String) -> String:
	## 去除 llama.cpp 的输出噪音
	var lines = raw.split("\n")
	var result: PackedStringArray = []
	var in_response := false

	for line in lines:
		if "<|assistant|>" in line:
			in_response = true
			continue
		if not in_response:
			continue
		# 跳过速度/计时行
		if line.begins_with("[") and ("t/s" in line or "tokens/s" in line):
			continue
		if line.begins_with(">") or line.begins_with("/"):
			continue
		if line.strip_edges().is_empty():
			continue
		result.append(line)

	return "\n".join(result)


func _find_model() -> String:
	## 自动发现模型文件：优先纯 ASCII 路径（避免 CJK 编码问题）
	var paths = [
		FALLBACK_MODEL,
		_resolve_res_path(DEFAULT_MODEL),
	]
	for p in paths:
		if p.is_empty():
			continue
		if FileAccess.file_exists(p):
			return p
	return ""


func _find_cli() -> String:
	## 自动发现 llama-cli：优先纯 ASCII 路径
	var paths = [
		FALLBACK_CLI,
		_resolve_res_path(DEFAULT_CLI),
	]
	for p in paths:
		if p.is_empty():
			continue
		if FileAccess.file_exists(p):
			return p
	return ""


func _resolve_res_path(res_path: String) -> String:
	## Godot res:// → 绝对路径
	if res_path.begins_with("res://"):
		var abs = ProjectSettings.globalize_path(res_path)
		return abs
	return res_path


func _get_model_size_mb() -> float:
	## 获取模型文件大小
	var path = _resolve_path(DEFAULT_MODEL)
	if path.is_empty():
		return 0.0
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return 0.0
	var size = file.get_length()
	file.close()
	return size / (1024.0 * 1024.0)

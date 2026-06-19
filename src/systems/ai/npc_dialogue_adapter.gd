## LinguaCore — NPCDialogueAdapter
## 连接 NPC 对话系统与 LocalProvider
## LinguaCore 架构: 状态机→Prompt Builder→模型→JSON→Parser→UI
class_name NPCDialogueAdapter
extends Node

## 引用 NPC 对话系统
@onready var dialogue_system: Node = get_node("/root/NPCDialogueSystem") if has_node("/root/NPCDialogueSystem") else null
@onready var mml_client: Node = get_node("/root/MMLClient") if has_node("/root/MMLClient") else null

## 规则系统覆盖 80%+ 的交互 → 零推理
var rule_only_calls: int = 0
var model_calls: int = 0


func handle_player_input(
	npc_profile: Dictionary,
	player_input: String
) -> Dictionary:
	"""
	处理玩家输入的完整管道。

	1. 程序端意图检测 (规则)
	2. 状态机更新
	3. 检查是否需要模型 (80%不需要)
	4. 需要模型 → PromptBuilder → LocalProvider → Parser
	5. 不需要模型 → 规则生成回复
	"""

	# === Step 1: 程序端意图检测 (零推理) ===
	var intent = _detect_intent(player_input)

	# === Step 2: 程序端 NPC 状态更新 ===
	var emotion = _calculate_emotion(npc_profile, intent)
	var relationship = npc_profile.get("relationship", 0)

	# === Step 3: 是否需要模型推理 ===
	# 规则表: 哪些意图不需要模型
	var is_rule_only = _is_rule_only_intent(intent, relationship)

	if is_rule_only:
		rule_only_calls += 1
		# 规则系统 → 零推理
		return _generate_rule_response(npc_profile, intent, emotion)

	# === Step 4: 模型推理 ===
	model_calls += 1
	return _generate_model_response(npc_profile, intent, emotion, player_input)


func _detect_intent(text: String) -> String:
	"""
	程序端意图检测，仅关键字匹配。
	0 推理，毫秒级。
	"""
	var t = text.to_lower()

	if "买" in t or "卖" in t or "交易" in t or "buy" in t or "sell" in t:
		return "trade"
	if "任务" in t or "需要帮忙" in t or "quest" in t or "help" in t:
		return "help"
	if "杀" in t or "毁" in t or "threat" in t or "kill" in t:
		return "threat"
	if "记得" in t or "认识" in t or "remember" in t or "recognize" in t:
		return "memory_trigger"
	if "走" in t or "再见" in t or "bye" in t or "goodbye" in t:
		return "farewell"
	if "听说" in t or "知道" in t or "news" in t or "gossip" in t:
		return "gossip"
	return "greeting"


func _calculate_emotion(npc: Dictionary, intent: String) -> String:
	"""程序端情感计算，基于关系和当前事件。"""
	var rel = npc.get("relationship", 0)
	if intent == "threat":
		return "angry" if rel >= 0 else "fearful"
	if intent == "help" and rel >= 30:
		return "grateful"
	if intent == "memory_trigger":
		return "surprised"
	if rel >= 50: return "friendly"
	if rel <= -30: return "angry"
	return "neutral"


func _is_rule_only_intent(intent: String, relationship: int) -> bool:
	"""
	检查是否可以用规则系统处理（零推理）。

	80%+ 场景不需要模型：
	- 日常打招呼 → 规则
	- 交易（固定台词）→ 规则
	- 威胁（固定反应）→ 规则
	- 告别 → 规则
	- 闲聊八卦 → 规则

	需要模型的场景：
	- 记忆触发（需要生成独特的回忆文本）
	- 关键剧情对话（需要理解复杂上下文）
	- 帮助（需要理解任务需求）
	"""
	# 关系极差：所有交互用规则（NPC不理你）
	if relationship <= -50:
		return true

	# 规则覆盖的意图
	var rule_only = [
		"greeting", "trade", "threat",
		"farewell", "gossip",
	]
	return intent in rule_only


func _generate_rule_response(npc: Dictionary, intent: String, emotion: String) -> Dictionary:
	"""
	规则生成回复（零推理）。
	返回与模型相同的 JSON 格式。
	"""
	var role = npc.get("role", "villager")
	var rel = npc.get("relationship", 0)
	var name = npc.get("name", "路人")

	match intent:
		"greeting":
			if rel >= 50:
				return {"reply": "%s：客官您来了！好久不见！" % [name], "action": "greet", "emotion": "friendly"}
			elif rel <= -20:
				return {"reply": "...（%s冷冷看了你一眼）" % [name], "action": "ignore", "emotion": "cold"}
			else:
				return {"reply": "%s：你好，有什么事吗？" % [name], "action": "greet", "emotion": "neutral"}

		"trade":
			match role:
				"innkeeper":
					return {"reply": "%s：住店一晚20文，吃饭另算。" % [name], "action": "show_menu", "emotion": "neutral"}
				"blacksmith":
					return {"reply": "%s：兵器架子上的都在这，看上哪个说。" % [name], "action": "show_inventory", "emotion": "neutral"}
				"merchant":
					return {"reply": "%s：来来来，我这什么都有！" % [name], "action": "show_inventory", "emotion": "friendly"}
				_:
					return {"reply": "%s：我不做买卖。" % [name], "action": "refuse", "emotion": "neutral"}

		"threat":
			match role:
				"blacksmith":
					return {"reply": "（%s握紧铁锤）你试试看？" % [name], "action": "defend", "emotion": "angry"}
				"innkeeper":
					return {"reply": "%s：来人！有闹事的！" % [name], "action": "call_guard", "emotion": "angry"}
				_:
					return {"reply": "%s：你这是什么意思？！" % [name], "action": "alert", "emotion": "angry"}

		"farewell":
			if rel >= 30:
				return {"reply": "%s：慢走，路上小心。" % [name], "action": "wave", "emotion": "friendly"}
			return {"reply": "%s：嗯。" % [name], "action": "nod", "emotion": "neutral"}

		"gossip":
			var gossips = [
				"最近落霞村好像来了些陌生人。",
				"听说道上的铁掌门不太平。",
				"没什么特别的，就是日子照过。",
				"听说东边有山贼出没，小心点。",
			]
			var idx = randi() % gossips.size()
			return {"reply": "%s：%s" % [name, gossips[idx]], "action": "gossip", "emotion": "neutral"}

	return {"reply": "%s：嗯。" % [name], "action": "talk", "emotion": "neutral"}


func _generate_model_response(npc: Dictionary, intent: String, emotion: String, player_input: String) -> Dictionary:
	"""
	通过 LocalProvider 生成 NPC 回复。
	模型只负责：输入结构化上下文 JSON → 输出结构化回复 JSON。

	如果 LocalProvider 不可用，降级到规则系统。
	"""
	if mml_client == null or not mml_client.is_available():
		# 优雅降级：模型不可用 → 规则系统
		return _generate_rule_response(npc, intent, emotion)

	# 构建 Prompt（统一格式）
	var context = {
		"task": "npc_dialogue",
		"npc": {
			"name": npc.get("name", "?"),
			"role": npc.get("role", "?"),
			"emotion": emotion,
			"relationship": npc.get("relationship", 0),
		},
		"player_input": player_input,
		"intent": intent,
		"memories": npc.get("recent_memories", []),
	}

	var prompt = JSON.stringify(context)

	# 通过 MMLClient 调用 LocalProvider
	var response = mml_client.generate(
		mml_client.TaskType.NPC_DIALOGUE,
		prompt,
		"Generate a short NPC reply in character. Return JSON: {\"reply\": string, \"action\": string}",
		64,  # max_tokens — 一句话就够了
		0.3  # temperature — 低温度保证稳定性
	)

	if response.is_success():
		return _parse_response(response.raw_text, npc, intent)

	# 模型失败 → 降级到规则
	return _generate_rule_response(npc, intent, emotion)


func _parse_response(raw: String, npc: Dictionary, intent: String) -> Dictionary:
	"""
	解析模型 JSON 输出。
	如果解析失败 → 规则降级。
	"""
	# 尝试提取 JSON
	var json_start = raw.find("{")
	var json_end = raw.rfind("}")
	if json_start >= 0 and json_end > json_start:
		raw = raw.substr(json_start, json_end - json_start + 1)

	var json = JSON.new()
	var error = json.parse(raw)
	if error == OK:
		var data = json.data
		if typeof(data) == TYPE_DICTIONARY and data.has("reply"):
			return {
				"reply": str(data.get("reply", "")),
				"action": str(data.get("action", "talk")),
				"emotion": str(data.get("emotion", "neutral")),
				"source": "model",
			}

	# 解析失败 → 规则降级
	var fallback = _generate_rule_response(npc, intent, "neutral")
	fallback["source"] = "rule_fallback"
	return fallback


func stats() -> Dictionary:
	"""
	统计信息：规则 vs 模型调用比例。
	目标：规则 > 90%
	"""
	var total = rule_only_calls + model_calls
	return {
		"rule_calls": rule_only_calls,
		"model_calls": model_calls,
		"total": total,
		"rule_percentage": (float(rule_only_calls) / float(max(total, 1))) * 100.0,
	}

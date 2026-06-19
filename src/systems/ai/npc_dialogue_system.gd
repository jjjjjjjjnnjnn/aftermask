## NPCDialogueSystem — NPC 对话系统
## 遵循 LinguaCore 架构：
##   - 程序端负责：状态管理、记忆系统、情感计算、Prompt 构建
##   - 模型只负责：自然语言生成（输入结构化 JSON，输出结构化 JSON）
extends Node

# === NPC 情绪状态 ===
enum Emotion {
	NEUTRAL,     # 中立
	FRIENDLY,    # 友好
	ANGRY,       # 愤怒
	SAD,         # 悲伤
	SUSPICIOUS,  # 怀疑
	SURPRISED,   # 惊讶
	FEARFUL,     # 恐惧
	GRATEFUL,    # 感激
}

# === 对话意图 ===
enum Intent {
	GREETING,      # 打招呼
	QUEST,         # 任务对话
	TRADE,         # 交易
	GOSSIP,        # 闲聊
	HELP,          # 求助
	THREAT,        # 威胁
	FAREWELL,      # 告别
	MEMORY_TRIGGER, # 记忆触发
}

# === NPC 对话配置 ===
class NPCDialogueProfile:
	var npc_id: int
	var npc_name: String
	var npc_role: String          # innkeeper, blacksmith, merchant, etc.
	var emotion: Emotion = Emotion.NEUTRAL
	var relationship: int = 0     # -100 ~ 100
	var memories: Array[Dictionary] = []
	var knowledge_tags: Array[String] = []

	func _init(id: int, name: String, role: String):
		npc_id = id
		npc_name = name
		npc_role = role

	func to_dict() -> Dictionary:
		return {
			"npc_id": npc_id,
			"name": npc_name,
			"role": npc_role,
			"emotion": Emotion.keys()[emotion],
			"relationship": relationship,
			"memory_count": memories.size(),
			"knowledge_tags": knowledge_tags,
		}


# === 系统信号 ===
signal dialogue_started(npc_id: int, dialogue_data: Dictionary)
signal dialogue_ended()
signal npc_response_ready(npc_id: int, response: String, action: String)


func start_dialogue(profile: NPCDialogueProfile, player_input: String = "") -> Dictionary:
	"""
	开始或继续对话。
	程序端构建完整的对话上下文，传递给模型（或直接规则生成）。
	"""
	var context = _build_dialogue_context(profile, player_input)
	var response = _generate_response(profile, context)

	emit_signal("npc_response_ready", profile.npc_id, response["reply"], response.get("action", "talk"))
	return response


func _build_dialogue_context(profile: NPCDialogueProfile, player_input: String) -> Dictionary:
	"""
	构建完整的对话上下文用于 Prompt Builder。
	所有逻辑在程序端完成，模型只负责一句话生成。
	"""
	var context = {
		"npc": profile.to_dict(),
		"player_input": player_input,
		"memories": _get_relevant_memories(profile, player_input),
		"quests": _get_related_quests(profile),
		"world_state": _get_world_state(),
	}

	# 检测对话意图（程序端，不需要模型）
	context["detected_intent"] = _detect_intent(player_input)

	# 情感计算（程序端）
	context["emotional_bias"] = _calculate_emotional_bias(profile)

	return context


func _generate_response(profile: NPCDialogueProfile, context: Dictionary) -> Dictionary:
	"""
	生成 NPC 回复。
	当前使用规则系统（不需要模型），未来可替换为 LinguaCore 小模型调用。

	规则系统覆盖 80% 的常见对话场景：
	- 打招呼 → 根据好感度回复
	- 交易 → 根据角色职业和好感度
	- 记忆触发 → 特殊对话
	- 其他 → 通用回复
	"""
	var intent = context.get("detected_intent", Intent.GREETING)
	var rel = profile.relationship

	match intent:
		Intent.GREETING:
			return _greeting_response(profile, rel)

		Intent.TRADE:
			return _trade_response(profile, rel)

		Intent.QUEST:
			return _quest_response(profile)

		Intent.HELP:
			return _help_response(profile, rel)

		Intent.THREAT:
			return _threat_response(profile, rel)

		Intent.FAREWELL:
			return _farewell_response(profile, rel)

		Intent.MEMORY_TRIGGER:
			return _memory_trigger_response(profile, context.get("memories", []))

		Intent.GOSSIP:
			return _gossip_response(profile)

		_:
			return {"reply": _neutral_reply(profile), "action": "talk"}


func _detect_intent(player_input: String) -> int:
	"""
	检测玩家输入意图。
	纯规则实现，不需要模型。
	"""
	var input_lower = player_input.to_lower()

	# 交易
	if "买" in input_lower or "卖" in input_lower or "交易" in input_lower \
		or "shop" in input_lower or "buy" in input_lower or "sell" in input_lower:
		return Intent.TRADE

	# 任务
	if "任务" in input_lower or "需要" in input_lower or "quest" in input_lower \
		or "help" in input_lower:
		return Intent.HELP

	# 威胁
	if "杀" in input_lower or "威胁" in input_lower or "threat" in input_lower \
		or "die" in input_lower:
		return Intent.THREAT

	# 告别
	if "走" in input_lower or "再见" in input_lower or "bye" in input_lower \
		or "goodbye" in input_lower or "farewell" in input_lower:
		return Intent.FAREWELL

	# 闲聊
	if "知道" in input_lower or "听说" in input_lower or "gossip" in input_lower \
		or "news" in input_lower:
		return Intent.GOSSIP

	# 记忆触发（特殊检测）
	if "记得" in input_lower or "认识" in input_lower or "remember" in input_lower \
		or "recognize" in input_lower:
		return Intent.MEMORY_TRIGGER

	# 默认：打招呼
	return Intent.GREETING


func _calculate_emotional_bias(profile: NPCDialogueProfile) -> Dictionary:
	"""
	根据好感度和当前情绪计算对话偏移。
	"""
	var bias = {
		"warmth": clamp(profile.relationship / 50.0, -1.0, 1.0),
		"talkativeness": 0.5 + clamp(profile.relationship / 200.0, -0.3, 0.3),
	}

	if profile.emotion == Emotion.ANGRY:
		bias["warmth"] = -0.5
	elif profile.emotion == Emotion.GRATEFUL:
		bias["warmth"] = 0.8
	elif profile.emotion == Emotion.FEARFUL:
		bias["talkativeness"] = 0.2

	return bias


func _get_relevant_memories(profile: NPCDialogueProfile, player_input: String) -> Array:
	"""
	检索 NPC 与玩家相关的记忆。
	"""
	var relevant = []
	for memory in profile.memories:
		# 检查记忆是否与输入相关
		if player_input.is_empty():
			relevant.append(memory)
		else:
			var tags = memory.get("tags", [])
			for tag in tags:
				if tag in player_input.to_lower():
					relevant.append(memory)
					break

	# 按强度排序
	relevant.sort_custom(func(a, b): return a.get("intensity", 0) > b.get("intensity", 0))
	return relevant.slice(0, 3)


func _get_related_quests(profile: NPCDialogueProfile) -> Array:
	"""获取 NPC 相关的活跃任务。"""
	# TODO: 从 QuestSystem 获取
	return []


func _get_world_state() -> Dictionary:
	"""获取当前世界状态摘要。"""
	# TODO: 从 WorldManager 获取
	return {"era": 0, "events": []}


# ============================================================
# 规则回复生成器（80% 场景覆盖，不需要模型）
# ============================================================

func _greeting_response(profile: NPCDialogueProfile, rel: int) -> Dictionary:
	match profile.npc_role:
		"innkeeper":
			if rel >= 50:
				return {"reply": "客官您来了！还是老位置？", "action": "greet"}
			elif rel <= -30:
				return {"reply": "...（掌柜冷冷看了你一眼，没说话）", "action": "ignore"}
			else:
				return {"reply": "欢迎光临！住店还是打尖？", "action": "greet"}

		"blacksmith":
			if rel >= 30:
				return {"reply": "来了？新打了一批铁器，你看看合不合手。", "action": "greet"}
			else:
				return {"reply": "要打什么？自己看价钱。", "action": "greet"}

		"merchant":
			var goods = ["丹药", "兵器", "古籍", "药材"]
			return {
				"reply": "好货不等人！今日刚到一批%s，要不要看看？" % goods[randi() % goods.size()],
				"action": "trade_offer",
			}

		_:
			var greetings = [
				"你好。", "有什么事吗？",
				"嗯？", "又见面了。",
			]
			return {"reply": greetings[randi() % greetings.size()], "action": "greet"}


func _trade_response(profile: NPCDialogueProfile, rel: int) -> Dictionary:
	var price_mod = 1.0 - clamp(rel * 0.002, -0.3, 0.3)
	var price_label = "（%d折）" % int(price_mod * 10)

	match profile.npc_role:
		"innkeeper":
			return {
				"reply": "住店一晚20文%s，吃饭另算。要些什么？" % price_label,
				"action": "show_menu",
			}
		"blacksmith":
			return {
				"reply": "兵器架子上的都在这%s。看上哪个说。 " % price_label,
				"action": "show_inventory",
			}
		"merchant":
			return {
				"reply": "来来来%s，我这什么都有！" % price_label,
				"action": "show_inventory",
			}
		_:
			return {"reply": "我不做买卖。", "action": "refuse"}


func _quest_response(profile: NPCDialogueProfile) -> Dictionary:
	# TODO: 从 QuestSystem 获取可用任务
	return {"reply": "眼下没什么特别的事。", "action": "talk"}


func _help_response(profile: NPCDialogueProfile, rel: int) -> Dictionary:
	if rel < -20:
		return {"reply": "呵，你也有求人的一天？", "action": "mock"}

	var helps = [
		"说来听听。",
		"说说看，能帮就帮。",
		"你需要什么？",
	]
	# 高好感度触发额外帮助
	if rel >= 50:
		helps.append("你开口就行！")
	return {"reply": helps[randi() % helps.size()], "action": "listen"}


func _threat_response(profile: NPCDialogueProfile, rel: int) -> Dictionary:
	if profile.npc_role == "blacksmith":
		return {"reply": "（握紧铁锤）你试试看？", "action": "defend"}
	elif profile.npc_role == "innkeeper":
		return {"reply": "来人！有闹事的！", "action": "call_guard"}

	if rel >= 50:
		return {"reply": "你...你认真的？", "action": "shocked"}
	else:
		return {"reply": "你这是什么意思？", "action": "alert"}


func _farewell_response(profile: NPCDialogueProfile, rel: int) -> Dictionary:
	match profile.npc_role:
		"innkeeper":
			if rel >= 50:
				return {"reply": "慢走啊！下次再来！", "action": "wave"}
			else:
				return {"reply": "慢走。", "action": "nod"}
		_:
			if rel >= 30:
				return {"reply": "慢走，路上小心。", "action": "wave"}
			else:
				return {"reply": "嗯。", "action": "nod"}


func _gossip_response(profile: NPCDialogueProfile) -> Dictionary:
	var gossips = [
		"最近落霞村好像来了些陌生人。",
		"听说道上的铁掌门不太平。",
		"没什么特别的，就是日子照过。",
		"听说东边有山贼出没，小心点。",
	]
	return {
		"reply": gossips[randi() % gossips.size()],
		"action": "gossip",
	}


func _memory_trigger_response(profile: NPCDialogueProfile, memories: Array) -> Dictionary:
	if memories.is_empty():
		return {"reply": "你...我们以前见过吗？", "action": "confused"}

	var top_memory = memories[0]
	var memory_text = top_memory.get("description", "")
	var memory_emotion = top_memory.get("emotion", "neutral")

	if memory_emotion == "positive":
		return {
			"reply": "你...你长得很像我认识的一个人。那是很久以前的事了...（语气变得温和）%s" % memory_text,
			"action": "recall_happy",
		}
	elif memory_emotion == "negative":
		return {
			"reply": "（脸色一沉）你让我想起了一些不好的回忆。" ,
			"action": "recall_painful",
		}
	else:
		return {
			"reply": "等一下...我们是不是在哪里见过？你看起来眼熟。",
			"action": "recall_uncertain",
		}


func _neutral_reply(profile: NPCDialogueProfile) -> String:
	return "嗯。"

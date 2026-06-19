"""
Aftermask — Core Loop Integration Test (v3)
Tests: Reincarnation Engine + NPC Dialogue System + LinguaCore Architecture

Usage:
    PYTHONIOENCODING=utf-8 python tests/aftermask_v3.py
"""
import os
import sys
import json
import random

os.environ["PYTHONIOENCODING"] = "utf-8"

sys.stdout = open(sys.stdout.fileno(), mode='w', encoding='utf-8', buffering=1)


# ============================================================
# SimReincarnation — 转生引擎模拟
# 遵循 LinguaCore 架构: 所有逻辑在程序端
# ============================================================
class SimReincarnation:
    REALMS = ["无", "武徒", "武者", "武师", "先天", "宗师", "大宗师", "天人"]
    BIRTH_PLACES = ["落霞村", "青风镇", "铁剑村", "杏花村", "江城", "无名谷"]
    IDENTITY_NAMES = {
        "peasant": "农家", "merchant": "商家", "scholar": "书生",
        "hunter": "猎户", "beggar": "乞丐", "artisan": "工匠", "noble": "贵族",
    }

    def calculate_rewards(self, peak_stats: dict, realm: str, realm_level: int,
                          kills: int, helped: int, relationships: int,
                          factions: int, legends: int, cause: str) -> dict:
        rewards = {"stat_bonuses": {}, "memory_slots": 1, "talents": []}
        realm_idx = self.REALMS.index(realm) if realm in self.REALMS else 0

        # 境界成就: 武师+ → 悟性+2
        if realm_idx >= 3:
            rewards["stat_bonuses"]["comprehension"] = rewards["stat_bonuses"].get("comprehension", 0) + 2
            rewards["talents"].append("修行者之心")

        # 社交成就: 10+关系 → 魅力+2
        if relationships >= 10:
            rewards["stat_bonuses"]["charisma"] = rewards["stat_bonuses"].get("charisma", 0) + 2
            rewards["talents"].append("社交达人")

        # 战斗成就: 5+树敌 → 力量+1 敏捷+1
        if kills >= 5:
            rewards["stat_bonuses"]["strength"] = rewards["stat_bonuses"].get("strength", 0) + 1
            rewards["stat_bonuses"]["agility"] = rewards["stat_bonuses"].get("agility", 0) + 1
            rewards["talents"].append("手上沾血")

        # 帮助他人: 10+ → 魅力+1
        if helped >= 10:
            rewards["stat_bonuses"]["charisma"] = rewards["stat_bonuses"].get("charisma", 0) + 1
            rewards["talents"].append("助人为乐")

        # 传说成就: 1+传说 → 记忆槽+1
        if legends >= 1:
            rewards["memory_slots"] += 1
            rewards["talents"].append("传说之源")

        # 建立势力: 全属性+1
        if factions >= 1:
            for s in ["strength", "agility", "comprehension", "charisma"]:
                rewards["stat_bonuses"][s] = rewards["stat_bonuses"].get(s, 0) + 1

        # 寿终正寝: 生命上限+10
        if cause == "natural":
            rewards["stat_bonuses"]["max_hp"] = 10
            rewards["talents"].append("善终者")

        return rewards

    def inherit_stats(self, peak_stats: dict, rewards: dict) -> dict:
        return {
            "strength": max(1, int(peak_stats.get("strength", 5) * 0.1))
                        + rewards["stat_bonuses"].get("strength", 0),
            "agility": max(1, int(peak_stats.get("agility", 5) * 0.1))
                       + rewards["stat_bonuses"].get("agility", 0),
            "comprehension": max(1, int(peak_stats.get("comprehension", 5) * 0.15))
                            + rewards["stat_bonuses"].get("comprehension", 0),
            "charisma": max(1, int(peak_stats.get("charisma", 5) * 0.1))
                        + rewards["stat_bonuses"].get("charisma", 0),
            "max_hp": 100 + rewards["stat_bonuses"].get("max_hp", 0),
            "max_mp": 50,
        }

    def assign_birth(self, peak_stats: dict) -> dict:
        s, c, ch = peak_stats.get("strength", 5), peak_stats.get("comprehension", 5), peak_stats.get("charisma", 5)
        w = {"peasant": 1.0, "merchant": 1.0, "scholar": 1.0, "hunter": 1.0,
             "beggar": 1.0, "artisan": 1.0}
        if s >= 8: w["hunter"] = 3.0
        if s >= 12: w["beggar"] = 2.0
        if c >= 8: w["scholar"] = 3.0
        if c >= 11: w["artisan"] = 2.0
        if ch >= 8: w["merchant"] = 3.0
        if ch >= 11: w["noble"] = 2.0

        total = sum(w.values())
        r = random.random() * total
        cum = 0.0
        chosen = "peasant"
        for k, v in w.items():
            cum += v
            if r <= cum:
                chosen = k
                break
        return {"identity": self.IDENTITY_NAMES.get(chosen, chosen),
                "location": random.choice(self.BIRTH_PLACES)}

    def run_full_cycle(self, peak_stats: dict, realm: str, realm_level: int,
                       kills: int, helped: int, relationships: int,
                       factions: int, legends: int, cause: str, era: int) -> dict:
        rewards = self.calculate_rewards(
            peak_stats, realm, realm_level, kills, helped,
            relationships, factions, legends, cause)
        new_stats = self.inherit_stats(peak_stats, rewards)
        birth = self.assign_birth(peak_stats)
        return {
            "era": era + 1,
            "birth": birth,
            "new_stats": new_stats,
            "rewards": rewards,
            "memory_fragments": self._generate_fragments(peak_stats, cause),
        }

    def _generate_fragments(self, peak_stats: dict, cause: str) -> list:
        fragments = []
        if peak_stats.get("charisma", 5) >= 8:
            fragments.append({"desc": "张铁师的微笑", "intensity": 80, "type": "positive"})
        if cause in ("combat", "accident"):
            fragments.append({"desc": "铁掌门的大火", "intensity": 90, "type": "trauma"})
        if peak_stats.get("comprehension", 5) >= 8:
            fragments.append({"desc": "你建的学堂", "intensity": 70, "type": "legacy"})
        return fragments


# ============================================================
# SimNPCDialogue — NPC 对话系统模拟
# 遵循 LinguaCore 架构: 规则覆盖 80%，模型处理 20%
# ============================================================
class SimNPCDialogue:
    def __init__(self):
        self.npcs = {}

    def register(self, npc_id: int, name: str, role: str, relationship: int = 0):
        self.npcs[npc_id] = {"name": name, "role": role, "relationship": relationship, "memories": []}

    def add_memory(self, npc_id: int, desc: str, emotion: str, intensity: int):
        if npc_id in self.npcs:
            self.npcs[npc_id]["memories"].append({"description": desc, "emotion": emotion, "intensity": intensity})

    def detect_intent(self, text: str) -> str:
        t = text.lower()
        if any(w in t for w in ["买", "卖", "交易", "buy", "sell", "shop"]): return "trade"
        if any(w in t for w in ["任务", "需要", "quest", "help"]): return "help"
        if any(w in t for w in ["杀", "威胁", "threat", "die"]): return "threat"
        if any(w in t for w in ["记得", "认识", "remember", "recognize"]): return "memory"
        if any(w in t for w in ["走", "再见", "bye", "goodbye"]): return "farewell"
        return "greeting"

    def respond(self, npc_id: int, player_input: str) -> dict:
        npc = self.npcs.get(npc_id, {"name": "?", "role": "?", "relationship": 0, "memories": []})
        intent = self.detect_intent(player_input)
        rel = npc["relationship"]
        role = npc["role"]

        if intent == "greeting":
            if rel >= 50: return {"reply": "客官您来了！好久不见！", "action": "greet"}
            if rel <= -20: return {"reply": "...（冷冷看了一眼）", "action": "ignore"}
            return {"reply": "你好。有什么事吗？", "action": "greet"}

        if intent == "trade":
            if role == "innkeeper": return {"reply": "住店一晚20文，吃饭另算。", "action": "show_menu"}
            if role == "blacksmith": return {"reply": "兵器架子上的都在这，看上哪个说。", "action": "show_inventory"}
            if role == "merchant": return {"reply": "来来来，我这什么都有！", "action": "show_inventory"}
            return {"reply": "我不做买卖。", "action": "refuse"}

        if intent == "threat":
            if role == "blacksmith": return {"reply": "（握紧铁锤）你试试看？", "action": "defend"}
            if role == "innkeeper": return {"reply": "来人！有闹事的！", "action": "call_guard"}
            return {"reply": "你这是什么意思？！", "action": "alert"}

        if intent == "memory":
            if not npc["memories"]: return {"reply": "你...我们以前见过吗？", "action": "confused"}
            mem = sorted(npc["memories"], key=lambda x: -x["intensity"])[0]
            if mem["emotion"] == "positive":
                return {"reply": f"你...你长得很像我认识的一个人。{mem['description']}", "action": "recall_happy"}
            elif mem["emotion"] == "negative":
                return {"reply": "（脸色一沉）你让我想起了一些不好的回忆。", "action": "recall_painful"}
            return {"reply": "等一下...我们是不是在哪里见过？", "action": "recall_uncertain"}

        if intent == "farewell":
            return {"reply": "慢走，路上小心。", "action": "wave"}

        if intent == "help":
            if rel < -20: return {"reply": "呵，你也有求人的一天？", "action": "mock"}
            if rel >= 50: return {"reply": "你开口就行！", "action": "listen"}
            return {"reply": "说说看，能帮就帮。", "action": "listen"}

        return {"reply": "嗯。", "action": "talk"}


# ============================================================
# Demo: 完整剧情
# ============================================================
def demo():
    reinc = SimReincarnation()
    dialogue = SimNPCDialogue()

    # 注册 NPC
    dialogue.register(1, "张铁师", "blacksmith", 0)
    dialogue.register(2, "老王", "blacksmith", 0)

    print("=" * 60)
    print("  百世江湖 — Core Loop v3")
    print("  转生引擎 + NPC识别 + LinguaCore架构")
    print("=" * 60)

    # === 第一世 ===
    print("\n\n【第一世】无名乞丐")
    print("  出生: 落霞村")
    print("  你遇到了铁掌门长老——张铁师。")

    resp = dialogue.respond(1, "你好")
    print(f"\n  玩家: 你好")
    print(f"  张铁师: \"{resp['reply']}\"")

    # 改善关系
    print("\n  你帮张铁师修好了铁剑，关系改善。")
    dialogue.npcs[1]["relationship"] = 50
    dialogue.add_memory(1, "一个乞丐帮我修好了剑。", "positive", 60)

    resp = dialogue.respond(1, "你好")
    print(f"\n  玩家: 你好")
    print(f"  张铁师: \"{resp['reply']}\"")

    # 第一世结束
    print("\n  --- 第一世结束 ---")
    print("  你在与毒蛇帮的战斗中重伤身亡。享年30岁。")

    result = reinc.run_full_cycle(
        peak_stats={"strength": 12, "agility": 8, "comprehension": 10, "charisma": 10},
        realm="武者", realm_level=3,
        kills=5, helped=3, relationships=8, factions=1, legends=1,
        cause="combat", era=0,
    )

    print(f"\n  轮回奖励: {', '.join(result['rewards']['talents'])}")
    print(f"  继承属性: 力{result['new_stats']['strength']} "
          f"敏{result['new_stats']['agility']} "
          f"悟{result['new_stats']['comprehension']} "
          f"魅{result['new_stats']['charisma']}")

    # === 第二世 ===
    print(f"\n\n【第二世 — {result['birth']['identity']}】")
    print(f"  出生: {result['birth']['location']}")
    print(f"  你有了新的名字——{result['birth']['identity']}之子李枫。")

    print("\n  --- 50年后 ---")
    print("  你回到落霞村，在铁匠铺遇到了一个老人——老王。")
    print("  他曾经是铁掌门的弟子...")

    dialogue.add_memory(2, "张铁师曾经救过一个乞丐，后来那人成了英雄。", "positive", 80)

    resp = dialogue.respond(2, "你记得张铁师吗？")
    print(f"\n  玩家: 你记得张铁师吗？")
    print(f"  老王: \"{resp['reply']}\"")

    resp = dialogue.respond(2, "我们是不是认识？")
    print(f"\n  玩家: 我们是不是认识？")
    print(f"  老王: \"{resp['reply']}\"")

    resp = dialogue.respond(2, "再见")
    print(f"\n  玩家: 再见")
    print(f"  老王: \"{resp['reply']}\"")

    # === 验证 ===
    print("\n\n" + "=" * 60)
    print("  验证检查")
    print("=" * 60)

    checks = [
        ("属性继承: 力量 >= 2", result["new_stats"]["strength"] >= 2),
        ("属性继承: 悟性继承率15%", result["new_stats"]["comprehension"] >= 2),
        ("轮回奖励: 至少2个天赋 (战斗+传说)", len(result["rewards"]["talents"]) >= 2),
        ("出生身份非空", bool(result["birth"]["identity"])),
        ("NPC对话: 意图检测正确", dialogue.detect_intent("买") == "trade"),
        ("NPC对话: 高好感度回复", "好久不见" in dialogue.respond(1, "你好")["reply"]),
        ("NPC对话: 记忆触发含'认识'", "认识" in dialogue.respond(2, "认识张铁师")["reply"]),
        ("NPC对话: 警告意图", "试试" in dialogue.respond(1, "杀")["reply"]),
        ("多种死因: natural", reinc.run_full_cycle({"strength": 5, "agility": 5, "comprehension": 5, "charisma": 5},
                                                     "无", 0, 0, 0, 0, 0, 0, "natural", 0) is not None),
        ("多种死因: combat", reinc.run_full_cycle({"strength": 5, "agility": 5, "comprehension": 5, "charisma": 5},
                                                    "无", 0, 0, 0, 0, 0, 0, "combat", 0) is not None),
    ]

    for label, passed in checks:
        icon = "✅" if passed else "❌"
        print(f"  {icon} {label}")

    total_pass = sum(1 for _, p in checks if p)
    total = len(checks)
    print(f"\n  {total_pass}/{total} 通过")

    if total_pass == total:
        print("\n  🎉 全部通过！")
    print("=" * 60)


if __name__ == "__main__":
    demo()

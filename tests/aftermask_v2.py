#!/usr/bin/env python3
"""
Aftermask Legacy Prototype v2 — Behavioral Test
================================================

Measures True Legacy Retention (TLR) through player behavior.

Usage:
    python aftermask_v2.py

The prototype runs in the terminal. Players make choices by typing numbers.
At the end of Life 2, they are asked: "Continue to Life 3?"
Their answer (yes/no) is the TLR metric.

No survey questions during play. Pure behavioral observation.
"""

import sys
import os
import json
import random
from datetime import datetime

# === Game State ===
class GameState:
    def __init__(self):
        self.era = 0
        self.player_name = ""
        self.stats = {"strength": 3, "agility": 3, "comprehension": 3, "charisma": 3}
        self.relationships = {}
        self.legacies = []
        self.choices_made = []
        self.events_experienced = []
        self.death_count = 0
        
    def to_dict(self):
        return {
            "era": self.era,
            "player_name": self.player_name,
            "stats": self.stats,
            "relationships": self.relationships,
            "legacies": self.legacies,
            "choices_made": self.choices_made,
            "events_experienced": self.events_experienced,
            "death_count": self.death_count
        }

# === Display ===
def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def pause():
    input("\n[按 Enter 继续 / Press Enter to continue / Fortsetzen mit Enter]")

def display_header(text):
    print("\n" + "=" * 60)
    print(f"  {text}")
    print("=" * 60)

def display_stats(state):
    print(f"\n  属性 / Stats: 力{state.stats['strength']} 敏{state.stats['agility']} 悟{state.stats['comprehension']} 魅{state.stats['charisma']}")
    print(f"  世代 / Era: {state.era}")

def get_choice(options):
    """Get player choice from numbered options"""
    while True:
        print()
        for i, opt in enumerate(options, 1):
            print(f"  [{i}] {opt}")
        print()
        try:
            choice = input("  选择 / Choose: ").strip()
            if choice.isdigit() and 1 <= int(choice) <= len(options):
                return int(choice)
            print("  无效选择 / Invalid choice")
        except (EOFError, KeyboardInterrupt):
            print("\n  [测试中断 / Test interrupted]")
            sys.exit(0)

def get_yes_no(question):
    """Get yes/no answer"""
    while True:
        print(f"\n  {question}")
        print("  [1] 是 / Yes / Ja")
        print("  [2] 否 / No / Nein")
        try:
            choice = input("  选择 / Choose: ").strip()
            if choice == "1":
                return True
            elif choice == "2":
                return False
            print("  无效选择 / Invalid choice")
        except (EOFError, KeyboardInterrupt):
            print("\n  [测试中断 / Test interrupted]")
            sys.exit(0)

# === Story Content ===
def intro():
    clear_screen()
    display_header("AFTERMASK")
    print("""
  Every life leaves a mask on the world.
  Jede Leben hinterlässt eine Maske auf der Welt.
  每一世都在世界留下一张面具。

  A reincarnation simulation.
  Eine Reinkarnationssimulation.
  一款轮回模拟器。
    """)
    pause()

def life1(state):
    """Life 1: The Unknown"""
    state.era = 1
    
    clear_screen()
    display_header("LIFE 1 / LEBEN 1 / 第一世")
    print("""
  You wake up in a village called Luoxia.
  You are 6 years old. Cold. Hungry. Alone.
  
  Du erwachst in einem Dorf namens Luoxia.
  Du bist 6 Jahre alt. Kalt. Hungrig. Allein.
  
  你在落霞村醒来。6岁。寒冷。饥饿。孤独。
    """)
    display_stats(state)
    pause()
    
    # Choice 1: How to survive
    clear_screen()
    display_header("THE BEGGAR'S CHOICE / DES BETTLERS WAHL / 乞丐的选择")
    print("""
  A passing swordsman drops a copper coin.
  He looks at you with curiosity.
  
  Ein vorbeigehender Schwertkämpfer wirft eine Kupfermünze hinunter.
  Er betrachtet dich mit Neugier.
  
  一个路过的剑客丢下一枚铜钱。他好奇地看着你。
    """)
    
    choice = get_choice([
        "Bow and say 'Thank you, master.' / Verbeugen und 'Danke, Meister.' sagen. / 鞠躬说'谢谢，师父。'",
        "Pick up the coin silently. / Münze schweigend aufheben. / 默默捡起铜钱。",
        "Push the coin back. 'I don't need charity.' / Münze zurückgeben. / 把铜钱推回去。"
    ])
    
    state.choices_made.append({"era": 1, "choice": "first_impression", "value": choice})
    
    if choice == 1:
        print("\n  The swordsman pauses. 'Polite. That's rare.'")
        print("  He returns 3 days later and takes you as his informal disciple.")
        state.stats["charisma"] += 1
        state.relationships["zhang_tieshi"] = {"trust": 30, "type": "master"}
        state.events_experienced.append("adopted_by_swordsman")
    elif choice == 2:
        print("\n  The swordsman frowns. 'No manners.' He walks away.")
        print("  A week later, older beggars beat you for trespassing.")
        state.stats["strength"] -= 1
        state.events_experienced.append("rejected_by_swordsman")
    else:
        print("\n  The swordsman raises an eyebrow. 'Interesting.'")
        print("  He tells the innkeeper to feed you. You eat your first full meal.")
        state.stats["charisma"] += 2
        state.relationships["zhang_tieshi"] = {"trust": 10, "type": "acquaintance"}
        state.events_experienced.append("impressed_swordsman")
    
    pause()
    
    # Choice 2: The training
    clear_screen()
    display_header("TRAINING / AUSBILDUNG / 修炼")
    print("""
  You train under Zhang Tieshi for 4 years.
  You reach Martial Apprentice Level 2.
  
  Du trainierst 4 Jahre unter Zhang Tieshi.
  Du erreichst Stufe 2 des Kampfkunstlehrlings.
  
  你在张铁匠门下修炼4年。达到武者学徒2级。
    """)
    display_stats(state)
    pause()
    
    # Choice 3: The secret
    clear_screen()
    display_header("THE SECRET / DAS GEHEIMNIS / 秘密")
    print("""
  You overhear: The Sect Master wants Zhang Tieshi dead.
  He knows about a murder from the Sect Master's past.
  
  Du hörst mit: Der Sektenmeister will Zhang Tieshi tot.
  Er weiß von einem Mord aus der Vergangenheit des Sektenmeisters.
  
  你偷听到：掌门要杀张铁匠。他知道掌门过去的秘密。
    """)
    
    choice = get_choice([
        "Tell Zhang Tieshi immediately. / Zhang Tieshi sofort sagen. / 立刻告诉张铁匠。",
        "Stay silent and wait. / Schweigen und warten. / 保持沉默，等待。",
        "Confront the Sect Master. / Den Sektenmeister konfrontieren. / 直接对质掌门。"
    ])
    
    state.choices_made.append({"era": 1, "choice": "secret", "value": choice})
    
    if choice == 1:
        print("\n  Zhang Tieshi fights the Sect Master. Wins, but is fatally wounded.")
        print("  His last words: 'The sect is yours now.'")
        state.relationships["zhang_tieshi"]["trust"] = 100
        state.relationships["zhang_tieshi"]["status"] = "dead"
        state.legacies.append({
            "type": "social",
            "description": "Became Sect Master after saving your master",
            "impact": 70
        })
        state.events_experienced.append("master_died")
    elif choice == 2:
        print("\n  The Sect Master kills Zhang Tieshi while you watch.")
        print("  You do nothing. The guilt is overwhelming.")
        state.stats["comprehension"] += 2
        state.events_experienced.append("witnessed_murder")
    else:
        print("\n  The Sect Master kills you on the spot.")
        print("  You die at age 12.")
        state.death_count += 1
        state.events_experienced.append("killed_by_sect_master")
        return False  # Death
    
    pause()
    
    # Choice 4: Legacy decision
    clear_screen()
    display_header("LEGACY DECISION / VERMÄCHTNIS ENTSCHEIDUNG / 遗产抉择")
    print("""
  5 years have passed. You are the Sect Master.
  A plague kills your best disciple, Chen Yu.
  
  5 Jahre sind vergangen. Du bist der Sektenmeister.
  Eine Epidemie töte deinen besten Schüler Chen Yu.
  
  已过5年。你是掌门。瘟疫杀死了你最好的弟子陈宇。
    """)
    
    choice = get_choice([
        "Close the sect. 'I can't bear to lose anyone else.' / Sekte schließen. / 关闭门派。",
        "Rebuild stronger. 'Chen Yu would want me to continue.' / Stärker aufbauen. / 更强地重建。",
        "Seek revenge on the Poison Snake Gang. / Rache an der Schlangengang. / 向毒蛇帮复仇。"
    ])
    
    state.choices_made.append({"era": 1, "choice": "legacy_decision", "value": choice})
    
    if choice == 1:
        print("\n  The sect dissolves. Its members scatter.")
        print("  You live out your days in solitude.")
        state.legacies.append({
            "type": "social",
            "description": "Dissolved the sect after the plague",
            "impact": -30
        })
    elif choice == 2:
        print("\n  You rebuild the sect. Build a school. Train new disciples.")
        print("  The sect grows to 60 members.")
        state.legacies.append({
            "type": "physical",
            "description": "Built a school, rebuilt the sect",
            "impact": 80
        })
        state.stats["charisma"] += 2
    else:
        print("\n  You attack the Poison Snake Gang. Kill their leader.")
        print("  But they retaliate. The sect falls.")
        state.legacies.append({
            "type": "social",
            "description": "Destroyed the Poison Snake Gang, but lost the sect",
            "impact": 40
        })
        state.stats["strength"] += 3
    
    pause()
    
    # Death
    clear_screen()
    display_header("DEATH / TOD / 死亡")
    print("""
  You are 30 years old.
  Wounded. Bleeding. The winter wind cuts through your robes.
  
  Du bist 30 Jahre alt.
  Verwundet. Blutend. Der Winterwind durchdringt deine Roben.
  
  你30岁了。受伤。流血。冬风穿透你的衣袍。
    """)
    
    print("\n  You collapse in the snow outside Luoxia Village.")
    print("  The village where you were born.")
    print("\n  Du brichst im Schnee vor dem Dorf Luoxia zusammen.")
    print("  Das Dorf, in dem du geboren wurdest.")
    print("\n  你在落霞村外的雪地中倒下。你出生的地方。")
    
    state.death_count += 1
    state.events_experienced.append("death_age_30")
    
    pause()
    return True  # Continue to reincarnation

def reincarnation(state):
    """Reincarnation sequence"""
    clear_screen()
    display_header("REINCARNATION / REINKARNATION / 转生")
    
    print("""
  You float in darkness.
  A voice speaks:
  
  Du schwebst in der Dunkelheit.
  Eine Stimme spricht:
  
  你漂浮在黑暗中。一个声音说：
    """)
    
    print('  "Your life has ended. But your story is not over."')
    print('  "Dein Leben ist zu Ende. Aber deine Geschichte ist nicht vorbei."')
    print('  "你的生命结束了。但你的故事还没有结束。"')
    
    pause()
    
    print("""
  "Choose which memory to carry into your next life."
  "Wähle, welche Erinnerung du in dein nächstes Leben mitnimmst."
  "选择带入下一世的记忆。"
    """)
    
    # Show legacies
    print("\n  Your legacy in this world:")
    print("  Dein Vermächtnis in dieser Welt:")
    print("  你在这一世的遗产：")
    for leg in state.legacies:
        print(f"    - {leg['description']} (Impact: {leg['impact']})")
    
    print("\n  Choose ONE memory to keep:")
    print("  Wähle EINE Erinnerung:")
    print("  选择一个记忆保留：")
    
    options = [
        f"Zhang Tieshi's smile: 'I'm proud of you.' (+2 Strength, +20 Loyalty)",
        f"The fall of the sect: Fire, screams, death. (+3 Comprehension, +30 Caution)",
        f"The school you built: Children learning, laughing. (+2 Charisma, Legacy +20)"
    ]
    
    choice = get_choice(options)
    state.choices_made.append({"era": 1, "choice": "memory_fragment", "value": choice})
    
    if choice == 1:
        state.stats["strength"] += 2
        state.events_experienced.append("kept_memory_strength")
    elif choice == 2:
        state.stats["comprehension"] += 3
        state.events_experienced.append("kept_memory_caution")
    else:
        state.stats["charisma"] += 2
        state.events_experienced.append("kept_memory_legacy")
    
    pause()

def life2(state):
    """Life 2: The Legacy"""
    state.era = 2
    
    clear_screen()
    display_header("LIFE 2 / LEBEN 2 / 第二世")
    print("""
  You are born again.
  This time, in a different village.
  Your father is a blacksmith. Your mother is a weaver.
  You are named Li Feng.
  
  Du wirst wiedergeboren.
  Diesmal in einem anderen Dorf.
  Dein Vater ist Schmied, deine Mutter Weber.
  Du wirst Li Feng genannt.
  
  你重生了。这次在另一个村庄。父亲是铁匠，母亲是织工。你叫李风。
    """)
    display_stats(state)
    pause()
    
    # The discovery
    clear_screen()
    display_header("THE DISCOVERY / DIE ENTDECKUNG / 发现")
    print("""
  At age 10, you feel drawn to a place you've never been.
  A village called Luoxia.
  
  Mit 10 Jahren fühlst du dich zu einem Ort hingezogen, den du nie besucht hast.
  Ein Dorf namens Luoxia.
  
  10岁时，你感到一种牵引，指向一个从未去过的地方。落霞村。
    """)
    
    print("\n  You walk there. Three days on foot.")
    print("  Du gehst dorthin. Drei Tage zu Fuß.")
    print("  你步行前往。走了三天。")
    
    pause()
    
    # The legacy
    clear_screen()
    display_header("THE LEGACY / DAS VERMÄCHTNIS / 遗产")
    
    # Generate legacy based on life 1 choices
    legacy_desc = ""
    legacy_impact = 0
    for leg in state.legacies:
        if leg["impact"] > 0:
            legacy_desc = leg["description"]
            legacy_impact = leg["impact"]
            break
    
    if legacy_desc:
        print(f"""
  You see a building.
  It's old. Weathered. But still standing.
  
  Du siehst ein Gebäude.
  Es ist alt. Verwittert. Aber es steht noch.
  
  你看到一座建筑。古老。斑驳。但仍然矗立。
        """)
        
        print(f"\n  The building is: {legacy_desc}")
        print(f"  Das Gebäude ist: {legacy_desc}")
        print(f"  这座建筑是：{legacy_desc}")
        
        print("\n  A teacher comes out:")
        print("  Ein Lehrer kommt heraus:")
        print("  一个老师走出来：")
        
        print('  "Welcome, young one. Are you here to learn?"')
        print('  "Willkommen, junger Mann. Bist du hier zum Lernen?"')
        print('  "欢迎，年轻人。你是来学习的吗？"')
        
        if legacy_impact >= 70:
            print("\n  The building has been here for 100 years.")
            print("  It was built by someone named Lin Wuming.")
            print("  Your name in your previous life.")
            print("\n  Das Gebäude steht hier seit 100 Jahren.")
            print("  Es wurde von jemandem namens Lin Wuming gebaut.")
            print("  Dein Name in deinem vorherigen Leben.")
            print("\n  这座建筑已经存在了100年。")
            print("  它是一个叫林无名的人建造的。")
            print("  你前世的名字。")
            
            state.events_experienced.append("found_own_legacy")
        else:
            print("\n  The building exists, but it's not what it used to be.")
            print("  Das Gebäude existiert, aber es ist nicht mehr das, was es war.")
            print("\n  建筑还在，但已经不是从前的样子了。")
            
            state.events_experienced.append("found_degraded_legacy")
    else:
        print("""
  You find nothing.
  The village is just a village.
  
  Du findest nichts.
  Das Dorf ist nur ein Dorf.
  
  你什么都没找到。村庄只是村庄。
        """)
        
        state.events_experienced.append("no_legacy_found")
    
    pause()
    
    # Choice: What to do with the legacy
    clear_screen()
    display_header("LEGACY INTERVENTION / VERMÄCHTNIS EINGRIFF / 遗产干预")
    print("""
  The school/building exists, but it needs help.
  What do you do?
  
  Die Schule/Das Gebäude existiert, aber sie braucht Hilfe.
  Was tust du?
  
  学校/建筑还在，但它需要帮助。你怎么做？
    """)
    
    choice = get_choice([
        "Rebuild it. Make it better than before. / Wiederaufbauen. Besser als zuvor. / 重建。比以前更好。",
        "Leave it as it is. Some things shouldn't be changed. / So lassen. / 保持原样。",
        "Destroy it. Start fresh. / Zerstören. Neu anfangen. / 毁掉它。重新开始。"
    ])
    
    state.choices_made.append({"era": 2, "choice": "legacy_intervention", "value": choice})
    
    if choice == 1:
        print("\n  You rebuild the school. Add new buildings. Create a curriculum.")
        print("  By age 20, it has 50 students.")
        state.legacies.append({
            "type": "physical",
            "description": "Rebuilt and expanded the school",
            "impact": 90
        })
        state.stats["charisma"] += 3
        state.events_experienced.append("rebuilt_legacy")
    elif choice == 2:
        print("\n  You leave it as it is. But you teach there on weekends.")
        print("  The school survives, but doesn't grow.")
        state.legacies.append({
            "type": "social",
            "description": "Preserved the school but didn't expand it",
            "impact": 50
        })
        state.events_experienced.append("preserved_legacy")
    else:
        print("\n  You burn it down. The villagers are horrified.")
        print("  'Why would you destroy our history?'")
        state.legacies.append({
            "type": "physical",
            "description": "Destroyed the school — villagers hate you",
            "impact": -60
        })
        state.stats["comprehension"] += 2
        state.events_experienced.append("destroyed_legacy")
    
    pause()
    
    # Death
    clear_screen()
    display_header("DEATH / TOD / 死亡")
    print("""
  You are 30 years old.
  You die peacefully, surrounded by your students.
  
  Du bist 30 Jahre alt.
  Du stirbst friedlich, umgeben von deinen Schülern.
  
  你30岁了。你安详地死去，学生们围在身边。
    """)
    
    print("\n  Your last thought:")
    print("  Dein letzter Gedanke:")
    print("  你最后的念头：")
    
    if choice == 1:
        print('  "I rebuilt what I created. The circle is complete."')
        print('  "Ich habe wiederaufgebaut, was ich erschaffen habe. Der Kreis ist geschlossen."')
        print('  "我重建了我创造的东西。轮回完成了。"')
    elif choice == 2:
        print('  "Some things are better left unchanged."')
        print('  "Manches besser unverändert lassen."')
        print('  "有些东西最好保持原样。"')
    else:
        print('  "I destroyed my own creation. Was it worth it?"')
        print('  "Ich habe meine eigene Schöpfung zerstört. War es das wert?"')
        print('  "我毁掉了自己的创造。值得吗？"')
    
    state.death_count += 1
    state.events_experienced.append("death_age_30_life2")
    
    pause()
    return True

def final_choice(state):
    """The critical behavioral choice"""
    clear_screen()
    display_header("REINCARNATION 2 / REINKARNATION 2 / 第二次转生")
    
    print("""
  You float in darkness again.
  A voice speaks:
  
  Du schwebst wieder in der Dunkelheit.
  Eine Stimme spricht:
  
  你再次漂浮在黑暗中。一个声音说：
    """)
    
    print('  "Your life has ended. But your story continues."')
    print('  "Dein Leben ist zu Ende. Aber deine Geschichte geht weiter."')
    print('  "你的生命结束了。但你的故事在继续。"')
    
    pause()
    
    print("""
  "Your legacy has evolved."
  "Dein Vermächtnis hat sich weiterentwickelt."
  "你的遗产已经演变。"
    """)
    
    # Show what happened
    print("\n  What your actions created:")
    print("  Was deine Handlungen erschaffen haben:")
    print("  你的行为创造了什么：")
    for leg in state.legacies:
        print(f"    - {leg['description']} (Impact: {leg['impact']})")
    
    pause()
    
    # THE CRITICAL QUESTION
    clear_screen()
    display_header("THE CHOICE / DIE WAHL / 选择")
    
    print("""
  The world is different because of you.
  Some things are better. Some are worse.
  But the world has changed.
  
  Die Welt ist wegen dir anders.
  Manches ist besser. Manches ist schlechter.
  Aber die Welt hat sich verändert.
  
  因为你，世界不同了。有些变好了，有些变坏了。但世界已经改变。
    """)
    
    print("\n  Do you want to live another life?")
    print("  Willst du ein weiteres Leben leben?")
    print("  你想再活一世吗？")
    
    print("\n  This is the final question. There is no wrong answer.")
    print("  Dies ist die letzte Frage. Es gibt keine falsche Antwort.")
    print("  这是最后的问题。没有错误答案。")
    
    print("\n" + "=" * 60)
    
    # This is the TLR measurement
    tlr_answer = get_yes_no(
        "Continue to Life 3? / Zu Leben 3 fortfahren? / 继续第三世？"
    )
    
    return tlr_answer

def test_summary(state, tlr_answer):
    """Display test summary"""
    clear_screen()
    display_header("TEST COMPLETE / TEST ABGESCHLOSSEN / 测试完成")
    
    print("""
  Thank you for playing Aftermask.
  
  Vielen Dank für das Spielen von Aftermask.
  
  感谢游玩 Aftermask。
    """)
    
    print(f"\n  === TEST RESULTS / TESTERGEBNISSE / 测试结果 ===")
    print(f"  Lives lived / Gelebte Leben / 活过的世: {state.era}")
    print(f"  Deaths / Tode / 死亡次数: {state.death_count}")
    print(f"  Choices made / Gemachte Entscheidungen / 做出的选择: {len(state.choices_made)}")
    print(f"  Legacies created / Erstellte Vermächtnisse / 创造的遗产: {len(state.legacies)}")
    print(f"  TLR (True Legacy Retention): {'YES' if tlr_answer else 'NO'}")
    
    # Save results
    results = {
        "timestamp": datetime.now().isoformat(),
        "era": state.era,
        "death_count": state.death_count,
        "choices_made": state.choices_made,
        "legacies": state.legacies,
        "events_experienced": state.events_experienced,
        "stats_final": state.stats,
        "tlr_answer": tlr_answer
    }
    
    filename = f"test_result_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(filename, 'w', encoding='utf-8') as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    
    print(f"\n  Results saved to: {filename}")
    print(f"  Ergebnisse gespeichert in: {filename}")
    print(f"  结果已保存到: {filename}")
    
    print("\n" + "=" * 60)
    
    return tlr_answer

def main():
    """Main game loop"""
    state = GameState()
    
    try:
        # Intro
        intro()
        
        # Life 1
        alive = life1(state)
        if not alive:
            print("\n  You died early. Game over.")
            print("  Du bist früh gestorben. Spiel vorbei.")
            print("\n  你早逝了。游戏结束。")
            return
        
        # Reincarnation
        reincarnation(state)
        
        # Life 2
        alive = life2(state)
        
        # Final choice (regardless of how life 2 ended)
        tlr_answer = final_choice(state)
        
        # Summary
        test_summary(state, tlr_answer)
        
    except (EOFError, KeyboardInterrupt):
        print("\n\n  [Test interrupted / Test unterbrochen / 测试中断]")
        sys.exit(0)

if __name__ == "__main__":
    main()

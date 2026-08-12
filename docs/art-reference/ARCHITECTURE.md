# 夏休み妖怪日記 — ARCHITECTURE

## 1. 技術方針

- Godot 4.x
- GDScript
- 2D
- Pixel Art
- 斜め見下ろし
- TileMapLayer
- CharacterBody2D
- AnimatedSprite2D
- SpriteFrames
- AnimationPlayer
- Camera2D
- CanvasModulate
- PointLight2D / Light2D
- AudioStreamPlayer / AudioStreamPlayer2D

3D、Blender、GLBは本プロジェクトの標準パイプラインから除外する。

---

## 2. ディレクトリ

```text
/
├─ AGENTS.md
├─ README.md
├─ project.godot
│
├─ docs/
│
├─ scenes/
│  ├─ bootstrap/
│  ├─ player/
│  ├─ maps/
│  │  ├─ grandma_house/
│  │  ├─ village/
│  │  ├─ river/
│  │  ├─ shrine/
│  │  └─ ...
│  ├─ npc/
│  ├─ yokai/
│  ├─ minigames/
│  ├─ ui/
│  └─ debug/
│
├─ scripts/
│  ├─ core/
│  ├─ player/
│  ├─ interaction/
│  ├─ events/
│  ├─ npc/
│  ├─ yokai/
│  ├─ diary/
│  ├─ save/
│  ├─ minigames/
│  └─ ui/
│
├─ resources/
│  ├─ events/
│  ├─ npc/
│  ├─ yokai/
│  ├─ items/
│  ├─ insects/
│  ├─ fish/
│  └─ locations/
│
├─ assets/
│  ├─ sprites/
│  ├─ tilesets/
│  ├─ props/
│  ├─ ui/
│  ├─ vfx/
│  ├─ audio/
│  └─ music/
│
├─ tests/
└─ tools/
```

---

## 3. Autoload

推奨:

```text
GameState
GameClock
CalendarManager
WeatherManager
WorldState
EventManager
NPCManager
YokaiManager
DiaryManager
SaveManager
AudioManager
SceneTransitionManager
```

Autoloadは便利だが、万能Manager化は禁止する。

---

## 4. GameState

責務:

- 現在のゲームフェーズ
- 現在エリア
- プレイヤー参照
- 一時停止状態
- Manager間の軽量な調停

保持しないもの:

- 妖怪個別イベントロジック
- NPC個別ロジック
- 日記文章
- 大量のWorld flag

---

## 5. GameClock

責務:

- 分単位のゲーム内時刻
- 時間進行
- pause
- time_scale
- 時間帯判定

例:

```text
05:00–09:59 morning
10:00–16:29 daytime
16:30–18:59 evening
19:00–04:59 night
```

Signal例:

```gdscript
signal minute_changed(total_minutes: int)
signal period_changed(period: StringName)
signal day_end_requested()
```

---

## 6. CalendarManager

責務:

- プレイ日数 1〜30
- カレンダー日付
- 特別日
- お盆
- 夏祭り
- 最終日

実ゲーム上の「7月/8月」表記は後から調整可能とし、
内部では `day_index` を基準にする。

---

## 7. WeatherManager

初期Enum:

```gdscript
SUNNY
CLOUDY
RAIN
THUNDERSTORM
```

責務:

- 当日の天気
- 天候変更
- マップへの通知
- NPC/Yokai/Event条件への情報提供
- Audio/VFX切替要求

---

## 8. WorldState

永続Flagや解除状態を管理する。

例:

```text
secret_base_unlocked
river_shortcut_unlocked
shrine_back_path_unlocked
abandoned_station_discovered
festival_completed
```

ルール:

- Sceneスクリプトに大量のBooleanを散らさない。
- `WorldState` は辞書の無秩序な物置にしない。
- Flag命名規則を統一する。

---

## 9. Player Scene

推奨:

```text
Player (CharacterBody2D)
├─ AnimatedSprite2D
├─ CollisionShape2D
├─ InteractionDetector (Area2D)
│  └─ CollisionShape2D
├─ ShadowSprite (Sprite2D)
├─ AnimationPlayer
└─ StateMachine / components
```

基本機能:

- 8方向移動
- idle
- walk
- run
- interaction lock
- animation state

Vertical Sliceでは複雑な状態機械を作りすぎない。

---

## 10. Pixel-perfect Camera

`Camera2D` を使用。

要件:

- 基準解像度を固定
- 整数スケーリングを優先
- SubpixelによるSpriteブレを抑える
- Zoom値をむやみに動的変更しない

---

## 11. Map Scene

例:

```text
RiverMap (Node2D)
├─ Ground (TileMapLayer)
├─ Water (TileMapLayer)
├─ DetailsBack (TileMapLayer)
├─ Collision (TileMapLayer)
├─ Objects (Node2D)
├─ NPCs (Node2D)
├─ Yokai (Node2D)
├─ EventTriggers (Node2D)
├─ Foreground (TileMapLayer)
├─ Lighting
└─ Audio
```

Y-sortが必要なオブジェクトは同一方針に従う。

---

## 12. Collision Layer

初期案:

```text
1 Player
2 World
3 Interaction
4 NPC
5 Yokai
6 Insects
7 EventTriggers
8 Water
```

プロジェクト開始時に `project.godot` 上で名前を固定する。

---

## 13. Interaction

共通Contract:

```gdscript
func can_interact(actor: Node) -> bool
func get_interaction_text(actor: Node) -> String
func interact(actor: Node) -> void
```

対象:

- NPC
- 妖怪
- 調査物
- 虫
- ドア
- 道具
- 小物

Interaction UIは候補がある場合のみ表示する。

---

## 14. NPC Architecture

NPC Scene:

```text
NPC (CharacterBody2D)
├─ AnimatedSprite2D
├─ CollisionShape2D
├─ InteractionArea
├─ AnimationPlayer
└─ ScheduleComponent
```

データ:

- npc_id
- display_name
- schedule
- dialogue_set
- state
- portrait/icon

NPCスケジュールはResource化する。

---

## 15. Yokai Architecture

基本SceneはNPCと近いが、
Yokai stateと出現条件を別Resourceで持つ。

Yokai state:

```text
UNKNOWN
TRACE
SEEN
CONTACTED
FRIENDLY
CLOSE
```

妖怪固有ロジックを `YokaiManager` に集約しない。

---

## 16. EventManager

役割:
条件に合うイベント候補を評価し、開始を管理する。

EventResource概念:

```text
id
priority
conditions
actions
one_shot
cooldown
exclusive_group
```

Eventは `EVENT_GUIDE.md` の規約に従う。

---

## 17. Dialogue

Dialogue systemは以下に対応する。

- 話者
- 本文
- 選択肢
- 条件分岐
- Flag設定
- Event actionとの連携

Vertical Sliceでは簡潔な構造から開始し、
外部Dialogueプラグインの導入は必要性を確認してから判断する。

---

## 18. Diary

`DiaryManager` はDayRecordを受け取り、表示可能なデータへ変換する。

DayRecordは「その日の事実」を保持し、
UI表示文章は別レイヤーで扱う。

---

## 19. Save

`SaveManager` はJSONまたはGodotの安全なDictionaryシリアライズを採用する。

ゲームオブジェクト自体を直接保存しない。
IDと状態値を保存する。

詳細は `SAVE_FORMAT.md`。

---

## 20. DebugMenu

必須機能:

- Set Day
- Set Time
- Set Weather
- Teleport
- Set Yokai Stage
- Trigger Event
- Give Item
- Set Money
- Show Event Candidates
- Save
- Load
- Reset

本番ビルドでは無効化。

---

## 21. Signal利用

Manager間の直接依存を減らす。

例:

```text
GameClock.period_changed
WeatherManager.weather_changed
CalendarManager.day_changed
EventManager.event_started
DiaryManager.entry_added
```

Signalの乱用も避ける。
明確な所有者がいる処理は直接APIで行う。

---

## 22. データ駆動

以下はResource化を優先:

- 妖怪
- NPCスケジュール
- Event
- Item
- Insect
- Fish
- Location

Sceneに直接大量の設定値を書かない。

---

## 23. コーディング規則

- 1クラス1責務
- Magic number禁止
- Export variableを適切に使用
- `get_node("../../..")` の多用禁止
- 型指定を可能な範囲で使用
- IDは `snake_case`
- Resource IDは永続Saveと連携するため変更に注意
- Debug printを本番コードに放置しない

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

---

## 24. Milestone 0 実装基準

- 基準解像度: 640x360
- Window stretch: `canvas_items` / `keep` / integer scale
- Texture filter: Nearest、Mipmap filter無効
- 2D transform / vertex pixel snap有効
- 初期Autoload: `GameState`, `GameClock`, `CalendarManager`, `SaveManager`, `SceneTransitionManager`
- DebugMenuはdebug buildでのみ有効
- `foundation_test` は基盤確認用Scene IDであり、本番ロケーションではない

Playerの表示はMilestone 0専用のコード描画Placeholderとする。
Reference Sheetから切り出した画像は使用せず、Production Sprite完成後に
`AnimatedSprite2D` の`SpriteFrames`へ差し替える。

---

## 25. Player Movement — Issue #020

- `Input.get_vector`によるKeyboard / Controller共通の8方向入力
- 斜め移動はベクトル長を1へ制限し、軸方向と同速度にする
- walk 80 px/s、run 128 px/sを初期値とし、Player Sceneから調整可能にする
- 最後に入力された向きを`down`から`down_right`までの`StringName`で保持する
- Dialogue / Eventから利用できる`set_movement_locked()`を提供する
- Playerの移動には`CharacterBody2D.move_and_slide()`を使用する

歩行アニメーションと方向別Sprite切替はIssue #021の責務とする。

---

## 26. Interaction System — Issue #022

対象はInteraction collision layerを持つ`Area2D`とし、次のContractを実装する。

```gdscript
func can_interact(actor: Node) -> bool
func get_interaction_text(actor: Node) -> String
func interact(actor: Node) -> void
```

Player配下の`InteractionDetector`が向いている方向へ追従し、重なっている
利用可能な対象のうち最短距離のものを候補にする。同距離の場合のみ
`interaction_priority`を使用する。候補がない場合はInteraction UIを表示しない。

`Interactable`は共通の最小実装であり、NPC・妖怪・ドア等はContractを守りつつ
固有処理をそれぞれの責務内に実装する。InteractionDetectorは個別種別を知らない。

---

## 27. Dialogue System — Issue #023

会話データはSceneから分離したResourceで構成する。

```text
DialogueResource (dialogue_id, lines)
└─ DialogueLine (speaker, text, choices)
   └─ DialogueChoice (text, next_line_index)
```

`DialogueController`は現在行、UI表示、通常送り、選択肢分岐、終了を管理する。
会話中はactorの`set_movement_locked(true)`を呼び、終了時に解除する。
GameClockは会話開始前のpause状態を保存して停止し、会話終了時に元へ戻す。
`DialogueInteractable`がInteraction ContractとDialogue開始を橋渡しする。

`dialogue_id`は将来のEvent historyやSave参照に利用できる永続IDとして扱う。
条件分岐、Flag変更、Event actionとの連携はWorldState / EventManager導入時に
Resourceへ拡張し、DialogueControllerへゲーム固有条件を直書きしない。

---

## 28. NPC / Grandma Base — Issue #024

汎用NPC Sceneは`CharacterBody2D`をルートとし、描画、Body Collision、
Dialogue用InteractionArea、AnimationPlayerを分離する。

`NPCData`が永続`npc_id`、表示名、初期向き、標準Dialogueを保持する。
NPC Scene固有スクリプトへ個別会話を直書きしない。

祖母は`npc_id = grandma`のNPCDataと専用Sceneで構成する。Production Spriteは
未完成のため、コード描画Placeholderを使用する。Reference SheetのCropは使用しない。
祖母の生活行動・Schedule・状態差分は後続IssueでComponent / Resourceとして追加する。

---

## 29. Day-period Visual Controller — Issue #028

`DayPeriodVisualController`はScene配下の`CanvasModulate`として配置し、
`GameClock.period_changed`を購読する。Core Clockは描画Nodeを参照しない。

朝・昼・夕・夜の色は`DayPeriodPalette` Resourceへ分離し、Locationごとの差し替えを
可能にする。切替は短いTweenで行い、Debugによる時刻変更にも同じSignal経路で反映する。

初期色は方向性確認用であり、Production MapとVisual Playtest後に調整する。
夜を真っ暗にせず、夕方の郷愁を優先するART_GUIDEの方針に従う。

---

## 30. Bug Entity — Issue #030

虫の不変設定は`InsectData` Resourceに分離し、永続`insect_id`、表示名、
移動速度、方向転換間隔を持つ。Entityは`CharacterBody2D`として
`PERCHED / MOVING / CAUGHT`の最小状態だけを管理する。

捕獲処理は`request_catch()`で要求Signalを発行し、判定側が成功時に
`confirm_caught()`を呼ぶ。網の範囲、成功率、所持品追加、演出はIssue #031で扱う。

Production虫Spriteは未完成のためコード描画Placeholderを使用し、
Reference Sheetの虫画像はCropしない。

---

## 31. Bug Catching Mechanic — Issue #031

Player配下の`BugCatcher` Area2Dが向いている方向へ追従し、`use_tool`入力時に
範囲内で最も近い未捕獲Insectへ捕獲を要求する。初期Vertical Sliceでは
範囲内なら確定成功とし、確率・レアリティ・複雑な照準UIを導入しない。

連打防止の短いcooldownを持ち、Dialogue / Debug pause / movement lock中は使用不可。
成功・空振りはSignalでHUDや将来のInventory / DayRecordへ通知する。

網Sprite、振り下ろしAnimation、捕獲VFX、Inventory追加はProduction Assetと
各責務の実装時にSignalへ接続する。

---

## 32. Minimal Event / Yokai State — Issues #032〜#034

- `WorldState`: 永続Flagと発見Location
- `YokaiManager`: `UNKNOWN → TRACE → SEEN → CONTACTED → FRIENDLY → CLOSE`
- `EventCondition`: day / location / time period / flag / Yokai stage
- `EventDefinition`: priority / one-shot / exclusive group / actions
- `EventManager`: 登録、候補評価、理由表示、開始、history

Actionの初期対応はFlag設定・解除とYokai stage変更に限定する。Scene演出は
`event_started` SignalをPresenterが購読し、EventManagerへ固有Nodeを持ち込まない。

河童は`kappa`の永続IDを持ち、仕様どおりDay 2のTRACE、Day 3以降のSEENを
別Event Resourceで定義する。見せ方は波紋と短いPlaceholder表示のみで、
派手なSpawn演出やReference SheetのCropは行わない。

---

## 33. DayRecord / Diary / Save — Issues #036〜#038

`DayRecord`はその日の事実だけを保持する。Location、NPC、Yokai、虫、Eventは
Signalを購読する`DayRecordRecorder`から記録し、各Entityへ日記依存を入れない。

`DiaryManager`は日別Recordの所有・重複排除・serializeを担当する。
`DiaryUI`は現在日の事実をノート形式で表示し、文章生成やEvent条件を持たない。

Save v1既定fieldの`world`、`yokai_states`、`event_history`、`diary.days`へ接続する。
既存Schema内の実装なのでsave_versionは1を維持する。

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
4方向SpriteFramesを専用Sceneから汎用NPCへ注入し、向き変更時に`idle_<direction>`を
切り替える。Production frames未設定のNPCだけコード描画Placeholderを使用する。
Reference SheetのCropは使用しない。
祖母の生活行動・Schedule・状態差分は後続IssueでComponent / Resourceとして追加する。

---

## 29. Day-period Visual Controller — Issue #028

`DayPeriodVisualController`はScene配下の`CanvasModulate`として配置し、
`GameClock.period_changed`を購読する。Core Clockは描画Nodeを参照しない。

朝・昼・夕・夜の色は`DayPeriodPalette` Resourceへ分離し、Locationごとの差し替えを
可能にする。切替は短いTweenで行い、Debugによる時刻変更にも同じSignal経路で反映する。

色値はProduction Mapに合わせて調整し、夜を真っ暗にせず、夕方の郷愁を優先する
ART_GUIDEの方針に従う。

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

河童は`kappa`の永続IDを持ち、Vertical SliceではDay 1の川沿いでTRACE、続いてSEENを
別Event Resourceと離れた`EventTriggerArea`で定義する。通常歩行で自然に発火し、
目撃後は夕方へ進む。見せ方は波紋と非ループの4 frame `surface` Production Spriteを
1.2秒だけ表示する。皿だけが見える状態から上半身を一瞬見せて潜る流れとし、
派手なSpawn演出やReference SheetのCropは行わない。

---

## 33. DayRecord / Diary / Save — Issues #036〜#038

`DayRecord`はその日の事実だけを保持する。Location、NPC、Yokai、虫、Eventは
Signalを購読する`DayRecordRecorder`から記録し、各Entityへ日記依存を入れない。

`DiaryManager`は日別Recordの所有・重複排除・serializeを担当する。
`DiaryUI`は現在日の事実をノート形式で表示し、文章生成やEvent条件を持たない。
Production UIでは512x320の開いたノート背景に、安定IDから変換した表示名と
天気・河童・虫の独立した記録印を重ねる。背景画像へ文字を焼き込まず、未知IDは
保存値をそのままfallback表示するため、Save schemaと記録責務は変更しない。
通常のJキー閲覧は224x280の閉じた表紙から始まり、`interact`で日別ページへ進む。
表紙から紙面への短いTweenは`DiaryUI`内の表示状態だけを変更し、DayRecordには
書き込まない。夕食後の必須Reviewは操作を一段増やさないよう日別ページを直接開く。

Save v1既定fieldの`world`、`yokai_states`、`event_history`、`diary.days`へ接続する。
既存Schema内の実装なのでsave_versionは1を維持する。

---

## 34. Vertical Slice Playtest Tools — Issue #039

再現可能なテスト状態は`PlaytestPreset` Resourceとして管理する。初期Preset:

- 朝の基準状態
- 河童の気配直前（Day 2 / river / daytime）
- 河童目撃直前（Day 3 / TRACE完了済み / evening）

`PlaytestDebugController`はPreset適用、既知地点Teleport、状態Snapshot、
実行中状態Resetを担当する。DebugMenuは表示とユーザー操作だけを受け持つ。
DebugMenuは640x360の基準解像度に収まる二列構成とし、開く前の時計pause状態を復元する。

Reset対象は日付・時刻・Location・Player transform・World・Yokai・Event history・
Diaryであり、登録EventやSaveファイルは削除しない。本番BuildではDebugMenu自体を無効化する。

---

## 35. Player Animation — Issue #021

`PlayerAnimationController`はPlayerの移動Signalを購読し、次の命名規則で
`AnimatedSprite2D`のAnimationを選択する。

```text
idle_<direction>
walk_<direction>
run_<direction>
```

directionはPlayer移動と同じ8方向とする。斜め方向のProduction framesが未完成の場合は
同じ左右側の4方向Animationへfallbackできるが、状態名自体は8方向を保持する。

Production Spriteは未完成のため、現時点ではコード描画の足踏みPlaceholderを使用する。
Reference SheetはCropせず、`SpriteFrames`へProduction Assetが設定された時点で
同じControllerが自動的にSprite Animationへ切り替わる。

---

## 36. Environment Audio — Issue #029

環境音はLocation Scene配下の`EnvironmentAudioController`が担当し、Core Managerへ
Scene固有の音源を持ち込まない。`EnvironmentAudioProfile` Resourceがarea IDと
morning / daytime / evening / nightのLoop音源、音量を保持する。

Areaまたは時間帯の変更時は2つの`AudioStreamPlayer`間でcrossfadeする。
Production音源が未設定の枠は無音とし、仮の生成音やReference由来音声で埋めない。
音源追加後もProfileへの割り当てだけで切替可能な構造とする。

---

## 37. Grandma House / Home Outdoor Greybox — Issues #025–#026

各Locationは`LocationScene`をrootにし、永続的な`area_id`と入口IDを持つ
`MapSpawnPoint`を所有する。`MapDoorway`はInteraction contractを実装し、
遷移先Sceneと入口IDだけをSceneTransitionManagerへ渡す。

共通のPlayer、HUD、Dialogue、Diary、Debug、時間帯描画、環境音は
`LocationRuntime` Sceneへまとめる。Location固有Entityや配置は共通Runtimeへ入れない。

祖母の家は寝室・居間・台所・縁側、家周辺は家・田舎道・畑の関係を確認できる
Greyboxとする。Production TileMap差し替え用にGround / DetailsBack / Collision /
Foregroundの`TileMapLayer`階層を先に固定する。コード描画面はProduction Assetではない。

家周辺の最初のProduction Art検証では、640x360背景プレートをGroundとDetailsBackの間に
配置し、既存TileMapLayer契約とCollisionを維持する。色・密度・導線の実画面評価後、
複数Mapで再利用する要素だけを32x32 modular TileSetへ分解する。

祖母の家も640x360 Production背景プレートで実画面の生活感を先に検証し、寝室・居間・
台所・縁側のCollisionと入口契約を維持する。家具の個別操作が必要になった時点で、
背景プレートから独立したObject Sceneへ切り出す。

Riverは追加でWater `TileMapLayer`と水域Collisionを分離する。岸沿いの歩行帯に
河童の波紋・一瞬の目撃Presenterを配置し、水面内へPlayerを侵入させない。
家周辺東端と川の帰路を入口IDで相互接続する。

川の最初のProduction Art検証も640x360背景プレートを使用し、Water `TileMapLayer`と
Collision契約を維持する。背景には河童の波紋を描き込まず、4 frameのProduction VFXを
PresenterがEvent発火中だけ表示する。SEEN時は同じPresenterが河童の4 frame非ループ
`surface` Animationを同期表示し、EventManagerへScene固有の演出参照を持ち込まない。

---

## 38. Return-home Flow — Issue #035

祖母の家固有の`ReturnHomeFlow`が、夕方・夜の祖母Dialogue、当日の日記Review、
翌朝への進行を調停する。NPC、DialogueController、DiaryUI、CalendarManagerへ
祖母の家固有条件を持ち込まない。

```text
夕方・夜に祖母と会話
→ 夕食会話
→ 当日のDiary Review
→ 日記を閉じる
→ 翌日07:00
→ 寝室Spawn
→ Autosave
```

Diary Review開始時に当日の`sleep_time`と`evening_diary_written` fragmentを確定する。
通常のJキーによる日記閲覧は日付を進めない。Day 30は31日目へ進めず、Review完了だけを記録する。
Save v1既存fieldだけを使用するため、save_versionは変更しない。

---

## 39. Vertical Slice Polish — Issue #040

### Location-aware Load

`LocationCatalog`が永続`scene_id`とMap Scene pathの対応を一箇所で管理する。
実ゲームのLoadはSave内のLocationが現在地と異なる場合、先にSceneを交換してから
Player位置・向きと各Manager状態を復元する。未知の`scene_id`は現在状態へ適用せず拒否する。

DebugMenuはLoad前に自身を閉じ、Global pauseとClock pauseを復元してからScene交換する。
Save v1 Schemaは変更しない。

---

## 40. Vertical Slice One-day Flow — Issue #041

`EventTriggerArea`はLocation固有の小さなArea2Dとして、Player接近時に指定Eventを
通常条件付きで発火する。川の順路上でTRACEとSEENを空間的に分け、同時発火を避ける。

祖母の家の`ReturnHomeFlow`はopt-inのVertical Slice終了モードを持つ。本編では
`end_vertical_slice_after_review`をfalseのままにし、夕食後の日記を閉じると翌日07:00の
寝室Spawnへ進む。Vertical Sliceの一日通しSmokeだけがexportをtrueにし、
`vertical_slice_complete` flag・完了Panel・入力停止・時計停止でDay 1を終える。
本編進行は`vertical_slice_complete`を必須条件にしない。CalendarManagerとSave v1 Schemaには
Vertical Slice固有条件を追加しない。

---

## 41. Bug-catching Production Presentation — Issue #047

捕獲判定は既存の`BugCatcher`へ維持し、虫網の表示・振りアニメーション・成功／空振りの
小さな視覚フィードバックはPlayer配下の`BugCatchPresenter`がSignalを購読して担当する。
演出からInventory、日記、Save状態は直接変更しない。

Vertical Sliceの虫Entityは独立制作したアブラゼミのProduction Spriteを使用する。
Reference SheetのCropは行わず、Texture FilterはNearest、MipmapはOFFとする。
虫網はPlayerの向きへ追従し、上向きではPlayerの背面、それ以外では前面に表示する。
成功演出は小さな輪ときらめき、空振りは短い風切り線に留める。

---

## 42. Vertical Slice Production Audio — Issue #048

`EnvironmentAudioProfile`へProduction音源を割り当て、既存の2 Player crossfade構造を維持する。
環境Loopは`EnvironmentAudioController`が`AudioStreamOggVorbis.loop`を有効化し、
import設定へ実行時仕様を依存させない。

- 祖母の家: 小さな室内のRoom Toneを全時間帯のdefaultとして使用
- 家周辺: daytimeはアブラゼミ、eveningはヒグラシ、未制作のmorning / nightは無音
- 川: 流水音を全時間帯のdefaultとして使用

河童の水面音はLocation環境音と分離し、`KappaGlimpsePresenter`配下の
`AudioStreamPlayer2D`がTRACEで波紋音、SEENで波紋音と控えめな気配音を同期再生する。
音源の権利・加工履歴は`docs/AUDIO_LICENSES.md`を正とする。

---

## 43. Minimal Production HUD — Issue #051

`GameplayHUD`はLocation共通Runtimeに置き、日付・時刻・時間帯・当日の天気・現在の道具だけを
常時表示する。目的地、Quest marker、Event候補は表示しない。天気は現在の`DayRecord.weather`を
読み取るだけで、HUDから日記やSave状態を変更しない。

操作Promptは有効なInteraction候補がある間だけ画面下へ表示する。虫取りの成功・空振り通知は
同じPrompt枠を1.6秒だけ借り、終了後に現在のInteraction候補へ戻す。Foundation専用の常設操作一覧は
削除し、Bootstrapも共通`gameplay_hud.tscn`をinstanceして本編との表示契約を共有する。

Vertical Sliceでは虫取り網だけが利用可能なためTool indicatorは`BugCatcher`の存在時だけ表示する。
将来の複数道具切替はInventory / Tool Manager導入IssueでSignal接続し、このHUDへ所持品責務を加えない。

---

## 44. Action / UI Production SFX — Issue #052

虫網の風切り音と捕獲成功音はPlayer配下の`BugCatchPresenter`が既存`BugCatcher` Signalを購読して
再生する。判定側は音源やAudio Nodeを参照しない。風切り音は`tool_used`時、成功音は視覚Feedbackと
同じ0.1秒後に再生し、空振りでは成功音を鳴らさない。

ページ音は`DiaryUI`が表紙から日別ページへAnimation付きで進む時だけ再生する。夕食後Reviewの
日別ページ直開きでは鳴らさず、画面状態と音の意味を一致させる。すべて1秒未満のmono Oggとし、
環境音・会話を妨げない音量に固定する。Save schemaと各ゲーム状態には影響しない。

---

## 45. Dialogue Production UI — Issue #053

`DialogueController`のResource・分岐・移動lock・時計pause契約は維持し、表示Sceneだけを
Production紙面へ差し替える。560x132の会話枠は画面下へ固定し、話者名札を背景へ統合する。
本文と話者名はTextureへ焼き込まず、既存`DialogueLine`から動的に表示する。

選択肢は会話枠の右上へ最大2件を縦に表示し、240x42の共通TextureをTheme経由でButtonへ適用する。
focus / hover / pressedは文字と枠の明度を併用し、色だけに依存しない。Vertical Sliceでは立ち絵を
追加せず、会話中も町とNPCの姿が残る面積を優先する。

---

## 46. Production Day-period Palette — Issue #054

共通`default_day_period_palette.tres`をVertical Sliceの3背景に合わせて調整する。朝は明るい薄金、
昼は元絵を保つごく薄い暖色、夕方は帰宅を感じる橙、夜は道路・水際・Playerを識別できる青灰とする。
背景Texture自体へ時間帯差分を焼き込まず、既存`CanvasModulate`構造を維持する。

時間帯の切替は3秒のsine easingで行う。同じ色への再適用ではTweenを作らず、Debug時刻変更などで
遷移途中に別の時間帯へ変わった場合は既存Tweenを破棄して現在色から再補間する。CanvasLayer上の
HUD・Dialogue・Diaryは別Canvasのため色調補正対象に含めない。

---

## 47. UI Confirm / Cancel Production SFX — Issue #055

UI操作音は巨大なAudio Managerへ集約せず、操作の意味を所有するScene内の`AudioStreamPlayer`で再生する。
`DialogueController`は通常送りと有効な選択肢決定で短い上昇音を鳴らし、無効な選択や選択肢待ちの
`advance`では鳴らさない。`DiaryUI`はJ / Escによる閉じる操作だけで短い下降音を鳴らし、ページ遷移には
既存の紙音を使用して二重再生を避ける。

音源は0.5秒未満のmono Oggとし、時計pause中も再生可能なScene-local Audio Nodeへ割り当てる。
DebugMenuはProduction Buildで無効になる開発UIのため対象外とする。Save schemaとゲーム状態は変更しない。

---

## 48. Vertical Slice Production Audit — Issue #056

`vertical_slice_production_audit`はVertical Sliceで実際に使用するMap、Character、河童、虫取り、HUD、
Dialogue、Diary、VFX、AudioのProduction Asset契約を独立して検証する。Reference Sheet、制作元画像、
候補画像をSceneやSpriteFramesから参照していないこと、背景Plateの解像度、640x360整数Scale、Nearest設定、
非表示Greybox fallbackを確認する。

この監査は既存の一日通しSmoke Testを置き換えず、フロー検証と素材検証を分離する。一括Validationは
Foundation、Map遷移、帰宅、1日通し、Production監査、クリック移動、クリック行動、対象Hover、マウスUI、祖母宅Geometry、家周辺Geometry、川Geometry、Foreground遮蔽、祖母屋内生活移動、Save復元の15 Sceneを実行する。未使用の将来素材は
監査対象へ含めず、`ASSET_CATALOG.md`で未完了のまま管理する。Save schemaへの影響はない。

---

## 49. Mouse Click Movement Foundation — Issue #057

`ClickMoveController`はPlayer配下で左クリックの目的地、経路上の次方向、右クリックCancelだけを担当する。
最終的な速度、8方向Facing、Animation、Collisionは既存`Player`の`_apply_movement()`へ集約したままにする。
Keyboard方向入力がある場合はクリック移動をCancelし、既存操作を即座に優先する。

各Mapは背景やCollisionから独立した`NavigationRegion2D`を持つ。目的地はNavigation Map上の最寄り点へ
丸め、家・用水路・川を横切らず歩行可能領域を経由する。会話、日記、Debug pause、一日終了などの
movement lock中は新しい目的地を拒否し、進行中の経路とMarkerを消去する。

目的地点Markerは小さなコード描画表示とし、Quest markerや常設目的地案内には使用しない。NPC、虫、
出入口をクリックした後の接近・Interaction予約は別責務の`ClickActionController`へ分離し、本Issueの移動Componentは地面移動だけを扱う。
クリック目的地は一時状態のためSave対象に含めない。

---

## 50. Mouse Click Approach / Action Queue — Issue #058

`ClickActionController`はクリック位置の小さなPhysics queryから、NPC・`Interactable`・`Insect`を選択し、
対象種別と一度限りの行動を予約する。地面クリックの判定は引き続き`ClickMoveController`が担当し、対象が
見つかった場合だけ行動予約へ切り替える。

予約後は対象位置まで既存Navigationで接近し、Interactionは`InteractionDetector.try_interact_target()`、
虫取りは`BugCatcher.attempt_catch_target()`を通して実行する。距離外からSignalやScene遷移を直接発火せず、
既存の会話lock、日記記録、捕獲演出、SFXを維持する。移動する虫は一定距離以上ずれた時だけ再探索する。

右クリック、Keyboard移動、movement lock、Pause、対象消失で予約を破棄する。予約対象と経路は一時状態であり
Saveしない。河童の気配・Event Triggerはクリック対象に含めず、歩行中の環境発見を維持する。

---

## 51. Mouse-first Dialogue / Diary UI — Issue #059

`DialogueController`は会話枠の左クリックを通常送りとして扱い、既存の`advance()`と決定音を再利用する。
選択肢表示中は会話枠クリックで進めず、既存の動的`Button`をクリックして`choose()`へ入る。本文Labelは
Mouse入力を会話枠へ透過し、会話枠はイベントを消費して背後の移動・Interactionへ漏らさない。

通常HUDには小さな日記Buttonを置き、押された時点で`diary_ui` Groupから同一Sceneの`DiaryUI`を解決する。
Scene初期化順に依存するNodePathは持たず、Pause中またはPlayerがlock中なら開かない。日記表紙のページButtonと
右上の閉じるButtonは、既存のページTween、紙音、キャンセル音、移動lock、`closed` Signalをそのまま使用する。

夕方の帰宅Flowが開く日記Reviewは従来どおり日別ページから開始し、閉じるButtonでも既存の一日終了処理へ戻る。
Keyboard操作は代替入力として維持する。UIの表示状態とクリックは一時状態で、Save schemaは変更しない。

---

## 52. Subtle Click-target Hover Feedback — Issue #060

`ClickTargetHoverController`はPlayer配下の独立した表示Componentとして、既存`ClickActionController.pick_target_at()`を
再利用する。Hover用に別の対象判定やCollision Layerを増やさず、実際にクリックして予約可能なNPC、`MapDoorway`、
未捕獲の`Insect`だけを同じ規則で選択する。

対象上では標準カーソルを指形へ変更し、数Pixelの四隅だけを描く枠を対象位置へ重ねる。NPCは全身、出入口は
足元を横長、虫は小さな正方形とし、常設Icon、目的地矢印、発光Textureは追加しない。地面へ外れた時、捕獲後、
会話・日記などのmovement lock中、Pause中、UI上では即座に非表示とし、カーソルを標準へ戻す。

Hover対象とカーソル状態は一時的なPresentation状態であり、行動予約、Event条件、Diary記録、Save schemaを変更しない。
河童の気配やEvent TriggerはHover対象に含めず、環境から気付く設計を維持する。

---

## 53. Grandma House Production Gameplay Geometry — Issue #061

祖母宅Sceneの`GreyboxWalls`と全面長方形Navigationを廃止し、背景Plate上の足元基準で
`WorldCollision`と`NavigationBakeBounds`を定義する。`WorldCollision`は外周に加え、ベッド、棚、テレビ台、
丸机、台所設備、食卓、部屋境、障子を個別の単純Polygonとして持つ。画像のPixel輪郭を過剰に追わず、
Playerの6px Collision半径で通路を安全に通れる形状を優先する。

Navigationは`tools/bake_2d_navigation.gd`でEditor用Resourceへ事前Bakeする。外周は
`NavigationBakeBounds`、障害物は`WorldCollision`配下の`CollisionPolygon2D`と対象Rectangleから取得し、
7pxのagent radiusで縮小する。Physics境界用Shapeは`navigation_bake_exclude` Metadataで二重に差し引かない。
生成した`grandma_house_navigation.tres`をProduction Sceneから参照し、実行時Bakeは行わない。

再生成Command:

```powershell
godot --headless --path . --script res://tools/bake_2d_navigation.gd -- res://scenes/maps/grandma_house/grandma_house.tscn res://resources/navigation/grandma_house_navigation.tres
```

寝室Spawnはベッド上から畳のベッド脇へ、祖母は丸机とテレビ台の間の通路へ移す。Spawn ID、Area ID、
Dialogue、帰宅Flow、Save schemaは変更しない。川も同じProduction Geometry方式へ移行済みとする。

---

## 54. Home Outdoor Production Gameplay Geometry — Issue #062

家周辺Sceneの`GreyboxCollision`と格子状Navigationを廃止し、背景Plate上の上側土道、中央橋、下側庭道を
主要な歩行面として定義する。`WorldCollision`は家の基礎、石灯籠、郵便受け、樽、右側の流れ、左右の用水路、
水田、トウモロコシ畑、庭の植栽区画を単純Polygonで表現する。上側土道は水面より手前の乾いた地面に置き、
庭道は植栽区画の外を回る。橋の物理幅29pxに対して7pxのagent radiusを
差し引き、Player中心用の15px幅Navigationを確保する。

`NavigationBakeBounds`と`tools/bake_2d_navigation.gd`を祖母宅と共用し、生成済み
`home_outdoor_navigation.tres`をProduction Sceneから参照する。上側道路から橋を通らず水路を横断するPathや、
水田・畑内部を目的地にするPathは生成しない。家入口、左道路、川方面の既存Spawn IDは維持し、背景に合わせて
家前Spawnと入口Interaction位置だけを石段前へ調整する。

アブラゼミはトウモロコシ畑内部から右側の庭道へ移し、クリック接近で中央橋を経由して捕獲できるようにする。
位置、Navigation、Collisionは一時的なScene状態であり、`aburazemi` ID、Diary記録、Save schemaは変更しない。
川Sceneも同じProduction Geometry方式へ移行済みとする。

---

## 55. River Production Gameplay Geometry — Issue #063

川Sceneは、背景画像と一致しない単純な横長の水域Collisionおよび矩形Navigationを廃止し、岸の凹凸、左側の低木、右岸の岩、画面下部の植生に沿う`CollisionPolygon2D`へ置き換える。歩行可能領域は中央の土手道に限定し、水面内へのKeyboard移動とクリック移動の双方を防ぐ。

`NavigationRegion2D`は`resources/navigation/river_navigation.tres`を参照する。祖母宅・家周辺と共通の`tools/bake_2d_navigation.gd`で`NavigationBakeBounds`から`WorldCollision`を差し引き、Player半径7pxを考慮してBakeする。入口、河童の気配、河童目撃、Debug用河岸の各地点は同一の連結領域に残す。

左端の`ReturnHome`と`home_path` Spawnは、背景上の低木ではなく見えている土手道へ寄せる。永続ID、Event ID、Save schemaは変更しない。実移動でEvent Triggerへ入ったフレーム中に監視状態を直接変更しないよう、`EventTriggerArea`の無効化はdeferredで行う。

---

## 56. Three-map Gameplay Geometry Visual Tuning — Issue #064

`tools/capture_2d_geometry.gd`は、Production背景へPhysics Collision、Bake済みNavigation、Spawn、Doorway、Event Triggerを重ねた640x360 PNGを出力する開発用監査ツールとする。赤はCollision、緑はNavigation、青はSpawn、黄はDoorway、紫はEvent Triggerを示す。描画可能なDisplay Driverが必要なため`--headless`では実行せず、一時確認は`.godot/`へ、現行のVisual Regression基準は`docs/art-reference/03_gameplay/marker_first_geometry/`へ保存する。

実行例:

```powershell
godot --path . --audio-driver Dummy --position 10000,10000 --quit-after 10 --script res://tools/capture_2d_geometry.gd -- res://scenes/maps/river/river.tscn res://.godot/geometry_river.png
```

末尾へ`player_x player_y clean`を渡すと、Playerを指定座標へ置き、Geometry線なしの遮蔽確認画像を出力できる。

原寸Overlay監査により、祖母宅は扇風機の足元、食卓前椅子、中央植木、障子下部をCollisionへ反映する。扇風機は見た目全体ではなく床に接する台座だけを塞ぎ、寝室から中央通路への連結を維持する。家周辺は中央橋下の紫陽花・植栽帯へ入っていたNavigationを除外し、橋から下側の細道とアブラゼミへの右側経路を残す。川は画面下部の柵・植生境界を約10〜15px上へ寄せ、土道から柵内へ踏み込みすぎないようにする。

Navigation Resourceは各Sceneの補正後Collisionから再Bakeする。Spawn ID、Doorway ID、Event ID、虫ID、Save schemaは変更しない。

---

## 57. Production Foreground Occlusion — Issue #065

Production背景は1枚絵のまま維持し、前景化が必要な部分だけを`ForegroundOccluder2D`で再描画する。各Occluderは背景と同じTextureを参照し、Polygon頂点とUVへ同じPixel座標を設定する。新しいCrop画像や補間済みTextureを生成しないため、元のドットとNearest表示を保てる。

`ForegroundOccluder2D`は`occlusion_y`を固定のDepth `z_index`へ変換する。PlayerとNPCはそれぞれ`CollisionShape2D`下端のWorld Yを自身のDepthへ反映し、同じ机の前後に別々のCharacterがいる場合も各Character単位で描画順を決める。前景全体をPlayerだけに合わせてON/OFFしないため、Playerが奥にいる間に手前のNPCが机へ隠れる問題を防ぐ。移動、Collision、Navigation、Interactionの責務は持たない。CanvasModulateは背景・Occluder・Characterへ共通して適用されるため、時間帯変化でも切り抜きの色差は発生しない。

祖母宅は扇風機、丸机、中央植木、食卓、左右の障子を対象とする。家周辺は水田右端、中央庭の植栽、トウモロコシ畑左端、川は左側低木、紫陽花、画面下部の柵・植生を対象とする。細かいPixel輪郭を過剰に追わず、Player Spriteと接触し得る連続した前景だけをPolygon化する。既存背景、Production Asset、Save schema、永続IDは変更しない。

---

## 58. Grandma Indoor Living Routine — Issue #066

`NPC`は汎用的な`move_with_velocity()`と`stop_movement()`を持ち、移動方向に応じた4方向の`walk_*`／`idle_*` Animation切替だけを担当する。行き先や時間帯はNPC基底へ持ち込まない。祖母Sceneは`NavigationAgent2D`と5pxの屋内用足元Collisionを持ち、World CollisionとPlayer Bodyを避ける。

祖母宅Scene固有の`GrandmaIndoorRoutine`が`GrandmaRoutinePoints`配下のMarkerを順番に選び、28px/sで「ちゃぶ台左→ちゃぶ台南側→中央植木の南側→キッチン入口」を巡る。各地点では4秒程度立ち止まり、常に歩き続ける印象を避ける。Playerが36px以内へ近づいた時、祖母へのクリック接近が予約された時、Dialogue・日記などでClockまたはGameがPauseした時は即座に停止する。

夕方・夜は既存の夕食会話を安定して開始できるよう、祖母をちゃぶ台左の定位置へNavigationで戻して停止する。翌朝へ進んだ場合は生活移動を再開できる。中央植木のCollisionは葉全体ではなく床に接する根元を塞ぐ形とし、植木と障子の間にPlayerと祖母が通れるNavigation幅を確保する。キッチン内は食卓と設備で歩行床がほぼないため、生活地点は見えている入口までとする。

ルーチンの現在座標や待機秒数はScene内の一時状態とし、Saveしない。`grandma` NPC ID、Dialogue、DayRecord、ReturnHomeFlow、Save schemaは変更しない。

---

## 59. Grandma House Table Depth / Kitchen Passage Correction — Issue #067

机・植木・障子などの前景は固定Depthを持ち、PlayerとNPCは各自の足元YをDepthとして更新する。これにより、Playerが机の奥、祖母が机の手前に同時にいる場合でも、祖母だけが誤って机の下へ消えない。Characterの原点ではなくCollision下端を使い、Spriteの高さに左右されない足元基準を維持する。

中央植木のPhysics Collisionは見えている根元までに縮め、居間右側からキッチン入口`(462, 212)`へ至る通路をNavigationへ再Bakeする。食卓・調理台・障子のCollisionは維持し、背景上に明確な歩行床がないキッチン奥へは入れない。祖母の巡回も同じ経路を使用し、Player専用の抜け道や瞬間移動は設けない。

変更対象はScene内Geometry、事前Bake済みNavigation、描画順、祖母の一時的な巡回地点だけである。Spawn ID、NPC ID、Dialogue、Event条件、Save schemaは変更しない。

---

## 60. Area-based Insect Spawning — Issue #068

屋外Locationへ虫を固定配置せず、`InsectAreaSpawner`と`InsectSpawnProfile`で日付・Areaごとの
出現数と位置を決定する。各Sceneは木、草地、水辺など虫が自然に存在できる場所へ複数の
`Marker2D`を置き、Spawnerはその候補だけから選ぶ。画面内への出現演出は行わず、Locationへ
入った時点ですでにそこにいたように見せる。

乱数Seedは`area_id`と`day_index`から生成し、同じ日に同じAreaへ入り直しても配置を変えない。
Day 1の虫取り導入は最低1匹を保証する。捕獲済み判定には既存`DayRecord.caught_insects`を使い、
同日中に捕まえた種類はScene再入場で復活させない。個体座標や乱数状態はSaveへ追加せず、
Save v1 Schemaを維持する。

Vertical SliceではProduction素材がある`aburazemi`だけを使用する。家周辺は0〜2匹のうちDay 1に
最低1匹、川は0〜1匹とする。種類、時間帯、天気による出現表はProduction素材追加後に
Profileを拡張し、Spawnerへ条件分岐を直書きしない。

エリア細分化は新しいProduction背景を必要とするため別Issueとする。予定する粒度は
「寝室」「居間・台所」「縁側・庭」「田んぼ道」「用水路・木陰」「川入口」「川奥」で、
各エリアに固有の音・観察対象・移動上の意味を持たせる。既存背景のCropや引き伸ばしで
仮のProduction Sceneを作らない。

---

## 61. Vertical Slice Area Subdivision — Issue #069

Day 1の必須導線を、従来の3 Locationから次の7つの小さな生活空間へ分割する。

```text
bedroom
→ grandma_house
→ engawa_yard
→ paddy_road
→ irrigation_shade
→ river_entrance
→ river
```

各Locationは独立した640x360 Production背景、安定`area_id`、双方向`MapDoorway`、入口ごとの
`MapSpawnPoint`、`NavigationRegion2D`、Physics境界、時間帯描画、環境音を持つ。屋外4 Locationは
`InsectAreaSpawner`を持ち、Day 1の必須虫は`engawa_yard`で最低1匹保証する。

新規背景はReference SheetのCropではなく、Referenceと既存Production画面を制作基準にした独立Assetとする。
原寸Sourceは1672x941で保存し、Production版はNearestで640x360へ縮小する。SceneはSource画像を参照しない。

既存Saveとの互換性のため`grandma_house`、`home_outdoor`、`river` IDとCatalog entryは維持する。
新規IDは`bedroom`、`engawa_yard`、`paddy_road`、`irrigation_shade`、`river_entrance`とする。
Main Sceneは`bedroom`へ変更し、夕方は同じLocation列を逆向きに戻る。河童Event ID、Yokai stage、
ReturnHomeFlow、Save versionは変更しない。

---

## 62. Grandma House Living-room Production Integration — Issue #070

`grandma_house`は寝室を含む旧背景から、独立Production Asset
`assets/maps/grandma_house_living/map_grandma_house_living.png`へ切り替える。`area_id`、Doorwayの
遷移先、Spawn ID、祖母NPC、ReturnHomeFlow、Save v1契約は維持し、既存Saveの`grandma_house`を
同じSceneへ復元する。

Physics CollisionとNavigationは居間・台所背景の家具配置から再構築する。ちゃぶ台、テレビ台、
食器棚、台所、食卓、障子は足元を塞ぎ、左室から玄関、ちゃぶ台周囲、台所入口を接続する。
中央植木は見た目全体ではなく床へ接する足元だけをCollisionにし、台所への狭い生活動線を残す。

祖母は新しいちゃぶ台左側を朝夕の定位置とし、ちゃぶ台南側・右側・台所入口を既存の
`GrandmaIndoorRoutine`で巡回する。前景Occluderは新背景と同じTextureを参照し、ちゃぶ台、植木、
食卓、左右障子の足元を境にPlayer・祖母との前後関係を切り替える。

---

## 63. Authored Stroll Path Movement

各Locationは`WalkPathNetwork2D`を1つ持ち、非表示の`Line2D`子Nodeで歩行経路と分岐を定義する。
線の共有端点を接続点として扱い、`WalkPathNetwork2D`がクリック地点の投影、最短経路、Keyboard移動の拘束を担当する。

`ClickMoveController`は散歩道があるLocationではBake済みNavigationより散歩道を優先する。
`Player`はPhysics Collisionで背景を押し返すのではなく、毎Physics frameの移動結果を散歩道上へ拘束する。
`GrandmaIndoorRoutine`も同じ散歩道を使い、Player専用の抜け道を作らない。

既存`NavigationRegion2D`と`WorldCollision`は移行期間中の比較・既存監査用として残すが、Playerの到達可能座標を決める正本は散歩道とする。
出入口、虫候補地点、NPC生活地点、必須Event Triggerは散歩道上、または既存Interaction距離内へ配置する。

Save v1の`player.position`は維持する。Load時には旧自由移動Saveを含め、復元座標を現在Locationの最寄り散歩道へ投影する。

Keyboard移動は現在位置が属する線分と、その端点へ直接接続された線分だけを候補にする。
画面上で近接していても接続点を共有しない別経路へは移らない。接続点へ到達したframeでは一度端点へ正確に停止し、
次のPhysics frameの入力方向で出る経路を選ぶ。クリック移動も中間接続点を到達距離で読み飛ばさず、同じ規則に従う。

`WalkPathNetwork2D`は各線分上へ一定間隔の常時表示Markerも生成する。Markerは経路探索と同じ線分データから生成し、
表示用座標をSceneへ二重定義しない。描画は背景より手前、Player・NPC・前景より奥とし、入力判定を持たない。
Marker生成位置はWorld Collisionとの非重複テストと640x360実画面キャプチャの両方で監査する。

---

## 64. Marker-first Environment Art Contract

新規Locationの実装順は`WalkPathNetwork2D`、目的地点、Marker付きGreybox、背景画像、Collision / Occluder調整とする。
背景画像を先に確定してから散歩道を当てはめない。経路座標の正本はScene内の`Line2D`で、背景生成用の座標表はそのレビュー用スナップショットとする。

`walk_path_marker_smoke_test`は`LocationCatalog.SCENE_PATHS`からProduction Locationを列挙する。
このため今後LocationCatalogへエリアを追加する場合、同じ変更単位で常時表示Markerを持つ`WalkPathNetwork2D`を実装しなければValidationを通過しない。

背景制作と差し替えの詳細は`docs/MAP_ART_WORKFLOW.md`に従う。背景にはMarkerを焼き込まず、Scene実行時に経路データから描画する。

---

## 65. Marker-first Background Geometry Finalization — Issue #071

再制作した背景へGeometryを同期する際は、全8 Locationの`*_markers.png`と`*_geometry.png`を同じ640x360条件で出力する。
単純な通過エリアは四辺のWorld Collision、祖母宅・家周辺・川は背景オブジェクト足元のCollisionPolygonとForeground Occluderを重点監査する。

Markerの点だけでなくPlayer足元半径7pxがWorld Collisionへ重ならないことを自動検証する。
背景変更で撤去したオブジェクトのCollisionを残さず、移動したオブジェクトのCollisionは新しい足元へ合わせる。
Visual Regression基準の更新には`tools/capture_marker_first_baselines.ps1`を使用する。

---

## 66. Walkable Surface Alignment

散歩道は背景上の畳、板間、土道、橋、乾いた川岸だけを通る。水面、水田、密な植栽、木の根元、岩、柵、家具の足元へは線を置かない。

`paddy_road`、`irrigation_shade`、`river_entrance`、`engawa_yard`は外周Collisionだけでなく、水面・水田・木・岩・柵・家屋足元の`CollisionPolygon2D`を持つ。Markerテストは2px表示範囲とPlayer足元半径7pxの両方で、これらのCollisionと散歩道が重ならないことを検証する。

出入口、Spawn、虫候補、河童Event、祖母の生活地点は散歩道上へ置く。画面端の植生や水面へ到達するための仮経路は作らない。

---

## 67. Marker-first Visual Baselines After Walkable Surface Alignment — Issue #072

散歩道と屋外Collisionを歩行面へ合わせた後、Bake済みNavigationとVisual Regression基準を同じ変更単位で同期する。

`grandma_house`、`home_outdoor`、`river`は`tools/bake_2d_navigation.gd`で`WorldCollision`から再Bakeする。Player到達座標の正本は散歩道のままとし、Bake結果はGeometry Overlayと移行期間中のNavigation比較用である。

全8 Locationの`*_markers.png`と`*_geometry.png`は640x360で`docs/art-reference/03_gameplay/marker_first_geometry/`へ保存する。捕獲は描画可能なDisplay Driverが必要で、Linuxでは`tools/capture_marker_first_baselines.sh`、Windowsでは既存のPowerShell Scriptを使う。`walk_path_marker_smoke_test`は基準画像の存在と解像度も検証する。

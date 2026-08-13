# 夏休み妖怪日記 — TEST_PLAN

## 1. 方針

このゲームは「手触り」「空気感」「時間感覚」が重要なため、
自動テストだけでは品質を保証できない。

以下を併用する。

- Unit Test
- Integration Test
- Manual Playtest
- Visual Check
- Save Regression Test

---

## 2. Unit Test対象

### GameClock

- 時刻加算
- 日付跨ぎ
- 時間帯判定
- pause
- time_scale

### CalendarManager

- day_index
- 特別日判定
- 30日目

### Event conditions

- 日付
- 時間
- 天候
- Flag
- Yokai state
- Inventory

### Save

- serialize
- deserialize
- version
- missing optional values

### Schedule

- NPC location lookup
- Weather override
- Special day override

---

## 3. Integration Test

### Clock + Event

特定時刻でEvent候補が変化する。

### Weather + Event

雨の日のみ唐傘Eventが成立する。

### Yokai + Diary

河童目撃後にDayRecordへ記録される。

### Save + WorldState

解除したショートカットがLoad後も残る。

---

## 4. Manual Playtest — Vertical Slice

### 移動

- 8方向が自然
- 引っ掛かりが少ない
- Pixel jitterなし
- 移動速度が遅すぎない
- 当たり判定が見た目と一致

### カメラ

- Spriteがぼやけない
- 不自然なSubpixel移動がない
- マップ端で違和感が少ない

### 虫取り

- 虫を見つける楽しさ
- 網を振る感触
- 成功/失敗が理解できる
- UI説明が多すぎない

### 河童

- 事前に存在を匂わせている
- 発見が唐突でない
- 派手なスポーンに見えない
- 見た後に「もっと知りたい」と感じる

### 時間

- 急いでいる感じが強すぎない
- 夕方への変化が分かる
- 帰宅したくなる

### 日記

- その日を振り返りたくなる
- 文章量が多すぎない
- 河童と虫取りの記録が残る

---

## 5. Vertical Slice評価表

各10点。

```text
移動
夏らしさ
田舎の空気感
音
虫取り
探索
河童発見
夕方
祖母の家
日記
```

平均7点以上をMilestone 2移行基準とする。

---

## 6. Visual Regression

毎Milestoneでスクリーンショットを保存。

基準:

- Character pixel scale
- Tile scale
- UI scale
- 色味
- 昼/夕方/夜

Referenceとの差異を確認する。

---

## 7. Debug Menu test

以下が機能すること:

- Day変更
- Time変更
- Weather変更
- Teleport
- Event trigger
- Yokai stage
- Item付与
- Save/Load

---

## 8. Save Regression

Milestoneごとに前MilestoneのSaveを可能な範囲で読み込む。

破壊的変更時はMigrationを確認する。

---

## 9. Performance

初期ターゲット:
Windows 60 FPS。

2Dなので過剰最適化はしないが、以下を確認:

- 大量Animation
- Particle
- TileMap
- NPC数
- Light2D
- UI
- Audio

---

## 10. Input

Keyboard:
- WASD / Arrow
- Interact
- Run
- Tool
- Menu

Controller:
後期Milestoneで正式確認するが、
InputMapは初期からActionベースで設計する。

---

## 11. Accessibility

確認項目:

- テキスト速度
- フォントサイズ
- Camera shake
- Flashing
- Audio volume
- Key remap
- 色だけで情報を伝えていないか

---

## 12. Bug Severity

### Blocker
起動不能、Save破損、進行不能。

### Critical
メインイベント進行不能、重要データ消失。

### Major
主要システムの誤動作。

### Minor
演出、表示、小さな不整合。

---

## 13. Milestone 0 Validation

Windows / PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File tools/validate_project.ps1
```

検証対象:

- Godot editor headless import / script parse
- GameClockの時間帯境界、pause、time_scale、Debug時刻設定
- CalendarManagerの1〜30日境界とDebug日付設定
- Save v1 round trip
- Unknown field tolerance
- Version mismatch
- Corrupted JSON
- Missing required calendar data

手動確認ではプロジェクトを実行し、F3でDebugMenuを開いて
Day / Time / Save / Loadを操作する。表示のNearest維持とカメラの
Subpixel jitterがないことは、Production Sprite導入後にも再確認する。

---

## 14. Player Movement Validation — Issue #020

自動Validation:

- 8入力方向が対応するfacingへ変換される
- 入力停止時に最後のfacingを維持する
- 斜め歩行が軸方向と同じ速度になる
- run入力時にrun speedへ切り替わる
- movement lock時に停止する

手動確認:

1. WASDと矢印キーで8方向へ移動できる
2. 斜め移動だけ速くならない
3. Shiftを押している間だけ走行速度になる
4. F3でDebugMenuを開くとPlayerが停止する
5. Placeholder上の白線が最後に向いた8方向を示す

---

## 15. Interaction Validation — Issue #022

自動Validation:

- `Interactable`の有効・無効とprompt text
- interaction実行時のsignal
- 利用可能な最短距離候補の選択
- 同距離候補のpriority判定

手動確認:

1. Foundation Sceneで`TEST`マーカーへ近づく
2. マーカーの方向を向いた時だけInteraction promptが表示される
3. EまたはZでinteractionが1回実行される
4. マーカーから離れるとpromptが消える
5. F3表示中はinteractionが実行されない

`FoundationInteractionMarker`はシステム確認専用で、ゲーム本編の調査物ではない。

---

## 16. Dialogue Validation — Issue #023

自動Validation:

- Dialogue Resourceの必須ID・本文検証
- 通常行の送り
- 選択肢行での自動送り抑止
- 選択肢による指定行への分岐
- 最終行後の終了
- 会話開始・終了時のPlayer移動ロック
- 会話中のGameClock停止と従来pause状態の復元

手動確認:

1. Foundation Sceneの`TEST`マーカーをEまたはZで調べる
2. 話者名と本文が表示され、Playerが移動できない
3. EまたはZで次の行へ進む
4. 選択肢を方向キーで選び、EまたはZで決定する
5. 最終行後にUIが閉じ、Playerが再び移動できる

Foundation用会話はシステム確認データであり、本編Dialogueではない。

---

## 17. NPC / Grandma Validation — Issue #024

自動Validation:

- NPCDataの必須ID・表示名
- actor位置に応じたNPCの基本方向転換
- Grandma Sceneの安定IDと表示名
- NPCDataからDialogueがInteractionAreaへ設定される
- NPC表示名を使ったInteraction prompt

手動確認:

1. Foundation Scene左側の祖母Placeholderへ近づく
2. 「おばあちゃんと話す」が表示される
3. 会話開始時に祖母がPlayerの方向を向く
4. 祖母の3行の会話が最後まで進む

PlaceholderはProduction Assetではなく、祖母の歩行・生活Animationも未実装。

---

## 18. Day-period Visual Validation — Issue #028

自動Validation:

- morning / daytime / evening / nightのPalette lookup
- Visual ControllerによるCanvasModulate色の適用

手動確認:

1. F3のTime変更で05:00、10:00、16:30、19:00を順番に設定する
2. 朝・昼・夕・夜の色へ滑らかに変化する
3. HUDとDialogue UIはCanvasModulateの影響を受けず読める
4. 夜が探索不能な暗さにならない

---

## 19. Bug Entity Validation — Issue #030

自動Validation:

- InsectDataの必須ID・表示名
- Entityからの安定insect_id取得
- 移動方向の正規化
- 捕獲要求Signal
- 捕獲確定後の状態・非表示・再要求拒否

手動確認はIssue #031の捕獲範囲・道具入力と統合後に実施する。

---

## 20. Bug Catching Validation — Issue #031

自動Validation:

- 範囲内で最も近い未捕獲Insectの選択
- 捕獲成功後のInsect状態
- movement lock中の道具使用拒否

手動確認:

1. Foundation Scene上側の虫Placeholderへ近づいて向く
2. Xで虫取り網を使用する
3. 範囲内なら虫が消え、捕獲したIDがHUDへ表示される
4. 虫がいない方向でXを押すと空振り表示になる
5. Dialogue中とF3表示中は網を使用できない

---

## 21. Event / Kappa / Diary Validation — Issues #032〜#038

自動Validation:

- World flag設定・解除
- Yokai stage進行と逆行拒否
- Eventの日付・場所・時間帯・Flag・Yokai条件
- priority、exclusive group、one-shot
- Event actionとhistory
- 河童TRACE→SEENイベント連鎖
- DayRecordの重複排除とserialize round trip
- Diary表示用format
- World / Yokai / Event history / DayRecordのSave round trip

手動確認:

1. F3のCandidatesで河童イベントの不成立理由を確認する
2. Force Trace / Force Seenで波紋と短い河童Placeholderを確認する
3. Jで日記を開き、捕まえた虫や見つけた妖怪が記録される
4. Save後に状態を変え、Loadで日記・河童stage・event historyが復元される

---

## 22. Vertical Slice Playtest Tools — Issue #039

自動Validation:

- Presetによるday / time / area / Player transform設定
- World flag / Yokai stage / Event history設定
- 以前のruntime状態とDiaryの初期化
- 既知地点Teleport
- 状態Snapshot
- runtime reset

手動確認:

1. 640x360の基準解像度でF3を押し、全操作が画面内に表示されることを確認する
2. 3つのPresetを順に適用する
3. Candidatesで各Presetのイベント成立状態を確認する
4. home / insect / kappaへTeleportする
5. Snapshotで現在状態を確認する
6. Reset Runtime後も既存SaveをLoadできることを確認する
7. 時計を事前にpauseしてからDebugMenuを開閉し、pause状態が維持されることを確認する

---

## 23. Player Animation — Issue #021

自動Validation:

- idle / walk / runと8方向からAnimation名を生成できる
- Player Sceneに`PlayerAnimationController`が存在する
- Production frames未設定時はPlaceholder表示を維持する

手動確認:

1. 8方向へ歩き、向きの白線と足踏みが入力方向へ追従する
2. ShiftまたはControllerのrun入力中は足踏みテンポが速くなる
3. 停止すると最後の向きを保ったidle状態になる
4. 表示が整数座標・Nearest設定でぼやけないことを確認する

---

## 24. Environment Audio — Issue #029

自動Validation:

- Location Profileが時間帯別Streamを返す
- 未設定時間帯は無音を返す
- Areaと時間帯に応じてControllerが再生Streamを切り替える

手動確認（Production音源追加後）:

1. 家・屋外・川を移動し、Location固有の環境音へcrossfadeする
2. 朝・昼・夕・夜をDebugMenuで変更し、対応する環境音へ切り替わる
3. 未設定のLocation / 時間帯でエラーや不必要な生成音が鳴らない
4. 夕方のヒグラシと川音が会話・河童演出を邪魔しない音量か確認する

---

## 25. Grandma House / Home Outdoor Greybox — Issues #025–#026

自動Validation:

- 祖母の家・家周辺Sceneをロードできる
- 各Mapが安定したarea IDとTileMapLayer契約を持つ
- 祖母と虫取り対象がそれぞれのMapに配置されている
- Location内の入口IDを解決できる

手動確認:

1. 起動時に祖母の家の寝室へ配置される
2. 居間の祖母と会話できる
3. 縁側の出口から家周辺へ移動し、玄関前へ配置される
4. 家周辺の玄関から祖母の家へ戻り、縁側側へ配置される
5. 家周辺のセミを虫取り網で捕まえられる
6. Greybox外周と家屋をPlayerが通り抜けない
7. ReferenceをCropしたProduction Tileが混入していない
8. 家周辺のProduction背景が640x360で表示され、道路・玄関・川への導線とCollisionが一致する

---

## 26. River Greybox — Issue #027

自動Validation:

- River Sceneをロードでき、area IDが`river`である
- Ground / Water / Collision / Foregroundを別TileMapLayerとして持つ
- 水域Collisionと河童Presenterが存在する

手動確認:

1. 家周辺の東端から川へ移動し、岸の帰路側へ配置される
2. 岸沿いを歩けるが、水面へ侵入できない
3. Day 1の気配Preset / Eventで波紋が表示される
4. Day 1の目撃Preset / Eventで河童が一瞬だけ見え、夕方になる
5. 帰路から家周辺東端へ戻れる
6. ReferenceをCropしたProduction Tileが混入していない
7. 川のProduction背景が640x360で表示され、水域境界・岸道・帰路がCollisionと一致する
8. 河童イベント前は波紋がなく、TRACE / SEEN時だけ4 frameの波紋が表示される

回帰テスト:

- `tests/map_transition_smoke_test.tscn`でScene交換後も入力元Nodeへアクセスせず、
  指定した入口へPlayerが配置されることを確認する。

---

## 27. Return-home Flow — Issue #035

自動Validation:

- evening / nightだけを帰宅時間として判定する
- 夕食Dialogue Resourceが有効である
- `tests/return_home_flow_smoke_test.tscn`で夕食後の日記Reviewから翌朝まで進行する
- 通常の日記閲覧では日付が進まない

手動確認:

1. DebugMenuで夕方へ変更し、祖母の家へ戻る
2. 祖母の会話が夕食内容へ変わる
3. 会話終了後に当日の日記が自動表示される
4. 河童・虫・訪問場所など当日の事実が表示される
5. 日記を閉じると翌日07:00になり、寝室へ戻る
6. DebugMenuのLoadでAutosaveから翌朝の状態を読み込める
7. Day 30では日付が進まず、同じ夜に夕食フローが再実行されない

---

## 28. Vertical Slice Polish — Issue #040

自動回帰:

- `LocationCatalog`がVertical Sliceの3 Locationを解決する
- 未知のSave `scene_id`を拒否する
- `tests/save_location_restore_smoke_test.tscn`で家のSaveを川からLoadし、
  家Scene・保存位置・向きを復元する
- DebugMenu Load時はメニューを閉じ、pause状態を残さない

手動確認:

1. 祖母の家・家周辺・川でそれぞれSaveする
2. 別Mapへ移動してからLoadし、保存Map・位置・向きへ戻る
3. F3メニューが閉じ、Player操作と時計進行が復帰する

一括実行:

```powershell
powershell -ExecutionPolicy Bypass -File tools/run_vertical_slice_validation.ps1
```

Foundation、Map遷移、帰宅フロー、一日通し、別Location Save復元の5 Sceneを順に実行する。

---

## 29. Vertical Slice One-day Flow — Issue #041

自動E2E:

- Day 1 07:00に祖母の家の寝室から開始する
- 祖母との朝会話、外出、セミ捕獲を順に実行する
- 川の2つの接近TriggerでTRACEからSEENへ進み、夕方へ変化する
- 帰宅後の夕食、日記Reviewまで進行する
- 日記に祖母、虫、3 Location、河童、2 Eventが記録される
- 日記を閉じてもDay 2へ進まず、完了Panel、入力停止、時計停止になる

一括Validationは上記E2Eを含む5 Sceneを順に実行する。

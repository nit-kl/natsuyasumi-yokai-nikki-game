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
9. 祖母の家のProduction室内が640x360で表示され、寝室・居間・台所・縁側の導線がCollisionと一致する
10. 祖母が会話開始時に4方向Production SpriteでPlayerの方を向く

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
9. SEEN時だけ河童の4 frame surface animationが一度再生され、約1.2秒で水面から消える
10. 河童が派手にSpawnせず、皿だけの状態から静かに浮上してすぐ潜る

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
- Smokeは`end_vertical_slice_after_review = true`でDay 2へ進めず、完了Panel、入力停止、時計停止になる
- 本編の祖母の家は同exportをfalseにし、日記クローズで翌朝へ進む

一括Validationは上記E2Eを含む5 Sceneを順に実行する。

---

## 30. Bug-catching Production Presentation — Issue #047

自動Validation:

- 虫Entityが24x24pxのアブラゼミProduction Spriteを使用する
- Player Sceneが32x48pxの虫網Production Spriteと`BugCatchPresenter`を持つ
- 虫網の基準角度がPlayerの向きへ追従する
- 空振り時にも虫網アニメーションが開始される
- 既存の捕獲判定、movement lock、日記記録を壊さない

手動確認:

1. 家周辺のセミへ近づき、上下左右と斜め方向からXを押す
2. 虫網が向いている方向へ振られ、上向きではPlayerの背面へ回ることを確認する
3. 範囲内ではセミが捕まり、小さな黄色の成功演出が表示される
4. 虫がいない場所では短い風切り線が表示され、成功と区別できる
5. 連打しても網が不自然に点滅せず、Dialogue中とF3表示中は使用できない
6. 捕獲後の日記に`aburazemi`が一度だけ記録される

---

## 31. Vertical Slice Production Audio — Issue #048

自動Validation:

- 祖母の家、家周辺昼、家周辺夕方、川のProfileがProduction Streamを返す
- 未制作の家周辺morningは無音を返す
- Ogg環境音がLoop再生へ設定される
- 河童Sceneが波紋音と気配音の`AudioStreamPlayer2D`を持つ
- 既存のArea / 時間帯crossfadeを壊さない

手動確認:

1. 祖母の家でRoom Toneが小さく聞こえ、会話を邪魔しないことを確認する
2. 家周辺を昼へ変更するとアブラゼミ、夕方へ変更するとヒグラシへcrossfadeする
3. 家周辺の朝・夜は、未制作音源を代替音で埋めず無音になる
4. 川へ移動すると流水音へcrossfadeし、不自然なLoop境界が目立たない
5. 河童TRACEで波紋音、SEENで波紋音と控えめな気配音が水面位置から聞こえる
6. 河童SEEN後に夕方へ変わっても、環境音と気配音が会話や帰宅判断を妨げない

---

## 32. Diary Daily-page Production UI — Issue #049

自動Validation:

- 日記Sceneが512x320のProductionノート紙面を使用する
- 河童・アブラゼミの記録印が独立したProduction Textureを持つ
- 安定IDを日本語の表示名へ変換し、未知IDは消さずfallback表示する
- DayRecord / Save v1の形式を変更しない

手動確認:

1. 640x360でJを押し、開いたノートが画面内に収まり背景から読み分けられることを確認する
2. 未記録状態では河童・虫の印が表示されず、記録後だけ対応する印が現れることを確認する
3. 一日通しで祖母、3 Location、アブラゼミ、河童の記録が日本語で読めることを確認する
4. 夕食後に自動表示された日記を閉じ、既存どおり一日終了へ進むことを確認する
5. JとEscのどちらでも閉じられ、移動と時計のpause状態が正しく復元されることを確認する
6. 紙面・文字・記録印がNearest表示でぼやけず、河童と虫を色だけでなく文字でも識別できることを確認する

---

## 33. Diary Cover / Page Transition — Issue #050

自動Validation:

- 日記Sceneが224x280のProduction表紙Textureを持つ
- 通常閲覧は表紙から始まり、夕食後Reviewは日別ページを直接表示する
- 表紙閲覧とページ遷移がDayRecord / Save v1を変更しない
- 既存のReview終了・翌朝進行契約を維持する

手動確認:

1. 通常時にJを押し、深緑の表紙と動的な日本語タイトルが表示されることを確認する
2. EまたはZで表紙が短く閉じるように消え、日別ページが約0.22秒で表示されることを確認する
3. 遷移中にE/Zを連打しても点滅や二重遷移が起きないことを確認する
4. 表紙と日別ページのどちらでもJまたはEscで閉じられ、Playerと時計が復帰することを確認する
5. 夕食会話後は表紙を挟まず当日の日別ページが開き、閉じると既存どおり一日終了へ進むことを確認する
6. 表紙・紙面ともNearest表示を維持し、遷移終了時に非整数Scaleが残らないことを確認する

---

## 34. Minimal Production HUD — Issue #051

自動Validation:

- HUD Sceneが208x72の状態枠、128x44の道具枠、300x48のPrompt枠を使用する
- 時間帯・天気・既知の虫IDを日本語表示し、未知IDは消さずfallback表示する
- Bootstrapと各Locationが同じ`gameplay_hud.tscn`を使用する
- Foundation用の常設操作一覧をProduction HUDへ残さない

手動確認:

1. 640x360で左上の日数・時刻・時間帯・晴れ表示が世界を大きく隠さないことを確認する
2. F3で05:00、10:00、16:30、19:00へ変更し、朝・昼・夕方・夜の文字が更新されることを確認する
3. 右上に「虫をクリック / X」と表示され、色だけに依存せず操作と道具用途を読めることを確認する
4. NPCや出口へ近づいた時だけ画面下へ「左クリック / E / Z」Promptが表示され、離れると消えることを確認する
5. 虫捕獲・空振り通知が1.6秒後に消え、近くにInteraction候補があれば元のPromptへ戻ることを確認する
6. Dialogue、日記、DebugMenuの主要テキストをHUDが妨げず、各TextureがNearest表示されることを確認する

---

## 35. Action / UI Production SFX — Issue #052

自動Validation:

- Player Sceneが虫網swingと捕獲successのAudioStreamPlayer2Dを持つ
- 網使用時にswing cueが再生される
- Diary Sceneがpage-turn AudioStreamPlayerを持つ
- 3音源が1秒未満で、既存の捕獲判定・日記Review契約を壊さない

手動確認:

1. 虫がいない場所でXを押し、網の振りと同期して短い風切り音だけが聞こえることを確認する
2. アブラゼミを捕まえ、風切り音の後に成功演出と控えめな二音が聞こえることを確認する
3. 連打しても音が不自然に重なり続けず、環境音や虫の声を覆わないことを確認する
4. 通常の日記でE/Zを押し、表紙の遷移開始と同時に短い紙音が鳴ることを確認する
5. 夕食後Reviewは日別ページを直接開き、ページ音が鳴らないことを確認する
6. Dialogue・Diary・DebugMenuで時計が停止しても、開始済みの短い効果音が不自然に途切れないことを確認する

---

## 36. Dialogue Production UI — Issue #053

自動Validation:

- Dialogue Sceneが560x132のProduction会話枠Textureを持つ
- 選択肢Buttonが240x42のProduction Texture Styleを使用する
- 既存の通常送り・選択肢分岐・終了処理を維持する
- 会話中のPlayer移動lockとGameClock pause復元を維持する

手動確認:

1. 祖母との朝会話を開始し、話者名・本文・送り表示が紙面内へ収まることを確認する
2. 640x360で会話枠がNPCと周囲の景色を必要以上に隠さないことを確認する
3. Foundation確認会話で上下キーを使い、選択中の枠と文字が色以外の明度差でも識別できることを確認する
4. E/Zとマウスの両方で選択肢を決定でき、正しい行へ分岐することを確認する
5. 長い祖母の夕食台詞が枠外へはみ出さず、日記Reviewへ既存どおり進むことを確認する
6. HUD・Dialogue・Diaryの紙面解像感が揃い、全TextureがNearest表示されることを確認する

---

## 37. Production Day-period Palette — Issue #054

自動Validation:

- 共通Palette Resourceが確定した朝・昼・夕・夜のProduction色を返す
- 未知の時間帯はdaytimeへfallbackする
- 同色への再適用で不要なTweenを生成しない
- 遷移中の即時変更が既存Tweenを破棄し、指定色を正しく適用する
- nightのRGB下限を検証し、探索不能な暗さへの退行を防ぐ

手動確認:

1. 家周辺でF3から05:00、10:00、16:30、19:00を順番に適用する
2. 朝は薄金、昼は元絵に近い暖色、夕方は橙、夜は青灰として読み分けられることを確認する
3. 夕方でも紫陽花・水路・虫・Playerの色と輪郭が潰れないことを確認する
4. 夜でも道路、水際、家の入口、Playerの進行方向を識別できることを確認する
5. 家周辺・川・祖母の家で同じ時間帯の空気感が揃い、室内が不自然に着色されすぎないことを確認する
6. 時刻を連続変更しても色が瞬間的に跳ねず、HUD・Dialogue・Diaryの色は変化しないことを確認する

---

## 38. UI Confirm / Cancel Production SFX — Issue #055

自動Validation:

- Dialogue Sceneが0.5秒未満の非Loop決定音を持つ
- 通常送りと有効な選択肢決定で決定音が再生される
- Diary Sceneが0.5秒未満の非Loopキャンセル音を持つ
- Diary Sceneが閉じる操作用のキャンセル音を持つ
- 既存の会話分岐、時計pause復元、日記ページ音を維持する

手動確認:

1. 祖母との会話をE / Zで送り、各入力に短い上昇音が1回だけ鳴ることを確認する
2. 選択肢のある確認会話をキーボードとマウスで決定し、どちらも同じ決定音になることを確認する
3. 選択肢表示中に送り操作をしても、無効操作の決定音が余分に鳴らないことを確認する
4. 日記をJで開いてJで閉じ、閉じる時だけ短い下降音が鳴ることを確認する
5. 日記を開いてEscで閉じ、Jで閉じた時と同じキャンセル音になることを確認する
6. ページめくり時は紙音だけが鳴り、決定音やキャンセル音が重ならないことを確認する
7. 環境音・祖母の会話・河童の気配音を覆わず、連続操作でも耳障りな音量にならないことを確認する

---

## 39. Vertical Slice Final Playtest / Production Audit — Issue #056

自動Validation:

- 640x360、integer scale、Nearest既定値を維持する
- Vertical Slice必須Textureが存在し、確定したpixel canvas sizeと一致する
- 必須の環境音・操作音・UI音がすべて存在する
- Production Scene / SpriteFramesがReference Sheet、`_source`、`_candidate`画像を参照しない
- 3 MapがProduction背景を持ち、Greybox表示を無効化している
- 既存の一日通しを含む15 Scene一括Validationが成功する

手動確認:

1. Day 1朝の寝室から開始し、祖母との会話、外出、アブラゼミ捕獲、川への移動を通常入力だけで進める
2. 河童の波紋と一瞬の目撃が自然に連続し、派手なSpawn演出や戦闘UIがないことを確認する
3. 夕方の家周辺へ戻り、祖母との夕食会話、日記Review、一日終了Panelまで進める
4. 各MapでGreybox文字・Reference Sheet・制作元画像・候補画像が画面へ出ないことを確認する
5. Player、祖母、河童、アブラゼミ、虫網、VFX、HUD、Dialogue、DiaryがNearest表示されることを確認する
6. 朝・昼・夕方の環境音、虫取り、河童、ページ、決定／キャンセル音の音量差と意味が自然か確認する
7. 日記に祖母、3 Location、アブラゼミ、河童の気配・目撃が記録され、終了後もDay 1のまま停止することを確認する

判定:

- 自動Validation対象のProduction必須項目は完了
- bridge、guard rail、bicycle、insect cage、kabutomushi、tonboは現Vertical Slice経路で未使用のため後続候補として保持
- 聴感、歩行経路の気持ちよさ、640x360実画面での重なりは人手プレイテストで最終判定する

---

## 40. Mouse Click Movement Foundation — Issue #057

自動Validation:

- Player Sceneが`NavigationAgent2D`、`ClickMoveController`、目的地点Markerを持つ
- 3 Production Mapが`NavigationRegion2D`を持つ
- 家周辺で用水路を挟んだ地点を指定すると、Collisionへ押し続けず通路を経由して到達する
- 右クリック相当のCancelで移動とMarkerを停止する
- movement lock中は新しいクリック目的地を拒否する
- 既存のKeyboard移動、一日通し、Map遷移、Save復元を含む15 Scene一括Validationが成功する

手動確認:

1. 祖母の家、家周辺、川で地面を左クリックし、Marker位置まで8方向Animationで歩くことを確認する
2. 家、用水路、水面など歩けない場所をクリックし、最寄りの歩行可能地点で停止することを確認する
3. 用水路の反対側をクリックし、壁へ押し続けず中央の通路を経由することを確認する
4. 移動中に別の地面を左クリックし、新しい目的地へ自然に経路を変更することを確認する
5. 移動中に右クリックし、その場で停止してMarkerが消えることを確認する
6. 移動中にWASDまたは方向キーを入力し、クリック移動が解除されて直接操作へ切り替わることを確認する
7. 会話、日記、DebugMenu、一日終了Panelの表示中に背景をクリックしても移動予約されないことを確認する
8. Markerが小さく控えめで、河童の気配や探索対象を指示するQuest markerに見えないことを確認する

---

## 41. Mouse Click Approach / Action Queue — Issue #058

自動Validation:

- Player Sceneが`ClickActionController`を持つ
- 祖母の表示位置クリックがNPC本体ではなく既存Interaction Areaへ解決される
- 祖母をクリックすると接近後に既存Dialogueを開始する
- 家の出口をクリックすると接近後に既存Map遷移を実行する
- アブラゼミをクリックすると用水路を迂回して接近し、既存`BugCatcher`で捕獲する
- マウス経由の捕獲でもDayRecordへ`aburazemi`が記録される
- 既存のKeyboard操作、一日通し、Production監査、Save復元を含む15 Scene一括Validationが成功する

手動確認:

1. 離れた祖母を左クリックし、近づいて祖母の方を向いてから会話が始まることを確認する
2. 出入口を左クリックし、遠距離から瞬時に遷移せず入口まで歩いてからMapが切り替わることを確認する
3. 家周辺のアブラゼミを左クリックし、通路を経由して近づき、虫の方向へ網を振ることを確認する
4. 捕獲時に既存の網Animation、swing音、成功演出、成功音、HUD通知、日記記録が一度だけ発生することを確認する
5. 対象へ接近中に右クリックし、その場で停止して予約行動が実行されないことを確認する
6. 対象へ接近中に別対象または地面を左クリックし、古い予約が残らないことを確認する
7. 会話・日記・DebugMenu表示中のクリックが背景の移動や別Interactionへ漏れないことを確認する
8. 河童の波紋やEvent Triggerにクリック誘導が追加されず、歩いて気付く演出を維持していることを確認する

---

## 42. Mouse-first Dialogue / Diary UI — Issue #059

自動Validation:

- HUDの日記Buttonで表紙が開き、Playerの移動がlockされる
- 表紙のページButtonで既存のページTweenと紙音が始まり、日別ページへ遷移する
- 日記の閉じるButtonで既存のキャンセル音が鳴り、Playerの移動lockが解除される
- 会話枠の左クリックで1行ずつ進み、既存の決定音が鳴る
- 選択肢Buttonのクリックが既存の分岐先へ進む
- UIクリックが背景のクリック移動・Interactionへ漏れない
- 既存の一日通し、Production監査、Save復元を含む15 Scene一括Validationが成功する

手動確認:

1. HUDの「日記」を左クリックし、表紙が開いてPlayerが動かなくなることを確認する
2. 表紙の「ページをめくる」を左クリックし、紙音と短いページAnimationの後に日別ページが表示されることを確認する
3. 右上の「閉じる」を左クリックし、キャンセル音が鳴って通常移動へ戻ることを確認する
4. 祖母を左クリックして近づき、会話枠を左クリックするたびに1行ずつ進むことを確認する
5. 選択肢がある会話では選択肢Buttonだけで分岐し、会話枠の空き部分を押しても勝手に進まないことを確認する
6. 会話・日記のButtonや枠をクリックしても、背後へ移動したり別の対象を予約したりしないことを確認する
7. 夕方の帰宅後に自動表示される日記を「閉じる」で終了し、従来どおり一日終了Panelへ進むことを確認する
8. マウスのみで起床後の祖母との会話、外出、移動、虫取り、帰宅、日記終了まで進められることを確認する

---

## 43. Subtle Click-target Hover Feedback — Issue #060

自動Validation:

- Player Sceneが`ClickTargetHoverController`を持つ
- 祖母へのHoverが既存Interaction Areaへ解決され、NPC用の縦長枠を表示する
- 出入口へのHoverが横長の足元枠を表示する
- 未捕獲のアブラゼミへのHoverが小型枠を表示する
- 地面上、movement lock中、捕獲済みの虫ではHover枠が消える
- Hover表示中だけ指カーソルを要求し、非表示時は標準カーソルへ戻す
- 既存のクリック行動、一日通し、Production監査、Save復元を含む15 Scene一括Validationが成功する

手動確認:

1. 祖母へカーソルを重ね、指カーソルと全身を囲む小さな四隅だけが表示されることを確認する
2. 祖母からカーソルを外し、枠がすぐ消えて標準カーソルへ戻ることを確認する
3. 家の出口とMap間の出入口へカーソルを重ね、足元に横長の枠が表示されることを確認する
4. アブラゼミへカーソルを重ね、虫を隠さない小型枠が表示されることを確認する
5. アブラゼミ捕獲後は同じ場所へカーソルを重ねても枠が再表示されないことを確認する
6. 会話、日記、DebugMenu、一日終了Panelの表示中は背後の対象にHover枠が出ないことを確認する
7. 河童の波紋、河童の一瞬の目撃、地面、背景小物にはHover枠が出ないことを確認する
8. 枠が常設Markerや目的地案内に見えず、夏の景色や対象Spriteの視認性を妨げないことを確認する

---

## 44. Grandma House Production Gameplay Geometry — Issue #061

自動Validation:

- 祖母宅が`GreyboxWalls`ではなく`WorldCollision`を使用する
- 外部Navigation Resourceが家具を避けた複数PolygonとしてBake済みである
- 寝室Spawnがベッド上ではなく畳のベッド脇にあり、Collisionと重ならない
- 祖母が丸机左側の通路に立ち、Collisionと重ならない
- ベッドと丸机の中心がPhysics Collision内かつNavigation外である
- 寝室から玄関までNavigation Pathが接続されている
- 実際のクリック移動で家具へ引っ掛からず玄関通路へ到達する
- 翌朝の寝室復帰、祖母クリック、出口クリック、帰宅Flowを含む15 Scene一括Validationが成功する

手動確認:

1. Day 1朝を寝室から開始し、Playerがベッド上ではなくベッド右側の畳に立つことを確認する
2. ベッド、箪笥、本棚、テレビ台へKeyboardと地面クリックの両方で進入できないことを確認する
3. 祖母を左クリックし、丸机を横切らず通路を回って接近して会話することを確認する
4. 丸机、座布団、中央棚、観葉植物を突き抜けないことを確認する
5. 台所設備と食卓へ進入せず、見えている床部分では不自然に遠くで止まらないことを確認する
6. 中央の開口部から縁側へ出て、画面下の庭や植木へ入り込まないことを確認する
7. 玄関を左クリックし、中央の通路と縁側を経由して外へ出られることを確認する
8. 夕方の帰宅後も祖母との会話、日記Review、翌朝の寝室復帰が従来どおり進むことを確認する

---

## 45. Home Outdoor Production Gameplay Geometry — Issue #062

自動Validation:

- 家周辺が`GreyboxCollision`ではなく`WorldCollision`を使用する
- 外部Navigation Resourceが用水路・水田・畑を避けた複数PolygonとしてBake済みである
- 家前Spawn、上側土道、中央橋、下側庭道、アブラゼミ位置がPhysics Collisionと重ならない
- 家の基礎、用水路、水田、トウモロコシ畑、庭の植栽区画がPhysics Collision内である
- 上側土道からアブラゼミ位置までのNavigation Pathが中央橋を通る
- 川方面の右端DoorwayがNavigationから接近可能である
- 実際のクリック移動と虫クリックで中央橋を経由し、庭道へ到達して捕獲できる
- Map遷移、一日通し、Save復元を含む15 Scene一括Validationが成功する

手動確認:

1. 祖母宅から外へ出て、Playerが屋根や縁側上ではなく石段前の土道へ配置されることを確認する
2. 家の壁、石垣、石灯籠、郵便受け、樽をKeyboardと地面クリックの両方で突き抜けないことを確認する
3. 用水路の水面・石積みを直接クリックしても進入せず、最寄りの道側で停止することを確認する
4. 上側土道から下側庭道をクリックし、背景中央の細い橋だけを通って移動することを確認する
5. 水田とトウモロコシ畑の内部へ入れず、作物の手前で自然に停止することを確認する
6. アブラゼミへカーソルを重ねて左クリックし、橋を経由して右側庭道で捕獲することを確認する
7. 右端を左クリックし、上側土道を通って川へのDoorwayまで到達できることを確認する
8. 夕方に川から戻った時も右側道路へ正しく配置され、祖母宅まで帰れることを確認する

---

## 46. River Production Gameplay Geometry — Issue #063

自動Validation:

- 川が`GreyboxCollision`ではなく`WorldCollision`を使用する
- Navigation Resourceが岸、水面、低木、岩、画面下部の植生を避けた複数PolygonとしてBake済みである
- 左入口Spawn、河童の気配地点、河童目撃地点、Debug用河岸がPhysics Collisionと重ならない
- 水面中央、岸際、左側低木、右岸の岩、画面下部の植生がPhysics Collision内である
- 水面中央のクリック先が岸から十分離れたNavigation上へ補正される
- 左入口から河童目撃地点までNavigation Pathが接続される
- 実際のクリック移動で中央の土手道を通り、河童目撃地点まで到達する
- 帰宅Doorwayが左側の見えている土手道から到達可能である
- Event Trigger進入時にPhysics監視状態変更エラーが発生しない
- Map遷移、一日通し、Production監査、Save復元を含む15 Scene一括Validationが成功する

手動確認:

1. 家周辺から川へ入り、Playerが左側の低木ではなく見えている土手道へ配置されることを確認する
2. 水面を左クリックし、岸際で止まって水中へ入らないことを確認する。Keyboard移動でも同様に確認する
3. 岸の凹凸に沿って停止位置が変わり、背景の草・石と移動境界が大きくずれないことを確認する
4. 中央の土手道を歩き、河童の気配地点と一瞬目撃地点へ自然に到達できることを確認する
5. 画面下部の柵・植生、左側低木、右岸の岩を突き抜けないことを確認する
6. 左側の帰宅地点をクリックまたは接近操作し、家周辺へ戻れることを確認する
7. 河童Eventが各一度だけ進行し、進入時にDebuggerへPhysics監視状態変更エラーが出ないことを確認する
8. 河童は水面に自然に現れ、Hover枠や派手なSpawn Effectが追加されていないことを確認する

---

## 47. Three-map Gameplay Geometry Visual Tuning — Issue #064

自動Validation:

- 祖母宅の扇風機台座と食卓前椅子がPhysics Collision内である
- 祖母宅の寝室から玄関までNavigation Pathが引き続き接続される
- 家周辺の中央橋下にある紫陽花・植栽帯がPhysics Collision内である
- 家周辺の橋、下側細道、アブラゼミ位置が同一Navigation領域で接続される
- 川の画面下部にある柵際がPhysics Collision内である
- 川の入口から河童の気配・目撃地点までのNavigation Pathが接続される
- 補正後のNavigation Resourceを使用して全15 Scene一括Validationが成功する
- `tools/capture_2d_geometry.gd`がheadless実行を明示的に拒否し、描画不能状態で停止し続けない

手動確認:

1. 3マップのGeometry Overlayを原寸出力し、赤いCollisionが背景上の家具・植栽・柵の足元に重なることを確認する
2. 祖母宅で扇風機の台座と食卓前椅子を突き抜けず、寝室から玄関までクリック移動できることを確認する
3. 祖母宅の障子前へ上下から接近し、障子の絵へ足元が入り込まないことを確認する
4. 家周辺で中央橋を渡り、橋下の紫陽花帯へ入らず左右の細道へ曲がれることを確認する
5. 家周辺でアブラゼミを左クリックし、植栽を横切らず右側経路から接近できることを確認する
6. 川の土手道を左右へ歩き、下側の柵・草へ足元が入り込みすぎないことを確認する
7. 川の水際、河童Event地点、帰宅Doorwayが補正前と同様に到達可能であることを確認する
8. Collision境界が背景のPixel輪郭を過剰に追わず、Playerが細道で引っ掛からないことを確認する

---

## 48. Production Foreground Occlusion — Issue #065

自動Validation:

- 3マップが`ForegroundOccluders`を持ち、対象Nodeが`ForegroundOccluder2D`である
- 各OccluderがMapのProduction背景と同一Textureを参照する
- 各OccluderのPolygon座標とUV座標が一致し、Texture FilterがNearestである
- Occluderが`occlusion_y`に対応する固定Depthを持つ
- PlayerとNPCがCollision下端のWorld YをそれぞれのDepthへ反映する
- Playerが机の奥、祖母が机の手前に同時にいても、机が両者の間へ描画される
- 前景境界判定がPlayer Node原点ではなく`CollisionShape2D`下端を使用し、手前へ出た後の約12pxの被さり残りがない
- 祖母宅、家周辺、川のScene遷移を挟んでも前後切替が機能する
- Foreground遮蔽テストを含む全15 Scene一括Validationが成功する

手動確認:

1. 祖母宅で丸机の上側を歩き、Playerの下半身が机の手前部分へ自然に隠れることを確認する
2. 丸机の下側へ回り込み、Playerが机より手前へ表示されることを確認する
3. 扇風機、中央植木、食卓の上下を移動し、足元位置に応じて前後関係が切り替わることを確認する
4. 室内側では障子がPlayerより手前、縁側側ではPlayerが障子より手前になることを確認する
5. 家周辺の水田右端、中央植栽、トウモロコシ畑左端を歩き、草際でPlayerの一部が自然に隠れることを確認する
6. 川の左側低木と下側の柵際を歩き、草・柵がPlayerの手前へ表示されることを確認する
7. 朝・昼・夕方で背景と前景切り抜きの色や明るさに境界が出ないことを確認する
8. Foreground切替がクリック移動、Hover、河童Event、虫取りを妨げないことを確認する
9. 各前景境界をゆっくり上下に通過し、主人公の足元が境界を越えた直後にオブジェクトの被さりが解除されることを確認する

---

## 49. Grandma Indoor Living Routine — Issue #066

自動Validation:

- 祖母が`NavigationAgent2D`とPlayer Bodyを避けるCollision Maskを持つ
- 祖母の屋内用足元Collisionが狭い居間通路を安全に通れる5px半径である
- ちゃぶ台左と南側の生活地点が同じNavigation領域で完全に接続される
- ちゃぶ台からキッチン入口までNavigationが完全に接続される
- 祖母が家具を横切らず生活地点へ到達する
- 移動中は向きに対応した`walk_*`、停止中は`idle_*` Animationを使用する
- Playerが接近または祖母をクリック予約した時に停止する
- 会話中はClock Pauseに従って位置を維持し、会話終了後に再開できる
- 夕方はちゃぶ台左へ戻って停止し、既存の夕食会話を妨げない
- 翌朝へ切り替わった場合は生活移動を再開できる
- 祖母生活移動テストを含む全15 Scene一括Validationが成功する

手動確認:

1. Day 1朝に祖母宅で数秒待ち、祖母がちゃぶ台左から南側・右側・キッチン入口へゆっくり歩くことを確認する
2. 祖母がちゃぶ台、テレビ台、扇風機、障子を横切らないことを確認する
3. 祖母の歩行方向に応じて4方向の歩行Animationが切り替わることを確認する
4. 移動中の祖母へカーソルを合わせて左クリックし、祖母が止まり、Playerが追従して会話できることを確認する
5. 祖母へ徒歩で近づいた時も目の前を横切り続けず、自然に立ち止まることを確認する
6. 会話中、日記表示中、Pause中に祖母が動かないことを確認する
7. 祖母から離れて会話を終えると、しばらく待った後に生活移動へ戻ることを確認する
8. 夕方に帰宅し、祖母がちゃぶ台左で停止して夕食会話・日記Reviewへ従来どおり進めることを確認する
9. 祖母が玄関、寝室Spawn、中央開口を長時間塞がないことを確認する

---

## 50. Grandma House Table Depth / Kitchen Passage Correction — Issue #067

自動Validation:

- 丸机の固定Depthが、奥側のPlayerと手前側の祖母の間に入る
- Playerと祖母が互いの位置に影響されず、各自の足元で前景との描画順を決める
- 中央植木前の見えている通路がPhysics Collisionで塞がれていない
- ちゃぶ台左からキッチン入口までNavigation Pathが完全に接続される
- 祖母が同じNavigationを使ってキッチン入口へ実際に到達する
- 夕方は従来どおりちゃぶ台左へ戻り、翌朝に巡回を再開する
- 修正後のNavigation Resourceを含む全15 Scene一括Validationが成功する

手動確認:

1. Playerを丸机の上側、祖母を下側へ置き、机が二人の間に表示されて祖母が消えないことを確認する
2. Playerと祖母の前後を入れ替え、今度はPlayerが机の手前へ正しく表示されることを確認する
3. 丸机の南側を左右へ歩き、座布団付近でCharacter全体が不自然に消えないことを確認する
4. 居間右側の植木の下をクリックし、見えている隙間を通ってキッチン入口へ到達できることを確認する
5. 同じ通路でKeyboard移動も引っ掛からず、植木の根元・障子・食卓は突き抜けないことを確認する
6. 数秒待ち、祖母が机の右側からキッチン入口へ歩いて到達し、しばらく滞在することを確認する
7. Playerと祖母が通路で接近した時は互いを突き抜けず、祖母が一時停止することを確認する
8. キッチンの調理台・食卓内部など、背景上に歩行床がない場所へは入れないことを確認する

---

## 51. Area-based Insect Spawning — Issue #068

自動Validation:

- 家周辺と川が有効な`InsectSpawnProfile`と3つ以上の生息候補地点を持つ
- Day 1の家周辺ではアブラゼミが最低1匹生成される
- 生成位置がScene内の生息候補地点のいずれかに一致し、Physics Collision外にある
- 同じ日付・Areaでは同じSeedを使い、Scene再入場で配置が変化しない
- 当日の日記へ`aburazemi`が記録済みの場合、再入場しても同種が復活しない
- 既存の捕獲判定、クリック接近、日記記録、一日通しFlowを維持する
- Save v1 Schemaを変更しない

手動確認:

1. Day 1朝に家周辺へ出て、アブラゼミがSpawnPoint上に自然に存在することを確認する
2. アブラゼミが画面内へ突然現れる演出や派手な通知を伴わないことを確認する
3. アブラゼミを捕まえ、家へ入って再び外へ出ても同日に復活しないことを確認する
4. 捕獲前に家周辺へ入り直した場合は同じ位置・同じ匹数になることを確認する
5. 川では日付・Area固有の0〜1匹となり、河童の気配・目撃演出を妨げないことを確認する
6. 日付をDebugMenuで変更すると、その日用の配置が選ばれることを確認する

---

## 52. Vertical Slice Area Subdivision — Issue #069

自動Validation:

- Main Sceneが`bedroom.tscn`で、Day 1 07:00に寝室から開始する
- 新規5 Sceneが安定`area_id`、640x360 Production背景、Nearest Filter、Navigation、Physics境界を持つ
- 各Doorwayの遷移先Sceneと入口IDが双方向に接続される
- LocationCatalogが既存3 IDと新規5 IDを解決し、Save v1を維持する
- 一日通しで7 Locationを訪問し、祖母、アブラゼミ、河童、日記終了まで進行する
- Area subdivision testを含む全16 Scene一括Validationが成功する

手動確認:

1. 寝室から居間へ移動し、部屋移動が短く自然であることを確認する
2. 祖母との朝会話後、縁側・庭、田んぼ道、用水路木陰、川入口を順番に歩く
3. 各画面の出口と次画面の入口の方角・地形が空間的に連続して見えることを確認する
4. 各屋外エリアの虫が画面内へ突然Spawnせず、背景の木・草・水辺に自然に存在することを確認する
5. 河童目撃後、夕方の同じ道を逆向きに帰り、色と環境音の変化を確認する
6. 帰宅後の夕食、日記Review、一日終了Panelが従来どおり進むことを確認する

---

## 53. Grandma House Living-room Production Integration — Issue #070

自動Validation:

- `grandma_house`が寝室なしの居間・台所Production背景を参照する
- 左室の旧ベッド位置が歩行可能で、新背景に見える箪笥、ちゃぶ台、食卓前椅子がPhysics Collision内にある
- 寝室入口から玄関、および祖母定位置から台所入口までNavigation Pathが接続される
- Playerが寝室側から玄関までクリック移動でき、家具Collisionへ引っ掛からない
- 祖母が新しいちゃぶ台周囲と台所入口を巡回し、夕方は朝夕の定位置へ戻る
- 前景Occluder、寝室からの双方向遷移、帰宅、夕食、日記、一日終了、Save v1を維持する
- Production asset auditが新しい居間・台所背景を必須Assetとして検証する

手動確認:

1. 寝室から居間へ入り、旧寝室と扇風機が居間背景に重複していないことを確認する
2. 左室からちゃぶ台の上下、台所入口、玄関までKeyboardと左クリックの両方で移動する
3. ちゃぶ台、植木、食卓の前後でPlayerと祖母の描画順が自然に切り替わることを確認する
4. 祖母が家具を横切らず、ちゃぶ台周囲から台所入口へ到達することを確認する
5. 寝室へ戻って再び居間へ入り、入口付近でPlayerと祖母が通路を塞がないことを確認する
6. 河童目撃後に帰宅し、祖母との夕食、日記Review、一日終了まで進行することを確認する

---

## 54. Authored Stroll Path Movement

自動Validation:

- 散歩道外の座標が最寄り経路へ投影される
- 分岐をまたぐクリック経路が共有接続点を通る
- 経路に垂直なKeyboard入力で背景側へ侵入しない
- 経路に沿うKeyboard入力では通常速度で前進する
- 旧Saveの自由座標をLoadした場合、Save v1を維持したまま最寄り散歩道へ復元する
- クリック移動、クリック行動、祖母の生活移動、一日通しを含む全Validationが成功する

手動確認:

1. 各Locationで背景の水面、畑、家具、植栽方向を押し続けても散歩道から外れないことを確認する
2. 地面、NPC、虫、出入口をクリックし、背景オブジェクトを横切らず到達することを確認する
3. 分岐でクリック先または入力方向に応じた道を選べることを確認する
4. 常設Markerが細い線や目的地矢印にならず、控えめな足元記号として経路だけを示すことを確認する
5. 河童の気配・目撃Eventが川岸の歩行中に従来どおり一度だけ発生することを確認する

追加の分岐Validation:

- 接続点で方向入力に一致する枝を選べる
- 近接しているが未接続の経路へ垂直入力で飛び移らない
- クリック移動が中間接続点を越えて往復せず、目的地まで到達する
- 寝室、祖母宅、家周辺の折れ曲がった経路から出入口とInteraction地点へ到達できる

---

## 55. Persistent Walkable-area Markers

自動Validation:

- Vertical Sliceの全8 Locationで、カーソル位置に関係なく歩行可能Markerが有効である
- 各Locationに経路を読める最低数のMarkerが生成される
- 全Markerが散歩道上にあり、別の表示座標を二重管理していない
- Marker位置の2px範囲がWorld Collisionと重ならない
- 常時Markerテストを含む全18 Scene一括Validationが成功する

手動確認:

1. カーソルを画面外へ置いても淡い黄色のMarkerが見えることを確認する
2. 寝室・祖母宅ではMarkerが畳と板間の通路上にあり、布団、机、家具へ重ならないことを確認する
3. 屋外ではMarkerが土道、橋、川岸に沿い、水面、水田、畑、植栽へ重ならないことを確認する
4. Markerが虫や河童の気配を示す特別Markerに見えず、歩行可能範囲だけを伝えることを確認する
5. 目的地Markerと対象Hoverが常時Markerより明確に見分けられることを確認する

---

## 56. Marker-first Background Production

自動Validation:

- `LocationCatalog`に登録された全Production Locationが`WalkPathNetwork2D`を持つ
- 全Locationで常時表示Markerが有効で、経路を読める最低数が生成される
- MarkerがSceneの散歩道と同一データから生成され、World Collisionと重ならない
- 全背景Sourceが1672x941、Production画像が640x360である
- Production背景がNearest Filterで表示される

手動確認:

1. 背景制作前にMarker付きGreyboxを承認し、その後に背景を作成していることを確認する
2. 8エリアのMarker付き実画面で、Marker列が畳、床、土道、橋、乾いた川岸の上に連続していることを確認する
3. 家具、水面、水田、畑、岩、柵、植栽がMarker列へ割り込まないことを確認する
4. Markerを非表示にしても道が不自然な誘導線に見えず、生活感のある背景として成立することを確認する
5. 背景差し替え後にCollision、Foreground Occluder、出入口、NPC、虫、Event位置の足元が背景と一致することを確認する

---

## 57. Marker-first Background Geometry Finalization — Issue #071

自動Validation:

- 全Markerの2px表示範囲に加え、Player足元半径7pxがWorld Collisionと重ならない
- 寝室右下に、背景から撤去済みの植物Collisionが残っていない
- 家周辺の家基礎、石灯籠、郵便受け、樽Collisionが再制作背景の足元に一致する
- 川右端の岩Collisionが土道へ張り出さず、新しい岩・植生位置を塞ぐ
- 出入口、祖母生活地点、虫候補地点、河童Event地点が散歩道上またはInteraction距離内にある
- 全18 Scene一括Validationが成功する

手動確認:

1. `tools/capture_marker_first_baselines.ps1`で全8 LocationのMarker画像とGeometry Overlay画像を更新する
2. 寝室右下の空いた畳で、存在しない植物の赤いCollisionが表示されないことを確認する
3. 家周辺の上側道路で、家基礎・石灯籠・郵便受け・樽のCollisionが土道へ浮いていないことを確認する
4. 川右側のMarker列と岩Collisionの間にPlayer足元分の余白があることを確認する
5. 祖母宅、家周辺、川のForeground Occluderが背景の机、植栽、柵の輪郭を切り抜いていることを確認する

---

## 58. Walkable Surface Alignment

自動Validation:

- 全Markerの2px範囲とPlayer足元半径7pxがWorld Collisionと重ならない
- 田んぼ道・用水路沿い・川入口・縁側庭が水面、水田、木、岩、柵のCollisionを持つ
- 出入口、Spawn、虫候補、河童Event地点が散歩道上にある
- 家周辺の上側土道が右側の流れへ入らず、庭道が植栽区画の外を回る
- 川の散歩道が左低木と草地の切れ込みを避け、河童Event地点を残す
- 祖母宅の居間経路が中央植木の南側を通り、台所入口へ接続する
- 全18 Scene一括Validationが成功する

手動確認:

1. 各屋外Locationで土道・橋・川岸以外をクリックしても、水面・木・岩・柵の上へ歩かないことを確認する
2. 田んぼ道の木橋だけを渡り、水田と中央の流れへ入らないことを確認する
3. 用水路沿いと川入口で、木の根元と紫陽花の上を通らず土道だけを歩くことを確認する
4. 家周辺の右端で流れの上ではなく乾いた土道から川へ出られることを確認する
5. 祖母宅で中央植木と食器棚の上を歩かず、植木の南側から台所入口へ行けることを確認する

---

## 59. Marker-first Visual Baselines After Walkable Surface Alignment — Issue #072

自動Validation:

- `grandma_house`、`home_outdoor`、`river`のBake済みNavigationが現行`WorldCollision`から再生成されている
- 全8 Locationの`*_markers.png`と`*_geometry.png`が`docs/art-reference/03_gameplay/marker_first_geometry/`に存在し、640x360である
- Markerの2px範囲とPlayer足元半径7pxがWorld Collisionと重ならない
- 全18 Scene一括Validationが成功する

手動確認:

1. Marker画像で、黄色Marker列が畳、板間、土道、橋、乾いた川岸の上に連続していることを確認する
2. Geometry Overlayで、田んぼ道・用水路沿い・川入口・縁側庭の水面・水田・木・岩Collisionが赤い塗りとして見えることを確認する
3. 家周辺の右側流れが赤いCollisionになり、緑のNavigationが水面へ張り出していないことを確認する
4. 川のGeometry Overlayが再Bake後も河岸の土道を残していることを確認する
5. キーボードとクリックの両方で、障害物方向へ入力しても散歩道から外れないことを確認する

---

## 60. Vertical Slice Playtest Record — Issue #8

2026-08-17 に初回通し、2026-08-18 に #159 / #160 適用後の再採点を行った。

詳細:

- 初回: `docs/playtest/vertical_slice_2026-08-17.md`（平均 6.9）
- 再プレイ: `docs/playtest/vertical_slice_2026-08-18.md`（平均 7.3）

要約:

- 自動 18 Scene Validation と一日通し Smoke は成功する
- 初回人手通しは 7 Location と河童まで到達したが、虫を逃し、日記時点で 02:49 だった
- #159 で既定時計を 0.375 分/秒、#160 で Day1 セミを本道 `(380, 205)` へ優先配置した
- 再採点の平均は **7.3 / 10**（Milestone 2 移行基準を満たす）
- Issue #1 の成功条件は 6 問中 YES 6
- Blocker（起動不能・Save破損・進行不能）はなし
- 次は #10（Day 2 ループ）

---

## 61. Day 2 Wake-Sleep Loop — Issue #10

自動Validation:

- 本編の`grandma_house`は`end_vertical_slice_after_review = false`
- `tests/return_home_flow_smoke_test.tscn`で日記クローズ後に翌日07:00・寝室Spawnへ進む
- 翌朝は祖母の通常会話と外出ができる
- Day 30のReview後は31日目へ進まない
- `tests/vertical_slice_day_flow_smoke_test.tscn`はexportをtrueにし、完了Panel契約を維持する
- 本編進行は`vertical_slice_complete`を必須にしない

手動確認:

1. 寝室07:00からVertical Sliceの一日を進める
2. 夕食後の日記を閉じ、Day 2の07:00で寝室Spawnにいることを確認する
3. 祖母と朝会話してから外へ出られることを確認する
4. 完了Panelが出ないことを確認する
5. DebugMenuでDay 30夕方にして夕食〜日記を閉じ、日付が30のままであることを確認する

---

## 62. WeatherManager — Issue #11

自動Validation:

- 天気IDは `sunny` / `cloudy` / `rain` / `thunderstorm`
- Day 1 の既定は `sunny`
- `WeatherForecast` の重みと日付overrideで翌日天気を決める
- `CalendarManager.next_day()` だけが翌日を抽選する
- Debugの日付変更は抽選せず、既存DayRecordの天気を復元する
- Save v1 field `weather` と `DayRecord.weather` がround tripする
- 欠落した `weather` は `sunny` へ戻す
- EventConditionの `weathers` が現在天気を判定する
- 既存18 Scene一括Validationが成功する

手動確認:

1. 寝室07:00から開始し、HUD/日記の当日天気が晴れであることを確認する
2. F3のDebugMenuでWeatherを雨へApplyし、日記の `DayRecord` が雨になることを確認する
3. SaveしてWeatherを晴れへ戻し、Loadで雨が復元されることを確認する
4. 夕食後の日記を閉じてDay 2へ進み、翌日天気が `WeatherForecast` から決まることを確認する
5. 雨粒・環境音・HUDアイコンの確認は Issue #12

---

## 63. Weather Presentation — Issue #12

自動Validation:

- HUD/日記が `cloudy` / `rain` / `thunderstorm` を日本語表示する
- 天気アイコンが4種とも48x48で存在する
- 屋外Profileは雨・雷雨で環境音を切り替える
- 室内Profileは雨でもRoom Toneを維持する
- 雨粒Overlayは屋外の雨/雷雨だけ表示する
- 雷雨の夜でも`WeatherVisualPalette`の最低輝度を下回らない
- 画面フラッシュを使わない
- 既存18 Scene一括Validationが成功する

手動確認:

1. 寝室でF3からWeatherを雨にしても雨粒が出ず、室内の環境音が続くことを確認する
2. 縁側または田んぼ道へ出て、控えめな雨粒と雨の環境音へ切り替わることを確認する
3. HUDと日記のアイコン/文言が「雨」になることを確認する
4. Weatherを雷雨にし、雨粒が増えても画面がフラッシュしないことを確認する
5. 19:00の雷雨でも道が見える明るさを保つことを確認する
6. Weatherを曇りに戻すと雨粒が消え、セミ/ヒグラシの時間帯音源に戻ることを確認する

---

## 64. InventoryManager — Issue #13

自動Validation:

- 新規プレイは `bug_net` x1、所持金 0 から始まる
- catalog外のItem IDは加算できない
- 所持以上の消費と負の所持金は拒否する
- `EventCondition.required_items` が現在の所持を判定する
- Save v1 field `inventory.items` / `inventory.money` がround tripする
- 欠落した `inventory` は初期所持へ戻す
- Playtest resetが初期所持へ戻す
- 既存18 Scene一括Validationが成功する

手動確認:

1. 寝室07:00から開始し、Vertical Sliceの虫取りが従来どおり使えることを確認する
2. F3のDebugMenuでキュウリをGiveし、Snapshotに `cucumber` が増えることを確認する
3. Moneyを300にしてSaveし、Moneyを0へ戻してからLoadで300が復元されることを確認する
4. Runtime Resetでキュウリが消え、虫取り網だけが残ることを確認する
5. 所持品画面は Issue #14


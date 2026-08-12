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

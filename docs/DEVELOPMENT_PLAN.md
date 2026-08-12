# 夏休み妖怪日記 — DEVELOPMENT_PLAN

## 1. 目的

本書は『夏休み妖怪日記』の開発ロードマップ、マイルストーン、優先順位、完了条件を定義する。
実装の詳細は `ARCHITECTURE.md`、イベント仕様は `EVENT_GUIDE.md`、アート仕様は `ART_GUIDE.md` を参照する。

---

## 2. プロジェクト概要

- ジャンル: 2Dドット絵・生活アドベンチャー
- エンジン: Godot 4.x
- 言語: GDScript
- 視点: 斜め見下ろし
- 基本タイル: 32x32 pxを基準
- 主人公: 小学5〜6年生
- 舞台: 田舎町「夕凪町」
- プレイ期間: 夏休み30日間
- コア体験: 妖怪のいる田舎で、自分だけの夏休みを過ごす

### 最重要方針

プレイヤーに「ゲームを攻略した」ではなく、
**「あの町で夏休みを過ごした」**
と思ってもらう。

---

## 3. 開発原則

1. 最初から30日分を作らない。
2. 最初にVertical Slice「河童と出会う1日」を完成させる。
3. 1 Issue = 1責務を原則とする。
4. 実装都合でゲームデザインの核を変更しない。
5. 巨大な `GameManager` に責務を集約しない。
6. 日付・天気・妖怪出現などはデータ駆動を優先する。
7. 参考画像は制作基準であり、そのまま本番スプライトとして使用しない。
8. コンテンツ量より「移動」「空気感」「発見」の品質を優先する。
9. 2Dドット絵に正式方針変更済み。3D/Blender前提は採用しない。

---

## 4. 開発フェーズ

### Milestone 0 — Foundation

目的:
Godot 2Dプロジェクトとして、安全に拡張できる基盤を作る。

実装対象:

- Godotプロジェクト初期化
- ディレクトリ構造
- InputMap
- GameState
- GameClock
- CalendarManager
- SaveManager骨格
- SceneTransitionManager
- DebugMenu
- Player Scene骨格
- Pixel-perfect Camera2D骨格
- 共通ログ方針
- 最低限の自動テスト環境

完了条件:

- プロジェクトがエラーなく起動する
- プレイヤーSceneを表示できる
- DebugMenuから時刻・日付を変更できる
- Saveデータの最小保存/読込が動作する
- ドキュメントと実装が一致している

---

### Milestone 1 — Vertical Slice「河童と出会う1日」

#### 体験フロー

```text
朝
↓
祖母の家で起床
↓
祖母と会話
↓
外へ出る
↓
田舎道を歩く
↓
虫を発見
↓
虫取り
↓
川へ到着
↓
河童の気配
↓
河童を一瞬目撃
↓
夕方になる
↓
帰宅
↓
祖母との夕食
↓
日記を書く
↓
1日終了
```

#### 必須機能

- 8方向移動
- 歩行アニメーション
- Interaction
- 祖母NPC
- Dialogue
- 祖母の家マップ
- 家周辺マップ
- 川エリア
- GameClock
- 朝→昼→夕方の変化
- 環境音
- 虫Entity
- 虫取り
- 河童初遭遇イベント
- EventManager最小版
- DayRecord
- Diary UI
- Save/Load統合
- 帰宅フロー

#### Vertical Sliceで作らないもの

- 30日分イベント
- 妖怪25体
- 海
- 山
- 廃駅
- 夏祭り
- 写真システム完全版
- 釣り
- 自転車
- 秘密基地拡張
- Steam連携

#### 成功判定

以下を各10点満点で評価する。

- 移動の気持ちよさ
- 夏らしさ
- 田舎の空気感
- 虫取りの手触り
- 川へ向かいたくなるか
- 河童発見のワクワク
- 夕方の演出
- 音
- 日記の満足感
- 「もう1日遊びたい」と思うか

平均7点未満の場合、Milestone 2へ進まず改善する。

---

### Milestone 2 — 最初の7日間

追加対象:

- 神社
- 駄菓子屋
- 田んぼ
- 秘密基地
- 太一
- 美鈴
- 悠斗
- ぬらりひょん
- 唐傘お化け
- 化け狸
- 座敷童子
- 雨
- 夜探索
- 「気になること」
- 妖怪状態進行

完了条件:
1〜7日目を通してプレイできる。

---

### Milestone 3 — 夏休みの主要遊び

- 釣り
- 水切り
- 自転車
- 写真
- 所持品
- お小遣い
- 駄菓子屋
- NPCスケジュール
- 妖怪スケジュール
- 噂
- 日記拡張
- 秘密基地

---

### Milestone 4 — 8〜15日目

追加エリア:

- 小学校
- 廃駅
- 古いトンネル
- 裏山
- 漁港
- 海岸

主要コンテンツ:

- 猫又
- 天狗
- 山姥
- 磯女
- 件
- 母親の日記
- お盆
- 夏祭り準備

---

### Milestone 5 — 8月15日 妖怪祭り

- 通常神社の祭り差分
- 人間NPC群
- 妖怪NPC群
- 提灯
- 狐火
- 特殊BGM
- 夜演出
- イベント連鎖
- 妖怪祭り専用会話
- 祭りの日記

「別世界マップ」ではなく、普段の神社が異なる姿になる構造を優先する。

---

### Milestone 6 — 16〜30日目

- 夏祭り後の日常
- 妖怪との別れ
- 人間友達イベント
- 祖母イベント
- 夏の終わり演出
- 荷造り
- 28〜29日目の自由行動強化
- 30日目帰宅
- バス停
- エンディング
- 最終アルバム

---

### Milestone 7 — Content Expansion

- 妖怪25体
- 虫拡張
- 魚拡張
- NPC会話拡張
- サブイベント
- 天候イベント
- 隠しイベント
- 周回時の発見差分

---

### Milestone 8 — Polish

- ドット絵統一
- アニメーション
- VFX
- UI
- 音
- BGM
- 入力感
- カメラ
- パフォーマンス
- アクセシビリティ
- バグ修正

---

### Milestone 9 — Release

- Windows build
- Steam
- Controller
- Save migration確認
- 解像度対応
- Credits
- Legal
- Store assets
- Trailer build
- Release checklist

---

## 5. 推奨Issue順 — Milestone 0

```text
#001 Initialize Godot 2D project
#002 Create repository structure
#003 Configure InputMap
#004 Implement GameState skeleton
#005 Implement GameClock
#006 Implement CalendarManager
#007 Implement SaveManager skeleton
#008 Implement SceneTransitionManager
#009 Implement DebugMenu
#010 Create Player scene skeleton
#011 Create pixel-perfect Camera2D
#012 Add validation/test scaffold
```

---

## 6. 推奨Issue順 — Vertical Slice

```text
#020 Player 8-direction movement
#021 Player walk animation
#022 Interaction system
#023 Dialogue system
#024 Grandma NPC base
#025 Grandma house map
#026 Outdoor home area
#027 River map
#028 Day-period visual controller
#029 Environment audio
#030 Bug entity
#031 Bug catching mechanic
#032 Minimal EventManager
#033 Kappa data/state
#034 Kappa first-sighting event
#035 Return-home flow
#036 DayRecord
#037 Diary UI
#038 Save integration
#039 Vertical Slice playtest tools
#040 Vertical Slice polish
```

---

## 7. Definition of Done

Issue完了条件:

- Requirementを満たしている
- Godot起動時エラーなし
- 既存機能を壊していない
- 必要なテストを実行済み
- Debug用printを放置していない
- 不要なコメントアウトコードなし
- ハードコードを増やしていない
- ドキュメント更新済み
- 手動確認方法がPRに記載されている
- Save形式変更時は `SAVE_FORMAT.md` 更新済み

---

## 8. 開発判断の優先順位

迷った場合は以下の順で判断する。

1. 夏休みを過ごしている感覚
2. 世界を歩く気持ちよさ
3. 妖怪を発見するワクワク
4. 日常の生活感
5. 妖怪との交流
6. 日記
7. ストーリー
8. コンテンツ量
9. 豪華さ

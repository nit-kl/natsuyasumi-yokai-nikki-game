# AGENTS.md

## Project

『夏休み妖怪日記』

田舎の祖母の家で30日間の夏休みを過ごし、
普通の人には見えない妖怪たちと交流する
2Dドット絵の生活アドベンチャーゲーム。

本作は戦闘中心RPGではない。
プレイヤーに「攻略した」ではなく
「この町で夏休みを過ごした」と感じてもらうことを最重要目標とする。

---

## Engine / Technology

- Godot 4.x
- GDScript
- 2D Pixel Art
- 斜め見下ろし視点
- TileMapLayer
- CharacterBody2D
- AnimatedSprite2D
- SpriteFrames
- AnimationPlayer
- Camera2D

3D / Blender / GLBを前提とした実装は行わない。

---

## Current Milestone

現在の最優先目標は Vertical Slice:

# 「河童と出会う1日」

以下だけを完成させる。

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
虫を見つける
↓
虫取り
↓
川へ行く
↓
河童の気配
↓
河童を一瞬目撃
↓
夕方
↓
祖母の家へ帰る
↓
日記を書く
↓
1日終了
```

30日分のゲームを先に作ってはいけない。

---

## Required Documents

実装前に必要に応じて以下を読むこと。

- `docs/DEVELOPMENT_PLAN.md`
- `docs/GAME_DESIGN.md`
- `docs/ARCHITECTURE.md`
- `docs/ART_GUIDE.md`
- `docs/EVENT_GUIDE.md`
- `docs/SAVE_FORMAT.md`
- `docs/TEST_PLAN.md`
- `docs/ASSET_CATALOG.md`

仕様判断で迷った場合は、上記ドキュメントを優先する。

---

## Art References

アート制作・Scene構築前に以下を参照する。

```text
docs/art-reference/00_master/
docs/art-reference/01_characters/
docs/art-reference/02_environment/
docs/art-reference/03_gameplay/
docs/art-reference/04_ui/
```

重要:

Reference画像は制作基準資料である。

説明文字・複数ポーズ・背景を含むReference Sheetを
そのままCropしてProduction Assetとして使用してはいけない。

実ゲーム用Sprite / Tile / UI素材は
`assets/` 以下へ別途配置する。

---

## Core Design Rules

### 1. 妖怪は敵として扱わない

基本行動:

- 気配を感じる
- 見つける
- 観察する
- 話す
- 遊ぶ
- 仲良くなる

戦闘・HP・攻撃力・レベルを中心システムにしない。

### 2. クエストマーカー中心にしない

大量の `!` や目的地矢印を使用しない。

代わりに「気になること」や
NPCの会話、環境変化からプレイヤーに気付かせる。

### 3. 1周コンプリートを前提にしない

イベントの取り逃しを許容する。

「自分の夏休み」がプレイヤーごとに異なることを価値とする。

### 4. 妖怪は自然に存在する

派手なSpawn Effectは禁止。

妖怪は「出現した」のではなく
「そこにいたことに気付いた」と感じる演出にする。

### 5. 何もしない時間にも意味を持たせる

縁側、雨宿り、昼寝、海を見る等を
無価値な行動として扱わない。

---

## Architecture Rules

- 巨大な `GameManager` を作らない
- 1 class = 1 responsibility を基本とする
- Scene固有ロジックをCore Managerへ入れない
- Event条件をScene Scriptへ大量直書きしない
- Resource / data-driven設計を優先する
- Magic Numberを避ける
- NodePathの深いハードコードを避ける
- Save対象IDは軽率に変更しない
- Signalは責務分離に有効な場合に使用する
- Autoloadを便利なGlobal変数置場にしない

---

## Pixel Art Rules

- Texture Filter = Nearest
- Mipmap原則OFF
- 非整数Scaleを避ける
- Pixel densityを統一する
- Character / Tile / UI間で解像感を崩さない
- Base tileは32x32pxを初期基準とする
- 実画面テスト後に最終固定する

---

## Development Rules

### Before coding

1. 関連ドキュメントを読む
2. 既存コードを読む
3. 影響範囲を確認
4. Save形式への影響を確認
5. 小さい変更単位に分解する

### During coding

- 1 Issue = 1責務
- 不要な大規模Refactorを同時に行わない
- 仕様外の機能を勝手に追加しない
- Plugin導入は必要性を説明してから行う
- Production Assetがない場合、仮素材であることを明示する

### After coding

1. Godotエラー確認
2. Tests / validation
3. 手動確認
4. Debug print除去
5. 関連Docs更新
6. 変更ファイル一覧を報告
7. 次のIssue候補を報告

---

## Definition of Done

Issueを完了扱いにする条件:

- Requirementを満たす
- Godot起動時エラーなし
- 既存機能を壊していない
- 必要なテストを実行済み
- Debug print残存なし
- 不要なコメントアウトコードなし
- Docs更新済み
- Manual Test手順あり
- Save形式変更時は `SAVE_FORMAT.md` 更新済み

---

## Debug Tools

開発初期からDebugMenuを重視する。

最終的に以下を扱える構造にする。

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

本番Buildでは無効化する。

---

## Priority

迷った場合の優先順位:

1. 世界を歩く気持ちよさ
2. 夏の空気感
3. 妖怪発見のワクワク
4. 日常の生活感
5. 妖怪との交流
6. 日記
7. ストーリー
8. コンテンツ量
9. 豪華さ

---

## Do Not Do

- 最初に町全体を作らない
- 最初に妖怪25体を作らない
- 最初に30日分イベントを作らない
- 3D化しない
- Blender前提へ戻さない
- レベル制を追加しない
- スタミナ制を追加しない
- 大量のクエストUIを追加しない
- Reference SheetをそのままProduction Sprite化しない
- Vertical Slice完成前にSteam対応へ進まない

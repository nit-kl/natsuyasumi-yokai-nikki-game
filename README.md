# 夏休み妖怪日記

2Dドット絵で描く、田舎の夏休み生活アドベンチャー。

主人公は夏休みの30日間を祖母の住む「夕凪町」で過ごす。
虫取り、川遊び、友達との秘密基地づくりなどを楽しむ一方、
主人公にだけ普通の人には見えない妖怪たちの姿が見える。

妖怪を倒したり集めたりすることではなく、
**妖怪のいる町で、自分だけの夏休みを過ごすこと**
を中心とする。

---

## Current Status

Pre-production / Vertical Slice development.

現在の目標:

# 「河童と出会う1日」

```text
祖母の家
↓
虫取り
↓
川
↓
河童を目撃
↓
夕方
↓
帰宅
↓
日記
```

---

## Technology

- Godot 4.4以降（Milestone 0 validation: Godot 4.7.1）
- GDScript
- 2D Pixel Art
- TileMapLayer
- CharacterBody2D
- AnimatedSprite2D
- Camera2D

---

## Documents

開発仕様は `/docs` を参照。

```text
docs/
├─ DEVELOPMENT_PLAN.md
├─ GAME_DESIGN.md
├─ ARCHITECTURE.md
├─ ART_GUIDE.md
├─ EVENT_GUIDE.md
├─ SAVE_FORMAT.md
├─ TEST_PLAN.md
├─ ASSET_CATALOG.md
└─ art-reference/
```

Codexで作業する場合は、
最初にリポジトリ直下の `AGENTS.md` を確認すること。

---

## Repository Structure

```text
/
├─ AGENTS.md
├─ README.md
├─ project.godot
│
├─ docs/
├─ scenes/
├─ scripts/
├─ resources/
├─ assets/
├─ tests/
└─ tools/
```

詳細は `docs/ARCHITECTURE.md`。

---

## Art Direction

- 懐かしい日本の夏
- 斜め見下ろし
- 2Dドット絵
- 昼は鮮やか
- 夕方はノスタルジック
- 夜は少し怖いが歩きたくなる
- 妖怪は世界に自然に混ざっている

Reference:

```text
docs/art-reference/
```

Reference Sheetは本番ゲーム用Spriteとして直接使用しない。

---

## Development Strategy

最初から30日分を制作しない。

Vertical Sliceを完成させ、

- 移動が楽しい
- 夏らしい
- 虫取りが楽しい
- 河童発見が面白い
- 日記に満足感がある

ことを確認した後にコンテンツを拡張する。

---

## Starting Development

1. Godotの使用バージョンを固定
2. `AGENTS.md` と `/docs` を確認
3. Milestone 0を実装
4. Vertical Sliceへ進む

詳細:

`docs/DEVELOPMENT_PLAN.md`

Milestone 0のValidation:

```powershell
powershell -ExecutionPolicy Bypass -File tools/validate_project.ps1
```

---

## Core Vision

> 「ゲームをクリアした」ではなく、
> 「あの町で夏休みを過ごした」と思えるゲーム。

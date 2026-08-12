# AGENTS.md

## Project

「夏休み妖怪日記」

田舎の祖母の家で30日間の夏休みを過ごし、
普通の人には見えない妖怪たちと交流する
2Dドット絵の生活アドベンチャーゲーム。

## Engine

- Godot 4.x
- GDScript
- 2D Pixel Art
- 斜め見下ろし視点
- TileMapLayer中心

3D / Blenderは使用しない。

## Core Experience

プレイヤーに、

「ゲームを攻略した」

ではなく、

「この町で夏休みを過ごした」

と思わせること。

## Current Milestone

Vertical Slice:
「河童と出会う1日」

朝
→ 祖母の家
→ 外へ出る
→ 虫取り
→ 川
→ 河童を目撃
→ 夕方
→ 帰宅
→ 日記
→ 終了

30日分を先に作らない。

## Required Documents

作業前に必要に応じて以下を読むこと。

- docs/DEVELOPMENT_PLAN.md
- docs/GAME_DESIGN.md
- docs/ARCHITECTURE.md
- docs/ART_GUIDE.md
- docs/EVENT_GUIDE.md
- docs/SAVE_FORMAT.md
- docs/TEST_PLAN.md
- docs/ASSET_CATALOG.md

## Rules

- 巨大なGameManagerを作らない
- 1 Issue = 1責務
- イベントはデータ駆動を優先
- Sceneに日付条件を大量直書きしない
- Reference画像をそのまま本番Spriteとして使わない
- Pixel densityを統一する
- 既存仕様を勝手に変更しない
- 実装後は必ず動作確認する
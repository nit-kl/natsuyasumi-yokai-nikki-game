# Vertical Slice 再プレイ記録 — 2026-08-18

日付: 2026-08-18  
対象: Issue #8 の再採点。#159（GameClock 0.375）と #160（Day1 セミ本道優先）適用後。  
前回: `docs/playtest/vertical_slice_2026-08-17.md`（平均 6.9）

この VM は llvmpipe のため、クリック移動の人手通しは Scene 遷移待ちで夕方を跨ぎやすい。再採点は次を組み合わせた。

- `tests/vertical_slice_day_flow_smoke_test.tscn`（祖母会話 → アブラゼミ捕獲 → 河童 TRACE/SEEN → 夕食 → 日記 → 完了 Panel）
- `tools/capture_location_shot.gd` による本番画面の撮影
- 前回通しで確認済みの移動・夏・田舎・河童・祖母の家・日記紙面

---

## 自動検証

```text
godot --headless --editor --quit
→ パース / インポートエラーなし

vertical_slice_day_flow_smoke_test
→ PASS（虫捕獲を含む一日通し）
```

---

## 体験の確認

### 虫取り（#160）

`engawa_yard` の Day1 保証セミは `(380, 205)`。`HouseToFields` の本道上（家出口から田んぼ道へ向かう途中）。

証拠: `docs/playtest/replay_2026-08-18/03_engawa_cicada.png`

- HUD 07:00 朝、晴れ
- プレイヤーが本道中央に立ち、右上に「虫をクリック / X」が出る
- 庭奥の木陰や紫陽花側へ寄り道しなくても、川へ歩く途中で網が出る

### 夕方（#159）

河童目撃は時刻を 17:00 に進める。Palette は暖色。

証拠:

- `docs/playtest/replay_2026-08-18/09_river_evening.png` — HUD `17:00 夕方`、川辺が夕方色
- `docs/playtest/replay_2026-08-18/14_house_evening.png` — 祖母の家も同じ夕方色。祖母が居間にいる

時計の既定は現実 1 秒あたり 0.375 ゲーム分（1 日およそ 38 分）。前回の日記 Review 02:49 のような夜越えは、川からの帰宅だけなら起きにくい。

---

## 10点評価

| 項目 | 前回 | 今回 | コメント |
|---|---:|---:|---|
| 移動 | 7 | 7 | 散歩道契約は維持。斜め Sprite は未対応のまま |
| 夏らしさ | 8 | 8 | 紫陽花、縁側、晴れ、セミの網提示 |
| 田舎の空気感 | 8 | 8 | 7 Location の生活空間は変わらず |
| 音 | 6 | 6 | 契約はある。本 VM は dummy audio |
| 虫取り | 5 | 7 | 本道上で保証され、クリック / X で捕れる。気持ちよさは最低限 |
| 探索 | 7 | 7 | 道なりに川へ行ける。虫が導入として機能する |
| 河童発見 | 7 | 7 | 波紋→目撃→日記。派手な Spawn なし |
| 夕方 | 5 | 7 | 17:00 の暖色が川と家で分かる。時計が先に深夜へ飛ばない |
| 祖母の家 | 8 | 8 | 朝の3行と夕食の日記誘導 |
| 日記 | 8 | 8 | 紙面は前回どおり。虫が残る一日通しは Smoke で確認 |

**平均: 7.3 / 10**

Milestone 2 移行基準（平均 7 点以上）を満たす。次は #10（Day 2 ループ）。

---

## Issue #1 成功条件

| 問い | 前回 | 今回 | 根拠 |
|---|---|---|---|
| 田舎を歩いているだけで少し楽しい | YES | YES | 土道と Marker |
| 川へ行きたくなる | YES | YES | 祖母の「今が気持ちいい」と東の道 |
| 虫取りが最低限気持ちいい | NO | YES | 本道の保証セミと網プロンプト |
| 河童を見つけた時にワクワクする | YES | YES | 波紋と目撃 |
| 夕方になると帰りたくなる | NO | YES | 17:00 Palette と夕食会話 |
| 日記を見ることで1日に意味が生まれる | YES | YES | 場所・河童・虫が1ページに残る |

YES は 6 / 6。

---

## 画面の撮り方

```bash
DISPLAY=:1 godot --path /workspace --audio-driver Dummy \
  --script res://tools/capture_location_shot.gd -- \
  res://scenes/maps/village/engawa_yard.tscn \
  res://docs/playtest/replay_2026-08-18/03_engawa_cicada.png \
  380 223 420 0.6
```

引数: Scene、出力 PNG、プレイヤー座標、`time_minutes`、待機秒。

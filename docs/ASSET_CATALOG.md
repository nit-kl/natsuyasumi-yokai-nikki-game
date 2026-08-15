# 夏休み妖怪日記 — ASSET_CATALOG

## 1. 目的

制作済みReferenceと、本番ゲーム用Production Assetを分離して管理する。

記号:

- [x] 完了
- [ ] 未完了
- [~] 制作中

---

# 2. Master Reference

- [x] ゲームプレイ基準画像
- [x] 必要アセット一覧
- [x] ドット絵方向性資料

保存先:

```text
docs/art-reference/00_master/
```

---

# 3. Characters

## 主人公

Reference:

- [x] ドット絵設定画
- [x] ターンアラウンド
- [x] Action reference
- [x] 表情reference

Production:

- [x] idle / walk / run 8方向Animation制御（コード描画Placeholder）
- [x] idle / walk / run 4方向Production Sprite（斜めはcardinal fallback）
- [ ] idle 8方向
- [ ] walk 8方向
- [ ] run 8方向
- [ ] bug_net
- [ ] crouch
- [ ] surprised
- [ ] item_hold
- [ ] bicycle
- [ ] fishing
- [ ] camera
- [ ] sit
- [ ] sleep

保存先:

```text
assets/sprites/characters/protagonist/
```

---

## 祖母

Reference:

- [x] ドット絵設定画
- [x] ターンアラウンド
- [x] Action reference
- [x] 表情reference

Production:

- [x] idle 4方向
- [x] walk 4方向
- [ ] talk
- [ ] sit
- [ ] cooking
- [ ] farming
- [ ] carry_tray

---

## 太一

Reference:

- [ ] Character reference

Production:

- [ ] idle
- [ ] walk
- [ ] run
- [ ] bug_catching
- [ ] river_play

---

## 美鈴

Reference:

- [ ] Character reference

Production:

- [ ] idle
- [ ] walk
- [ ] shrine actions

---

## 悠斗

Reference:

- [ ] Character reference

Production:

- [ ] idle
- [ ] walk
- [ ] scared

---

## 凛

Reference:

- [ ] Character reference

Production:

- [ ] idle
- [ ] walk

---

# 4. Yokai

## 河童

Reference:

- [x] ドット絵設定画
- [x] Movement reference
- [x] Action reference
- [x] Expression reference

Production:

- [ ] idle
- [ ] walk
- [ ] swim
- [x] surface（Vertical Slice目撃用4 frame）
- [x] dive（surface animation終端として収録）
- [ ] eat_cucumber
- [ ] stone_skip
- [ ] surprised

---

## 座敷童子

Reference:

- [ ] Character reference

Production:

- [ ] idle
- [ ] walk
- [ ] sit
- [ ] hide
- [ ] play

---

## 猫又

Reference:

- [ ] Character reference

Production:

- [ ] cat_idle
- [ ] cat_walk
- [ ] two_tail_idle
- [ ] fish_steal

---

## 化け狸

Reference:

- [ ] Character reference

Production:

- [ ] idle
- [ ] walk
- [ ] transform
- [ ] surprised

---

## ぬらりひょん

Reference:

- [ ] Character reference

Production:

- [ ] idle
- [ ] walk
- [ ] ramune

---

## 天狗

Reference:

- [ ] Character reference

Production:

- [ ] idle
- [ ] fly
- [ ] wind
- [ ] sit_tree

---

# 5. Environment

## 祖母の家

Reference:

- [x] タイル・オブジェクト分解

Production:

- [x] Scene / TileMapLayer / Collision / 出入口
- [x] 640x360 Production室内背景プレート（寝室、居間、台所、縁側）
- [x] 寝室独立エリア背景（1672x941 Source / 640x360 Production）
- [x] 居間・台所分割用背景（1672x941 Source / 640x360 Production、後続差し替え候補）
- [ ] 再利用用32x32 modular TileSetへの分解

### 外観
- [ ] roof tiles
- [ ] wall tiles
- [ ] windows
- [ ] doors
- [ ] engawa
- [ ] foundation
- [ ] steps

### 内装
- [x] tatami（背景プレート）
- [x] wood floor（背景プレート）
- [x] hallway（背景プレート）
- [x] fusuma（背景プレート）
- [x] shoji（背景プレート）
- [x] kitchen floor（背景プレート）

### Furniture
- [x] chabudai（背景プレート）
- [x] cushion（背景プレート）
- [ ] fan（寝室内の通路を妨げるため撤去）
- [x] TV（背景プレート）
- [x] cabinet（背景プレート）
- [x] refrigerator（背景プレート）
- [x] sink（背景プレート）
- [x] stove（背景プレート）
- [ ] altar
- [x] futon（背景プレート）

### Props
- [ ] wind chime
- [ ] mosquito coil
- [ ] watermelon
- [ ] tea set
- [ ] calendar
- [ ] radio
- [ ] slippers

---

## 川エリア

Reference:

- [x] 川エリア用タイルセット

Production:

- [x] Scene / Water Layer / Collision / 帰路
- [x] 640x360 Production背景プレート（水面、浅瀬、川岸、土道、草花）
- [x] 川入口独立エリア背景（1672x941 Source / 640x360 Production）
- [x] ripple VFX（4 frame）
- [ ] 再利用用32x32 modular TileSetへの分解

- [ ] water calm
- [ ] water flow
- [ ] shallow water
- [ ] deep water
- [ ] water edge
- [ ] river bank grass
- [ ] river bank stone
- [ ] river curves
- [ ] dirt path
- [ ] grass
- [ ] flower patch
- [ ] rocks
- [ ] stepping stones
- [ ] wooden bridge
- [ ] guard rail
- [ ] river plants
- [x] ripple VFX
- [ ] splash VFX

---

## 家周辺

- [x] Scene / TileMapLayer / Collision / 出入口
- [x] 640x360 Production背景プレート（家、田舎道、田んぼ、用水路、庭）
- [x] 縁側・庭独立エリア背景（1672x941 Source / 640x360 Production）
- [x] 田んぼ道独立エリア背景（1672x941 Source / 640x360 Production）
- [x] 用水路・木陰独立エリア背景（1672x941 Source / 640x360 Production）
- [ ] 再利用用32x32 modular TileSetへの分解
- [ ] rice field
- [ ] dirt road
- [ ] utility pole
- [ ] wires
- [ ] guard rail
- [ ] hydrangea
- [ ] morning glory
- [ ] mailbox
- [ ] bicycle parking
- [ ] garden props

---

# 6. Bug Catching

Reference:

- [x] 虫取り用アセット資料

Production:

### Tools
- [x] bug net（Vertical Slice用Production Sprite）
- [ ] insect cage
- [ ] observation case

### Insects
- [ ] kabutomushi
- [ ] nokogiri_kuwagata
- [ ] miyama_kuwagata
- [x] aburazemi（Vertical Slice用Production Sprite）
- [x] aburazemi area spawn profiles（家周辺0〜2、川0〜1、Day 1最低1匹）
- [ ] minminzemi
- [ ] higurashi
- [ ] oniyanma
- [ ] red_dragonfly
- [ ] grasshopper
- [ ] mantis
- [ ] butterfly
- [ ] firefly

### VFX
- [ ] discovery
- [x] net swing（向き追従Tween演出）
- [x] catch success（小さな輪・きらめきの実装演出）
- [ ] escape
- [ ] grass rustle

Vertical Slice必須:

- [x] bug net
- [ ] kabutomushi
- [x] semi（aburazemi）
- [ ] tonbo
- [x] catch success

---

# 7. UI

## Diary

Reference:

- [x] 日記UI設定画

Production:

- [x] diary cover（224x280 Production Pixel Art）
- [x] open notebook（Vertical Slice日別記録画面）
- [x] page base（512x320 Production Pixel Art）
- [ ] tabs
- [ ] photo frame
- [x] tape（日別ページ背景に統合）
- [ ] pencil icons
- [x] weather icons（Vertical Slice用sunny）
- [x] date stamp（当日を動的表示）
- [x] yokai stamp（Vertical Slice用kappa）
- [ ] page arrow
- [x] page turn animation（0.22秒の表紙→日別ページTween）

Vertical Slice必須:

- [x] diary cover
- [x] daily page
- [x] weather icons（sunny）
- [x] kappa note
- [x] insect record（aburazemi）

---

## HUD

- [x] date/time（夏休みの日数・時刻・時間帯）
- [x] weather（sunny icon + 文字表示）
- [x] interaction prompt（状況依存時のみ表示）
- [x] tool indicator（Vertical Slice用虫取り網）

---

## Dialogue

- [x] dialogue panel（560x132 Production Pixel Art）
- [x] speaker name tag（会話枠へ統合）
- [x] choice button（240x42、focus / hover / pressed状態）
- [ ] character portrait

---

# 8. Audio

Vertical Slice:

- [x] Location / 時間帯別の環境音切替制御
- [x] summer daytime ambience
- [x] cicada loop
- [x] river loop
- [x] evening higurashi
- [x] grandma house interior
- [x] bug catch SFX（swing / success）
- [x] water ripple
- [x] kappa subtle cue
- [x] page turn
- [x] UI confirm/cancel（短いmono Ogg、会話決定・日記を閉じる操作）

---

# 9. Vertical Slice必須アセット一覧

Art direction benchmark:

- [x] 家周辺・主人公・田園・用水路の代表画面（Production Tile / Spriteではない）

### Characters
- [x] protagonist production sprites（Vertical Slice用4方向）
- [x] grandma production sprites（Vertical Slice用4方向）
- [x] kappa production sprites（Vertical Slice用surface / dive）

### Map
- [x] grandma house（640x360背景プレート）
- [x] house exterior（家周辺背景プレートへ統合）
- [x] road（家周辺・川背景プレートへ統合）
- [x] river（640x360背景プレート）
- [ ] bridge（現Vertical Slice経路では未使用）

### Nature
- [x] tree（背景プレートへ統合）
- [x] grass（背景プレートへ統合）
- [x] rice（家周辺背景プレートへ統合）
- [x] rocks（背景プレートへ統合）
- [x] flower（背景プレートへ統合）
- [x] hydrangea（背景プレートへ統合）

### Props
- [x] utility pole（家周辺背景プレートへ統合）
- [ ] guard rail（現Vertical Slice経路では未使用）
- [ ] bicycle（現Vertical Sliceでは未使用）
- [x] bug net（Player操作用Production Sprite）
- [ ] insect cage（現Vertical Sliceでは未使用）
- [ ] fan（寝室内の通路を妨げるため撤去）
- [x] wind chime（祖母の家背景プレートへ統合）
- [x] mosquito coil（祖母の家背景プレートへ統合）

### Creatures
- [ ] kabutomushi（現Vertical Sliceでは未使用）
- [x] semi（aburazemi Production Sprite）
- [ ] tonbo（現Vertical Sliceでは未使用）

### UI
- [x] minimal HUD
- [x] interaction（状況依存Prompt）
- [x] diary（表紙・日別ページ・記録印）

### Time
- [x] morning palette（soft golden）
- [x] daytime palette（light summer warmth）
- [x] evening palette（nostalgic orange）
- [x] night palette（readable blue-gray）

---

## 10. Vertical Slice Area Subdivision — Issue #069

新規背景はReference SheetのCropではなく、既存Production画面とReferenceを画風・密度の基準として
独立生成した背景である。`*_source.png`は生成原寸（1672x941）、Sceneが参照する同名の
`map_*.png`はNearestで640x360へ縮小したProduction版とする。

| Area | Production asset | Source asset | Scene usage |
|---|---|---|---|
| 寝室 | `assets/maps/bedroom/map_bedroom.png` | `assets/maps/bedroom/map_bedroom_source.png` | 使用中 |
| 縁側・庭 | `assets/maps/engawa_yard/map_engawa_yard.png` | `assets/maps/engawa_yard/map_engawa_yard_source.png` | 使用中 |
| 田んぼ道 | `assets/maps/paddy_road/map_paddy_road.png` | `assets/maps/paddy_road/map_paddy_road_source.png` | 使用中 |
| 用水路の木陰 | `assets/maps/irrigation_shade/map_irrigation_shade.png` | `assets/maps/irrigation_shade/map_irrigation_shade_source.png` | 使用中 |
| 川入口 | `assets/maps/river_entrance/map_river_entrance.png` | `assets/maps/river_entrance/map_river_entrance_source.png` | 使用中 |
| 居間・台所候補 | `assets/maps/grandma_house_living/map_grandma_house_living.png` | `assets/maps/grandma_house_living/map_grandma_house_living_source.png` | 未接続。既存NPC・帰宅Flowを維持するため後続Issue候補 |

既存の`grandma_house`と`river`背景は継続使用する。Production Sceneは`*_source.png`を参照しない。

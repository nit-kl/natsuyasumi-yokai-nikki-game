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

- [ ] idle
- [ ] walk
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
- [ ] surface
- [ ] dive
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

- [x] Scene / TileMapLayer / Collision / 出入口Greybox（Production Tile未設定）

### 外観
- [ ] roof tiles
- [ ] wall tiles
- [ ] windows
- [ ] doors
- [ ] engawa
- [ ] foundation
- [ ] steps

### 内装
- [ ] tatami
- [ ] wood floor
- [ ] hallway
- [ ] fusuma
- [ ] shoji
- [ ] kitchen floor

### Furniture
- [ ] chabudai
- [ ] cushion
- [ ] fan
- [ ] TV
- [ ] cabinet
- [ ] refrigerator
- [ ] sink
- [ ] stove
- [ ] altar
- [ ] futon

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

- [x] Scene / Water Layer / Collision / 帰路Greybox（Production Tile未設定）

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
- [ ] ripple VFX
- [ ] splash VFX

---

## 家周辺

- [x] Scene / TileMapLayer / Collision / 出入口Greybox（Production Tile未設定）
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
- [ ] bug net
- [ ] insect cage
- [ ] observation case

### Insects
- [ ] kabutomushi
- [ ] nokogiri_kuwagata
- [ ] miyama_kuwagata
- [ ] aburazemi
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
- [ ] net swing
- [ ] catch success
- [ ] escape
- [ ] grass rustle

Vertical Slice必須:

- [ ] bug net
- [ ] kabutomushi
- [ ] semi
- [ ] tonbo
- [ ] catch success

---

# 7. UI

## Diary

Reference:

- [x] 日記UI設定画

Production:

- [ ] diary cover
- [ ] open notebook
- [ ] page base
- [ ] tabs
- [ ] photo frame
- [ ] tape
- [ ] pencil icons
- [ ] weather icons
- [ ] date stamp
- [ ] yokai stamp
- [ ] page arrow
- [ ] page turn animation

Vertical Slice必須:

- [ ] diary cover
- [ ] daily page
- [ ] weather icons
- [ ] kappa note
- [ ] insect record

---

## HUD

- [ ] date/time
- [ ] weather
- [ ] interaction prompt
- [ ] tool indicator

---

# 8. Audio

Vertical Slice:

- [x] Location / 時間帯別の環境音切替制御（音源未設定）
- [ ] summer daytime ambience
- [ ] cicada loop
- [ ] river loop
- [ ] evening higurashi
- [ ] grandma house interior
- [ ] bug catch SFX
- [ ] water ripple
- [ ] kappa subtle cue
- [ ] page turn
- [ ] menu confirm/cancel

---

# 9. Vertical Slice必須アセット一覧

### Characters
- [ ] protagonist production sprites
- [ ] grandma production sprites
- [ ] kappa production sprites

### Map
- [ ] grandma house
- [ ] house exterior
- [ ] road
- [ ] river
- [ ] bridge

### Nature
- [ ] tree
- [ ] grass
- [ ] rice
- [ ] rocks
- [ ] flower
- [ ] hydrangea

### Props
- [ ] utility pole
- [ ] guard rail
- [ ] bicycle
- [ ] bug net
- [ ] insect cage
- [ ] fan
- [ ] wind chime
- [ ] mosquito coil

### Creatures
- [ ] kabutomushi
- [ ] semi
- [ ] tonbo

### UI
- [ ] minimal HUD
- [ ] interaction
- [ ] diary

### Time
- [ ] morning palette
- [ ] daytime palette
- [ ] evening palette

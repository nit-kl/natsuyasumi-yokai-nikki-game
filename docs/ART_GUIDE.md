# 夏休み妖怪日記 — ART_GUIDE

## 1. アートコンセプト

**懐かしい日本の夏に、妖怪だけが少し混ざっている。**

世界の90%は普通の夏休み。
残り10%に違和感と妖怪が存在する。

---

## 2. 描画方針

- 2D Pixel Art
- 斜め見下ろし
- 温かみのある色
- 昼は鮮やか
- 夕方は郷愁
- 夜は美しさと少しの怖さ
- 妖怪は世界から浮きすぎない

---

## 3. 基準画像

すべてのアセット制作は以下を参照する。

```text
docs/art-reference/00_master/
docs/art-reference/01_characters/
docs/art-reference/02_environment/
docs/art-reference/03_gameplay/
docs/art-reference/04_ui/
```

Reference sheetは本番Spriteではない。
そのままCropして使用しない。

---

## 4. Pixel基準

初期基準:

- Tile: 32x32 px
- Character footprint: 32x32 px
- Character visual height: 約40〜48 pxを目安
- 小型妖怪: 24〜40 px程度
- 大型妖怪: 64px以上も可

Vertical Sliceで実画面を確認後、最終固定する。

---

## 5. Texture設定

Godot:

- Texture Filter: Nearest
- Mipmaps: 原則OFF
- 自動アンチエイリアス: OFF
- Spriteの非整数倍率表示を避ける
- UIとゲーム世界でPixel密度を混在させない

---

## 6. キャラクター方向

最終目標:
8方向。

```text
down
down_left
left
up_left
up
up_right
right
down_right
```

Vertical Sliceでは4方向から開始してもよいが、
Referenceとコード構造は8方向拡張を妨げないこと。

---

## 7. 主人公アニメーション

必須:

```text
idle
walk
run
bug_net
crouch
surprised
item_hold
```

後期:

```text
bicycle
fishing
stone_skip
camera
sit
sleep
```

---

## 8. 祖母

必須:

- idle
- walk
- talk
- sit
- cooking
- farming
- carry_tray

派手なアニメより生活感を重視。

---

## 9. 河童

必須:

- idle
- walk
- swim
- surface
- dive
- eat_cucumber
- stone_skip
- surprised

水面から出る際も派手な魔法エフェクトは禁止。

---

## 10. 妖怪デザイン分類

### 親しみ系
河童、座敷童子、猫又、化け狸。

- 丸い形
- 読みやすい表情
- 子供と並んだ時に友達感が出る

### 不思議系
天狗、ぬらりひょん、唐傘、泥田坊。

- 少し不自然な比率
- 独特な動き
- 色や影に違和感

### 怪異系
ろくろ首、のっぺらぼう、磯女、海坊主。

- グロテスクにしない
- シルエットと動きで怖さを作る

---

## 11. 環境

背景は「観光地として美しい田舎」より、
**人が暮らしている田舎**を優先する。

必要要素:

- 電柱
- 電線
- ガードレール
- 用水路
- カーブミラー
- 郵便ポスト
- 洗濯物
- 自販機
- 石垣
- ブロック塀
- 軽トラ的な生活要素
- 草の侵食
- 古い看板

---

## 12. 祖母の家

重要モチーフ:

- 木造
- 瓦屋根
- 縁側
- 障子
- 畳
- ちゃぶ台
- 扇風機
- 風鈴
- 蚊取り線香
- 麦茶
- スイカ
- 仏壇
- 古いテレビ

「帰りたくなる場所」にする。

---

## 13. 川

必要タイル:

- 水面
- 浅瀬
- 深い水
- 川岸
- 草の川岸
- 石の川岸
- カーブ
- 岩
- 飛び石
- 橋
- 花
- 川草
- 水しぶき
- 波紋

河童イベント用に水面差分を持つ。

---

## 14. 時間帯の色

### 朝
- 少し淡い
- 朝露
- 柔らかい影

### 昼
- 強い青空
- 白い入道雲
- 強い日差し
- 濃い緑

### 夕方
最重要時間帯。

- オレンジ
- 長い影
- ヒグラシ
- 水面反射
- ノスタルジー

### 夜
- 青暗い
- 月
- 星
- 街灯
- ホタル
- 狐火

真っ暗にしすぎない。

---

## 15. 妖怪出現演出

禁止:

- 強いフラッシュ
- RPG的スポーン煙
- レア演出
- 大きな警告UI

推奨:

- 水面が揺れる
- 草が動く
- 虫の声が止まる
- 風鈴
- 影
- 一瞬だけ見える
- NPCの背後にいる

---

## 16. UI

世界観:
「主人公の夏休みノート」

日記UI:

- 紙
- テープ
- 鉛筆
- 写真
- スタンプ
- 落書き
- 手描き地図

HUDは最小限。

歩行可能Marker:

- 夏の光に馴染む淡い黄土色と濃色の1px影を使う
- 2〜4px程度の小さな足元記号を間隔を空けて配置する
- 常時表示するが、目的地矢印やクエストMarkerのように強く点滅させない
- 水面、田畑、家具、植栽など歩行不能な絵の上へ配置しない

---

## 17. ファイル命名

```text
chr_protagonist_walk_down.png
chr_grandma_idle.png
yokai_kappa_swim.png
tile_river_water_01.png
tile_river_bank_grass_01.png
prop_bug_net.png
ui_diary_page.png
vfx_water_ripple.png
```

---

## 18. アセット完成条件

- Referenceと世界観が一致
- Pixel密度が一致
- Nearest表示で崩れない
- 必要方向が揃っている
- 透過背景
- 不要な余白なし
- Godotで実サイズ確認済み
- アニメ時に体格が変形しない

---

## 19. 背景は移動マーカーを先に決める

新しいエリアは、背景画像より先に640x360 Greybox上で`WalkPathNetwork2D`を定義する。
出入口、Spawn、NPC生活地点、虫、必須Eventを経路へ接続し、常時表示Markerの並びをレイアウト契約として固定してから背景を制作する。

背景はMarker列を中心に連続した床・畳・土道・橋・乾いた川岸を描き、家具、水面、水田、畑、岩、柵、植栽を経路外へ置く。
Marker自体はゲーム側で描画するため、背景画像へ焼き込まない。詳細な手順、歩行幅、現行8エリアの座標は`docs/MAP_ART_WORKFLOW.md`を正とする。

背景差し替え後は、原寸Sourceだけで判断せず、640x360のMarker付き実画面で全経路を確認する。

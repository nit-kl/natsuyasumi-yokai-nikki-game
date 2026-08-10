# 夏休み妖怪日記

## Codex向け ゲーム開発計画・引き継ぎ仕様書

---

# 0. この文書の目的

本書は、ゲーム『夏休み妖怪日記』を GitHub / Git / Codex / Godot / Blender を中心として開発するためのマスター開発計画である。

Codexは実装前に本書を読み、以下を理解したうえで作業すること。

* ゲームのコンセプト
* 絶対に守るべきゲームデザイン
* 技術構成
* ディレクトリ構成
* システム境界
* データ構造
* 実装優先順位
* マイルストーン
* Issueの粒度
* テスト方針
* Definition of Done
* アセット制作フロー
* 禁止事項

ゲーム全体を一度に実装しない。

**必ず小さなVertical Sliceから開発し、遊んで面白いことを確認してから拡張する。**

---

# 1. プロジェクト概要

## タイトル

夏休み妖怪日記

英語仮題：

Natsuyasumi Yokai Nikki

---

# 2. ゲームコンセプト

田舎の祖母の家で過ごす約30日間の夏休み。

主人公には、普通の人には見えない妖怪が見える。

プレイヤーは、

* 虫取り
* 釣り
* 川遊び
* 自転車
* 写真撮影
* 秘密基地づくり
* 友達との交流
* 妖怪との交流
* 町の探索

などをしながら自由に夏休みを過ごす。

ゲームの目的は、

**妖怪を倒すことでも、図鑑をコンプリートすることでもない。**

プレイヤー自身が過ごした30日間を、

**「自分だけの夏休み妖怪日記」**

として残すことが最終的な成果となる。

---

# 3. 最重要ゲームデザイン原則

以下は実装都合で勝手に変更してはいけない。

## 3.1 妖怪は敵ではない

基本的に戦闘ゲームにはしない。

妖怪とは、

* 見つける
* 観察する
* 話す
* 遊ぶ
* 手伝う
* 仲良くなる

ことで関係を築く。

---

## 3.2 クエストマーカー中心にしない

一般的なRPGのような、

「！」
「目的地マーカー」
「討伐数」
「報酬」

を中心とした設計は禁止。

代わりに、

**「気になること」**

として自然な文章でヒントを残す。

例：

* 夜の学校からピアノが聞こえるらしい
* 河童が川上流を指差していた
* 昨日の雷のあと山に何か落ちたらしい

---

## 3.3 すべてを見ることを前提にしない

1周ですべての妖怪やイベントを見る必要はない。

プレイヤーによって、

「どんな夏だったか」

が違うことを価値とする。

---

## 3.4 何もしない時間もゲーム

以下のような非効率行動にも意味を持たせる。

* 縁側に座る
* 海を見る
* ラムネを飲む
* 昼寝する
* 扇風機に当たる
* 雨宿りする

効率だけを求めるゲームにしない。

---

## 3.5 妖怪は最初から世界に存在している

派手なスポーン演出は禁止。

妖怪は、

「出現した」

のではなく、

**「そこにいたことにプレイヤーが気付く」**

ように演出する。

---

# 4. ゲームの基本ループ

毎日の基本ループは以下。

```text
起床
 ↓
朝食・家族との会話
 ↓
天気・町の様子を知る
 ↓
自由行動開始
 ↓
探索 / 虫取り / 釣り / 人間との交流 / 妖怪との交流
 ↓
昼
 ↓
夕方
 ↓
帰宅する or 夜の町を探索
 ↓
祖母の家へ帰る
 ↓
夕食 / 風呂 / 家族との会話
 ↓
妖怪日記
 ↓
就寝
 ↓
翌日
```

ゲーム内1日は、おおよそ30〜45分を目標とする。

ただしプレイテスト結果を優先する。

---

# 5. 30日間の構成

## 第1章：1〜7日目

テーマ：

**田舎の夏休みと最初の怪異**

内容：

* 祖母の家
* 太一との出会い
* 虫取り
* 川遊び
* 河童の目撃
* 駄菓子屋
* ぬらりひょん
* 雨
* 唐傘お化け
* 秘密基地
* 化け狸
* 夜の神社
* 妖怪の存在を確信

---

## 第2章：8〜14日目

テーマ：

**妖怪のいる日常**

妖怪との交流が増える。

* 河童との遊び
* 座敷童子
* 猫又
* 天狗
* 山
* 海
* 廃駅
* 母親の日記
* お盆
* 件の予言

---

## 第3章：15〜21日目

テーマ：

**人間と妖怪の夏祭り**

8月15日を最大イベントとする。

昼は普通の夏祭り。

夜になると主人公にだけ、

「妖怪の祭り」

が見える。

世界滅亡イベントにはしない。

町と妖怪の歴史を知るイベントとする。

---

## 第4章：22〜30日目

テーマ：

**夏の終わり**

新しい妖怪を大量投入しない。

既に出会った人・妖怪との関係を中心にする。

28〜29日目は自由度を高くする。

30日目は帰宅イベント。

---

# 6. 技術構成

## ゲームエンジン

Godot 4.x

プロジェクト開始時に使用する具体バージョンを固定する。

全開発者・CI・Codex作業環境で同一バージョンを使用する。

---

## スクリプト

原則 GDScript。

理由：

* Godotとの統合が強い
* Codexによる修正が容易
* プロトタイピングが高速
* 小〜中規模ゲームとして十分

C#は明確な理由がない限り導入しない。

---

## 3D制作

Blender。

必要に応じてBlender MCPを利用。

---

## バージョン管理

Git + GitHub。

---

## AI開発

Codex。

主用途：

* GDScript実装
* リファクタリング
* テスト
* データ追加
* Scene構築補助
* Blender MCP操作
* デバッグ
* ドキュメント更新

---

# 7. Gitリポジトリ

推奨：

```text
natsuyasumi-yokai-nikki-game
```

---

# 8. Git運用

mainへの直接コミットは禁止。

基本：

```text
main
 ↓
feature/xxx
 ↓
Pull Request
 ↓
review
 ↓
main
```

ブランチ例：

```text
feature/game-clock
feature/day-night-cycle
feature/kappa-encounter
feature/diary-system
feature/fishing
fix/save-corruption
refactor/event-system
```

---

# 9. Issue単位で開発する

Codexに巨大な指示を与えない。

悪い例：

```text
ゲーム全部作って
```

良い例：

```text
Issue #15
GameClockを実装する。

Requirements:
- 現在日時を保持
- pause可能
- time_scale変更可能
- signal time_changed
- signal period_changed
- save/load対応
```

1 Issue = 1責務を基本とする。

---

# 10. 推奨ディレクトリ構成

```text
natsuyasumi-yokai-nikki-game/
│
├─ project.godot
├─ README.md
├─ LICENSE
│
├─ docs/
│  ├─ GAME_DESIGN.md
│  ├─ DEVELOPMENT_PLAN.md
│  ├─ ARCHITECTURE.md
│  ├─ ART_GUIDE.md
│  ├─ EVENT_GUIDE.md
│  ├─ SAVE_FORMAT.md
│  └─ TEST_PLAN.md
│
├─ scenes/
│  ├─ bootstrap/
│  ├─ player/
│  ├─ world/
│  │  ├─ grandma_house/
│  │  ├─ village/
│  │  ├─ river/
│  │  ├─ shrine/
│  │  ├─ school/
│  │  ├─ rice_fields/
│  │  ├─ secret_base/
│  │  ├─ abandoned_station/
│  │  ├─ tunnel/
│  │  ├─ mountain/
│  │  ├─ harbor/
│  │  └─ beach/
│  │
│  ├─ npc/
│  ├─ yokai/
│  ├─ minigames/
│  ├─ ui/
│  └─ debug/
│
├─ scripts/
│  ├─ core/
│  ├─ player/
│  ├─ world/
│  ├─ events/
│  ├─ npc/
│  ├─ yokai/
│  ├─ diary/
│  ├─ save/
│  ├─ minigames/
│  └─ ui/
│
├─ resources/
│  ├─ yokai/
│  ├─ npc/
│  ├─ events/
│  ├─ locations/
│  ├─ weather/
│  ├─ items/
│  ├─ insects/
│  └─ fish/
│
├─ assets/
│  ├─ models/
│  ├─ textures/
│  ├─ materials/
│  ├─ animations/
│  ├─ audio/
│  ├─ music/
│  ├─ ui/
│  └─ fonts/
│
├─ shaders/
├─ tests/
└─ tools/
```

---

# 11. Coreシステム

Autoload / Service層として以下を想定する。

```text
GameState
GameClock
CalendarManager
WeatherManager
WorldState
EventManager
NPCManager
YokaiManager
DiaryManager
SaveManager
AudioManager
SceneTransitionManager
```

巨大な `GameManager.gd` 1つにすべてを書くことは禁止。

---

# 12. GameState

ゲーム全体の進行状態を保持する。

責務：

* 現在日
* 現在時刻
* プレイヤー状態
* 現在エリア
* ゲーム進行フェーズ
* 各Managerへの参照

ゲームロジックそのものを大量に持たせない。

---

# 13. GameClock

責務：

* ゲーム内時刻
* 時間進行
* pause
* time scale
* 朝 / 昼 / 夕方 / 夜判定

例：

```text
05:00 朝
10:00 昼
16:30 夕方
19:00 夜
```

具体値はプレイテストで調整可能にする。

signal：

```text
time_changed
period_changed
day_ended
```

---

# 14. CalendarManager

責務：

* 日付
* 1〜30日目
* 特別日
* お盆
* 夏祭り
* 最終日

イベント条件から参照可能にする。

---

# 15. WeatherManager

初期実装：

```text
SUNNY
CLOUDY
RAIN
THUNDERSTORM
```

責務：

* 今日の天気
* 天気変更
* WorldEnvironment切替
* 雨エフェクト
* 環境音切替
* NPC行動への通知
* 妖怪出現条件への通知

将来的には、

* 台風
* 霧

などを追加可能にする。

---

# 16. 昼夜システム

同じマップを使用する。

変更対象：

* DirectionalLight
* WorldEnvironment
* Sky
* Fog
* NPC
* 妖怪
* 環境音
* 一部オブジェクト

昼マップと夜マップを完全に別管理しない。

---

# 17. WorldState

町全体の永続状態。

例：

```text
secret_base_unlocked
river_shortcut_unlocked
shrine_back_path_unlocked
abandoned_station_discovered
festival_completed
```

イベントスクリプトに直接大量のbooleanを散らさない。

---

# 18. プレイヤー

三人称視点。

基本操作：

* 歩く
* 走る
* ジャンプ
* しゃがむ
* 調べる
* 道具使用
* 自転車
* カメラ

---

# 19. プレイヤーにHPを持たせない

通常プレイでは、

* HP
* 攻撃力
* 防御力
* 経験値
* レベル

を使用しない。

スタミナゲージも初期実装では導入しない。

---

# 20. Interactionシステム

共通Interactableを作る。

対象：

* NPC
* 妖怪
* 虫
* 調査物
* 家具
* ドア
* アイテム
* 写真スポット

例：

```text
Interactable
├─ get_interaction_text()
├─ can_interact()
└─ interact()
```

個別システムを乱立させない。

---

# 21. NPCシステム

主要NPC：

* 祖母
* 太一
* 美鈴
* 悠斗
* 凛
* 駄菓子屋店主
* 漁師
* その他町民

NPCはスケジュールを持つ。

例：

```text
太一

晴れ
朝: 自宅
昼: 川
夕方: 秘密基地

雨
昼: 駄菓子屋

8月15日
夜: 神社
```

Resourceとして管理する。

---

# 22. NPC会話

会話はデータ駆動を基本とする。

条件：

* 日付
* 時間
* 天候
* 関係値
* イベント履歴
* 妖怪イベント
* 所持アイテム

などから会話を変化させる。

巨大な `if day == 3` をNPCスクリプトに大量記述しない。

---

# 23. 妖怪システム

妖怪には状態段階を持たせる。

基本：

```text
UNKNOWN
TRACE
SEEN
CONTACTED
FRIENDLY
CLOSE
```

日本語概念：

```text
未発見
気配
目撃
接触
交流
親しい
```

---

# 24. YokaiResource

妖怪をResourceとして定義する。

例：

```text
id
display_name
description
preferred_locations
available_weather
available_time_ranges
minimum_day
maximum_day
interaction_stage
favorite_items
event_chain
diary_entries
```

---

# 25. 初期主要妖怪

優先度A：

1. 河童
2. 座敷童子
3. 猫又
4. 化け狸
5. ぬらりひょん
6. 天狗
7. 山姥
8. 磯女
9. 件
10. 九尾

その他：

* 一つ目小僧
* 唐傘お化け
* 小豆洗い
* ろくろ首
* のっぺらぼう
* 火の玉
* 土蜘蛛
* 泥田坊
* 海坊主
* 船幽霊
* 雷獣
* ぬりかべ
* 砂かけ婆
* 大天狗
* 百々目鬼

---

# 26. 妖怪イベント設計

例：河童

```text
Stage 0
川に異変なし

Stage 1
水面に皿だけ見える

Stage 2
河童の姿を目撃

Stage 3
キュウリを置ける

Stage 4
会話可能

Stage 5
水切り勝負

Stage 6
秘密の滝へ案内
```

イベントを1シーンに直書きしない。

EventManagerから管理する。

---

# 27. EventManager

ゲームの最重要システムの1つ。

Eventには以下を持たせる。

```text
event_id
priority
conditions
location
start_time
end_time
weather
required_flags
forbidden_flags
one_shot
cooldown
actions
```

---

# 28. Event条件

最低限以下に対応する。

```text
日付
時間
時間帯
天候
場所
NPC状態
妖怪状態
WorldState
所持アイテム
過去イベント
```

---

# 29. Event Action

例：

```text
会話開始
NPC移動
妖怪出現
アイテム追加
WorldState変更
日記追加
時間進行
カットシーン開始
ミニゲーム開始
```

---

# 30. 「偶発的な一日」を作る

イベントは一本のクエストラインだけにしない。

例：

```text
豆腐を買う
 ↓
クワガタ発見
 ↓
農道へ寄り道
 ↓
化け狸
 ↓
夕立
 ↓
駄菓子屋へ雨宿り
 ↓
トンネルの噂
```

複数の小イベントが自然に連鎖する設計を目指す。

---

# 31. 日記システム

最重要システム。

1日ごとに `DayRecord` を保存する。

---

# 32. DayRecord

```text
date
weather
wake_time
sleep_time

visited_locations
met_npcs
met_yokai

caught_insects
caught_fish

photos
items_found

events_completed
events_seen

diary_fragments
special_memories
```

---

# 33. DiaryManager

責務：

* 日中の行動記録
* 日記候補生成
* 妖怪記録
* 写真リンク
* 最終アルバム生成

文章生成は完全生成AI依存にしない。

基本テンプレートをゲーム内データとして保持する。

---

# 34. 妖怪日記

図鑑形式にしない。

表示例：

```text
河童

川にいる。
キュウリが好きみたい。
水切りがものすごく上手い。

8月7日
滝の裏に連れていってくれた。
```

`13/25` のようなコンプリート率は基本表示しない。

---

# 35. 写真システム

ゲーム内カメラを実装する。

要件：

* 写真撮影
* 保存
* 撮影時刻
* 撮影場所
* 写っている主要対象情報
* 日記への追加

写真はセーブ容量に注意する。

必要ならサムネイルと元画像を分ける。

---

# 36. 妖怪と写真

妖怪ごとに写真挙動を変更可能にする。

例：

```text
河童
普通に写る

火の玉
光のみ

座敷童子
特殊イベントで写り込む

九尾
普通の狐に見える
```

後期フェーズで実装。

---

# 37. アイテム

カテゴリー：

```text
TOOLS
FOOD
FOUND_OBJECT
IMPORTANT
```

主な道具：

* 虫取り網
* 虫かご
* 釣竿
* カメラ
* 懐中電灯
* 水筒

---

# 38. お金

簡素な小遣いシステム。

用途：

* 駄菓子
* ラムネ
* アイス
* 花火
* 虫用品
* 釣り用品

経済ゲームにはしない。

---

# 39. 虫取り

Vertical Sliceで最初に作るミニゲーム。

基本：

```text
虫を発見
 ↓
ゆっくり接近
 ↓
網を振る
 ↓
ヒット判定
 ↓
捕獲
```

初期対象：

* カブトムシ
* セミ
* トンボ

---

# 40. 釣り

Phase 2。

基本：

```text
投げる
 ↓
待つ
 ↓
ヒット
 ↓
ラインテンション管理
 ↓
釣り上げ
```

複雑なシミュレーションにはしない。

---

# 41. 水切り

Phase 2。

パラメータ：

```text
投げる方向
角度
力
タイミング
```

河童との遊びにも再利用。

---

# 42. 妖怪ミニゲーム

予定：

```text
河童
水切り

化け狸
化け当て

一つ目小僧
かくれんぼ

天狗
山駆け

猫又
魚集め

座敷童子
だるまさんがころんだ
```

---

# 43. 秘密基地

Phase 2以降。

基本機能：

* 発見
* 掃除
* アイテム配置
* 装飾
* NPC集合
* 妖怪来訪

初期は自由建築にしすぎない。

スナップポイント方式でもよい。

---

# 44. 自転車

重要な移動システム。

優先事項：

* 操作の気持ちよさ
* 田舎道を走る感覚
* 坂道
* 砂利
* ブレーキ
* 降車 / 乗車

高精度な自転車物理シミュレーションは不要。

---

# 45. マップ構成

完全な巨大オープンワールドにはしない。

エリア制＋シームレス感を狙う。

主要エリア：

```text
祖母の家
集落
駄菓子屋
神社
小学校
田んぼ
川
秘密基地
廃駅
古いトンネル
裏山
漁港
海岸
```

---

# 46. エリア制作順

1. 祖母の家
2. 家周辺
3. 川
4. 神社
5. 駄菓子屋
6. 田んぼ
7. 秘密基地
8. 小学校
9. 廃駅
10. トンネル
11. 山
12. 漁港
13. 海岸

---

# 47. ファストトラベル

初期実装ではなし。

自転車を高速移動手段とする。

後半に必要ならバス等を検討する。

---

# 48. UI基本方針

HUDを最小化する。

常時表示候補：

* 日付
* おおまかな時間帯
* 天候
* Interaction表示

表示しない：

* HP
* EXP
* ミニマップ
* クエスト一覧
* 敵レベル

---

# 49. 地図

主人公の手描き地図。

新しい場所を発見すると描き足される。

妖怪情報も、

```text
変な声がした
夜に光る
```

のようなメモとして表示する。

---

# 50. 「気になること」

クエストログの代替。

例：

```text
・夜の学校からピアノが聞こえるらしい
・河童が川上流を指していた
・昨日の雷で山に何か落ちたらしい
```

報酬表示や完了率は不要。

---

# 51. セーブシステム

最初期から実装する。

保存対象：

```text
version
day
time
weather

player_position
current_scene

inventory
money

world_flags

npc_states
yokai_states

event_history

secret_base_state

day_records

photos
```

---

# 52. Save Version

必ずバージョンを持たせる。

例：

```text
save_version: 1
```

将来のMigrationに備える。

---

# 53. オートセーブ

候補：

* 起床
* 帰宅
* 日記終了
* 大イベント終了

プレイヤー行動中に頻繁なディスク書き込みをしない。

---

# 54. Audio

このゲームでは音を非常に重要視する。

環境音：

朝：

* 鳥
* 食器
* ラジオ

昼：

* セミ
* 川
* 風

夕方：

* ヒグラシ
* 遠くのチャイム

夜：

* 鈴虫
* カエル
* 犬
* 風

---

# 55. 妖怪検知演出

UIアイコンを出さない。

代わりに、

* 虫の声が止まる
* 風鈴が鳴る
* 水面が揺れる
* 猫が一点を見る
* 画面端に影
* 環境音変化

などを使う。

---

# 56. アート方向

基本：

**懐かしい日本の夏 + 少し不思議な妖怪**

3Dアニメ調。

人間：

自然なアニメ頭身。

背景：

ややリアル。

妖怪：

少しデフォルメ。

---

# 57. 昼の演出

* 強い日差し
* 青空
* 入道雲
* 濃い緑
* 陽炎
* 強い木陰

---

# 58. 夕方

ゲームでもっとも美しい時間帯。

* オレンジ
* 長い影
* ヒグラシ
* 水面反射

日常と妖怪世界の境界。

---

# 59. 夜

完全な暗闇にはしない。

* 月
* 星
* 街灯
* 自販機
* 民家
* ホタル
* 狐火

怖さより、

**歩いてみたくなる夜**

を目標とする。

---

# 60. 妖怪祭り

8月15日。

ゲーム最大のビジュアルイベント。

普段の神社を再利用し、

* 提灯
* 狐火
* 妖怪屋台
* 天狗
* 河童
* 百鬼夜行
* 巨大な妖怪の影

などを追加。

完全別マップにしない。

---

# 61. Blender制作方針

最初から町全体を作らない。

Vertical Sliceで必要なものだけ制作する。

最初に必要：

```text
祖母の家
庭
農道
川
橋
木
草
電柱
ガードレール
主人公
祖母
河童
虫
```

---

# 62. Blender → Godotルール

原則 glTF / GLB。

統一事項を `ART_GUIDE.md` に記載する。

最低限：

* Scale
* Up Axis
* Origin
* Naming
* Collision
* LOD
* Material
* Texture Resolution

を固定する。

---

# 63. アセット命名

例：

```text
env_river_bridge_01.glb
env_utility_pole_01.glb
prop_ramune_bottle_01.glb
char_kappa_01.glb
char_grandma_01.glb
```

命名規則を途中で変えない。

---

# 64. 開発の最重要戦略

30日分を最初から作らない。

まず、

# 「1日版 Vertical Slice」

を完成させる。

---

# 65. Vertical Slice内容

1日のみ。

## 朝

祖母の家で起床。

祖母と短い会話。

外へ出る。

---

## 昼

川まで自由移動。

途中で虫を捕れる。

---

## 川

河童の気配。

最終的に一瞬目撃。

---

## 夕方

空とライティングが変化。

帰宅。

---

## 夜

祖母の家。

日記を書く。

---

## 終了

1日の記録を表示。

---

# 66. Vertical Slice必須システム

以下のみ先に作る。

```text
Player movement
Third-person camera
Interaction
GameClock
Day/night lighting
Grandma NPC
Dialogue
River area
Bug catching
Kappa encounter
EventManager minimal
Diary
DayRecord
Save/Load minimal
Audio environment
Scene transition
```

---

# 67. Vertical Sliceでは作らないもの

以下は後回し。

```text
30日分イベント
妖怪25体
釣り
秘密基地
自転車
海
山
夏祭り
NPC大量追加
高度な写真システム
大量のUI
実績
Steam連携
```

---

# 68. Vertical Slice成功条件

プレイ後に以下へYESと言えること。

### A

田舎を歩いているだけで少し楽しい。

### B

川へ行きたくなる。

### C

虫取りが最低限気持ちいい。

### D

河童を見つけた時にワクワクする。

### E

夕方になると帰りたくなる。

### F

日記を見ることで1日に意味が生まれる。

この6項目が成立しなければPhase 2へ進まない。

---

# 69. Milestone 0

## Foundation

目的：

プロジェクト基盤。

Issue例：

```text
#001 Initialize Godot project
#002 Create repository structure
#003 Add coding conventions
#004 Add GameState
#005 Add GameClock
#006 Add save skeleton
#007 Add debug overlay
#008 Setup automated validation
```

---

# 70. Milestone 1

# Vertical Slice

Issue例：

```text
#010 Third-person controller
#011 Camera controller
#012 Interaction system
#013 Grandma house scene
#014 Grandma NPC
#015 Dialogue system
#016 River scene
#017 Day/night lighting
#018 Basic weather hooks
#019 Bug entity
#020 Bug catching mechanic
#021 Minimal EventManager
#022 Kappa state data
#023 First Kappa encounter
#024 Return-home flow
#025 DayRecord
#026 Diary UI
#027 Save/load integration
#028 Environment audio
#029 Vertical Slice polish
#030 Vertical Slice playtest
```

---

# 71. Milestone 2

# First 7 Days

追加：

```text
Shrine
Candy store
Rice fields
Secret base
Taichi
Misuzu
Yuto
Nurarihyon
Karakasa
Bakedanuki
Zashiki-warashi
Rain
Night exploration
```

---

# 72. Milestone 3

# Core Summer Systems

追加：

```text
Fishing
Stone skipping
Bicycle
Photography
Inventory
Allowance
Candy store economy
NPC scheduling
Yokai scheduling
Rumors
Expanded diary
```

---

# 73. Milestone 4

# Days 8–15

追加：

```text
Mountain
Harbor
Beach
Abandoned station
Tunnel

Nekomata
Tengu
Yamauba
Iso-onna
Kudan

Mother's diary
Obon events
Festival preparation
```

---

# 74. Milestone 5

# August 15 Festival

重点実装。

必要：

```text
Festival version of shrine
Human festival NPC crowd
Yokai festival overlay
Lantern lighting
Festival music
Special dialogue
Cutscene
Festival diary
```

---

# 75. Milestone 6

# Days 16–30

追加：

* 後半イベント
* 妖怪との別れ
* 友人イベント
* 祖母イベント
* 荷造り
* 最終自由日
* バス停
* エンディング

---

# 76. Milestone 7

# Content Expansion

妖怪25体まで拡張。

虫・魚追加。

NPC会話追加。

サブイベント追加。

---

# 77. Milestone 8

# Polish

重点：

* Animation
* Lighting
* Audio
* VFX
* Camera
* UI
* Loading
* Performance
* Bugs
* Accessibility

---

# 78. Milestone 9

# Release Preparation

対象：

* Windows Build
* Steam integration
* Controller
* Resolution
* Save validation
* Crash testing
* Credits
* Legal
* Privacy
* Store assets
* Trailer build

---

# 79. Coding Rules

Codexは以下を守る。

### Rule 1

1ファイルを巨大化させない。

### Rule 2

Managerを万能化しない。

### Rule 3

イベント固有ロジックをCoreへ入れない。

### Rule 4

Magic Numberを避ける。

### Rule 5

設定可能な値はResource化を検討。

### Rule 6

Scene固有のNodePathを大量にハードコードしない。

### Rule 7

Signalを適切に使う。

### Rule 8

循環依存を避ける。

---

# 80. CodexがIssueを開始するとき

必ず以下を確認する。

1. 関連仕様
2. 既存実装
3. 影響範囲
4. 保存データへの影響
5. テスト方法

---

# 81. Codex作業単位

Issue実装時には、

```text
1. Existing code inspection
2. Implementation plan
3. Minimal implementation
4. Tests / validation
5. Manual test instructions
6. Documentation update
7. Commit
```

の順で進める。

---

# 82. Definition of Done

Issue完了条件：

* Requirementを満たす
* エラーがない
* 既存機能を壊していない
* テスト済み
* Debug print残存なし
* コメントアウトコードなし
* 不要ファイルなし
* ドキュメント更新済み
* PR説明あり

---

# 83. テスト方針

最低限、

### Unit

データ・条件判定。

### Integration

Manager間連携。

### Manual

実際のゲームフィール。

を使い分ける。

このゲームではManual Playtestを特に重視する。

---

# 84. 必須自動テスト候補

```text
GameClock rollover
Calendar day progression
Event condition matching
Yokai state progression
Save serialization
Save deserialization
DayRecord creation
NPC schedule lookup
Weather condition lookup
```

---

# 85. Debug Tools

開発初期からDebug Menuを用意する。

機能：

```text
Set Day
Set Time
Set Weather
Teleport
Set Yokai Stage
Trigger Event
Give Item
Set Money
Show Event Candidates
Save
Load
Reset
```

本番Buildでは無効化。

これがないと30日ゲームのテストコストが非常に高くなる。

---

# 86. Performance目標

ターゲットをまずWindows PCとする。

初期目標：

**60 FPSを基準**

低〜中スペックでも遊べる設計を意識。

最適化対象：

* 草
* 木
* Shadow
* NPC
* Animation
* Draw Call
* Particle
* Texture
* LOD

---

# 87. エリアストリーミング

最初から複雑なStreamingを作らない。

Vertical Sliceでは単純なScene構成。

町が拡大して問題が出た段階で、

* Chunk
* Visibility
* Background loading

を導入する。

---

# 88. アクセシビリティ

後回しにしすぎない。

最低限検討：

* 字幕
* テキスト速度
* カメラ感度
* Y軸反転
* モーションブラーON/OFF
* 色だけに依存しない情報
* ボタン再割当
* 音量個別設定

---

# 89. やってはいけない開発

## 禁止1

最初に夕凪町全体を作る。

## 禁止2

妖怪25体を先に作る。

## 禁止3

ストーリーイベントを大量実装してから操作感を確認する。

## 禁止4

巨大なGameManagerを作る。

## 禁止5

イベントをコードへ直書きし続ける。

## 禁止6

すべての遊びを同時開発する。

## 禁止7

グラフィック完成を優先してゲームループを後回しにする。

---

# 90. 最初の開発ゴール

最優先は、

# 「河童と出会う1日」

を完成させることである。

完成イメージ：

```text
夏の朝
祖母の家を出る

↓

セミの声を聞きながら田舎道を歩く

↓

途中でカブトムシを捕る

↓

川へ到着

↓

水面に違和感

↓

河童を一瞬目撃

↓

夕方になる

↓

家へ帰る

↓

祖母と夕食

↓

その日の出来事が日記になる
```

この15〜30分程度の体験を、

**「もっとこの町で過ごしたい」**

と思える品質まで高める。

---

# 91. Vertical Slice完成後のレビュー

以下を10点満点で評価する。

```text
移動の楽しさ
町の雰囲気
夏らしさ
音
探索
虫取り
妖怪発見
河童の魅力
夕方の演出
日記の満足感
```

平均7点未満なら30日コンテンツ制作へ進まず改善する。

---

# 92. 最優先品質項目

このゲームでは以下の順で品質を優先する。

```text
1. 世界を歩く気持ちよさ
2. 夏の空気感
3. 妖怪を発見するワクワク
4. 日常イベント
5. 妖怪との交流
6. 日記
7. ストーリー
8. コンテンツ量
9. グラフィックの豪華さ
```

「コンテンツ量」で面白さをごまかさない。

---

# 93. 最終的なプレイヤー体験

プレイヤーに、

「ゲームをクリアした」

ではなく、

**「あの町で夏休みを過ごした」**

と思ってもらう。

30日後に、

河童と遊んだこと。

友達と秘密基地を作ったこと。

夜の神社が怖かったこと。

祖母の家の縁側。

夕方の田んぼ。

夏祭り。

そうした出来事が、

プレイヤー自身の思い出として残る作品にする。

---

# 94. Codexへの最初の指示

リポジトリ作成後、まず以下を実施すること。

```text
1. 本仕様書を docs/DEVELOPMENT_PLAN.md として保存
2. GAME_DESIGN.mdを作成
3. ARCHITECTURE.mdを作成
4. Godotプロジェクト初期化
5. 推奨ディレクトリを作成
6. README.md作成
7. Git ignore設定
8. GameStateの骨格作成
9. GameClockの骨格作成
10. Debug Menuの骨格作成
11. Vertical Slice用IssueをGitHubに登録
```

その後、

**Milestone 1「河童と出会う1日」**

の完成を最初の開発目標とする。

---

# 95. 開発判断の基準

迷った場合は必ず、

> これは「夏休みを過ごしている感覚」を強くするか？

で判断する。

YESなら検討。

NOなら、機能追加を見送る。

---

# PROJECT VISION

## 夏休み妖怪日記

**あの夏、ぼくにだけ、妖怪が見えた。**

妖怪を集めるゲームではない。

妖怪のいる町で、

30日間の夏休みを過ごすゲームである。

そして最後に残るのは、

攻略率でも、

レベルでも、

レアアイテムでもない。

**プレイヤー自身が過ごした、ひと夏の思い出である。**

# 夏休み妖怪日記 — EVENT_GUIDE

## 1. 目的

本書は日付・天気・場所・NPC・妖怪の条件に基づくイベントを、
一貫した方法で実装するための規約を定義する。

---

## 2. イベントの原則

- Sceneに日付条件を大量直書きしない
- EventResourceとして管理する
- 条件と結果を分離する
- イベント固有ロジックをCoreへ入れない
- 1イベントは可能な限り小さくする
- イベント同士を連鎖させて「予定外の一日」を作る

---

## 3. EventResource概念

```yaml
id: kappa_first_sighting
priority: 100

conditions:
  min_day: 3
  max_day: 30
  locations:
    - river
  time_periods:
    - daytime
    - evening
  weather:
    - sunny
    - cloudy
  required_flags: []
  forbidden_flags:
    - kappa_first_sighting_complete

actions:
  - type: spawn_entity
    entity_id: kappa
    spawn_point: kappa_surface_point

  - type: play_animation
    target: kappa
    animation: surface

  - type: set_yokai_stage
    yokai_id: kappa
    stage: SEEN

  - type: add_diary_fragment
    fragment_id: strange_thing_in_river

  - type: set_flag
    flag: kappa_first_sighting_complete

one_shot: true
```

Godot Resource実装時も同等の概念を保持する。

---

## 4. Condition

最低限対応:

- day
- min_day
- max_day
- time
- time range
- time period
- weather
- location
- required flags
- forbidden flags
- NPC state
- Yokai state
- inventory
- event history
- random chance

Randomは乱用しない。

---

## 5. Action

最低限対応:

- start_dialogue
- spawn_entity
- hide_entity
- move_entity
- play_animation
- play_audio
- start_minigame
- add_item
- remove_item
- add_money
- set_flag
- clear_flag
- set_yokai_stage
- set_npc_state
- add_diary_fragment
- advance_time
- change_scene
- start_cutscene

---

## 6. Priority

同時に複数Eventが成立した場合に使用する。

例:

```text
200 Main story critical
150 Major character event
100 Yokai encounter
50 Ambient event
10 Cosmetic event
```

Priorityだけでなく、排他グループも使用する。

---

## 7. Exclusive Group

例:

```text
river_major_event
home_evening_event
shrine_night_event
```

同一タイミングで大イベントが重複しないために使用する。

---

## 8. Yokai state

標準:

```text
UNKNOWN
TRACE
SEEN
CONTACTED
FRIENDLY
CLOSE
```

状態を飛ばさないことを原則とする。

---

## 9. 河童イベントチェーン

### KAPPA_01_TRACE
条件:
- Day >= 2
- 川
- 昼

結果:
- 水面に波紋
- 主人公の短いリアクション
- Stage = TRACE

### KAPPA_02_SEEN
条件:
- Stage TRACE
- Day >= 3

結果:
- 皿だけ見える
- 一瞬姿を確認
- Stage = SEEN

### KAPPA_03_CUCUMBER
条件:
- Stage SEEN
- キュウリ所持

結果:
- キュウリを置ける
- 後日変化

### KAPPA_04_CONTACT
結果:
- 初会話
- Stage CONTACTED

### KAPPA_05_STONE_SKIP
結果:
- 水切りミニゲーム
- Stage FRIENDLY

### KAPPA_06_SECRET_WATERFALL
結果:
- 新エリア/ショートカット
- Stage CLOSE

---

## 10. Ambient Event

大きな意味を持たない小イベント。

例:

- 猫が道を横切る
- 風鈴が鳴る
- セミが飛ぶ
- NPCが遠くで話している
- 洗濯物を取り込んでいる
- 妖怪の影だけ見える

Ambient Eventは世界の生活感を作るため重要。

---

## 11. 偶発連鎖

例:

```text
祖母から豆腐のおつかい
↓
農道で珍しい虫
↓
追いかけて脇道
↓
化け狸
↓
夕立
↓
駄菓子屋に雨宿り
↓
トンネルの噂を聞く
```

すべてを1つの長大クエストとして定義しない。
小イベント同士が条件で自然につながる形にする。

---

## 12. 「気になること」

Eventから日記へヒントを追加できる。

例:

```text
rumor_school_piano
rumor_mountain_lightning
rumor_rain_station
```

完了マークや報酬表示は不要。

---

## 13. Event ID命名

```text
kappa_first_trace
kappa_first_sighting
grandma_first_errand
taichi_bug_hunt
shrine_night_week1
festival_yokai_gate
```

Saveに保存するためID変更は慎重に行う。

---

## 14. Event debug

DebugMenuから:

- Candidate Event一覧
- 条件成立/不成立理由
- 強制Trigger
- Event history確認

ができること。

30日ゲームでは必須。

# 夏休み妖怪日記 — SAVE_FORMAT

## 1. 方針

Saveはゲームオブジェクトそのものではなく、
IDと状態値を保存する。

Save形式には必ずVersionを持たせる。

---

## 2. 初期形式

```json
{
  "save_version": 1,
  "meta": {
    "play_time_seconds": 0,
    "last_saved_at": ""
  },
  "calendar": {
    "day_index": 1,
    "time_minutes": 420
  },
  "weather": "sunny",
  "player": {
    "scene_id": "grandma_house",
    "position": [128, 192],
    "facing": "down"
  },
  "inventory": {
    "items": {},
    "money": 0
  },
  "world": {
    "flags": [],
    "discovered_locations": []
  },
  "npc_states": {},
  "yokai_states": {},
  "event_history": [],
  "diary": {
    "days": []
  },
  "settings_snapshot": {}
}
```

---

## 3. Time

`time_minutes` は0〜1439。

例:

```text
420 = 07:00
720 = 12:00
1020 = 17:00
```

---

## 4. Player

保存:

- scene_id
- position
- facing
- 必要なら現在道具

原則として移動速度などの設定値は保存しない。

Vertical Sliceの安定`scene_id`:

```text
bedroom
grandma_house
home_outdoor        # 既存Save互換用
engawa_yard
paddy_road
irrigation_shade
river_entrance
river
```

エリア細分化後も`save_version = 1`を維持する。既存`grandma_house`、`home_outdoor`、`river`は
Catalogから削除せず、旧Saveを引き続き復元できる。

---

## 5. Inventory

例:

```json
{
  "items": {
    "bug_net": 1,
    "cucumber": 2,
    "kabutomushi": 1
  },
  "money": 300
}
```

Item IDは後から変更しない。

---

## 6. World flags

ArrayまたはDictionaryを使用。

例:

```text
secret_base_unlocked
river_shortcut_unlocked
kappa_first_sighting_complete
```

Flag命名はsnake_case。

---

## 7. NPC states

例:

```json
{
  "taichi": {
    "relationship": 2,
    "state": "normal"
  }
}
```

必要な値だけ保存する。

---

## 8. Yokai states

例:

```json
{
  "kappa": {
    "stage": "SEEN",
    "relationship": 1,
    "last_event_id": "kappa_first_sighting"
  }
}
```

---

## 9. Event history

One-shot判定等に使用。

例:

```json
[
  "intro_arrival",
  "grandma_first_breakfast",
  "kappa_first_trace",
  "kappa_first_sighting"
]
```

---

## 10. DayRecord

```json
{
  "day_index": 3,
  "weather": "sunny",
  "wake_time": 420,
  "sleep_time": 1260,
  "visited_locations": [
    "grandma_house",
    "river"
  ],
  "met_npcs": [
    "grandma"
  ],
  "met_yokai": [
    "kappa"
  ],
  "caught_insects": [
    "kabutomushi"
  ],
  "caught_fish": [],
  "events_seen": [
    "kappa_first_sighting"
  ],
  "diary_fragments": [
    "strange_thing_in_river"
  ],
  "photos": []
}
```

---

## 11. Save Version

初期:

```text
save_version = 1
```

形式を破壊的に変更する場合:

```text
v1 -> v2 migration
```

を実装する。

旧Saveを黙って壊さない。

---

## 12. Autosave

推奨:

- 起床後
- 帰宅後
- 日記終了後
- 大イベント終了後

移動中に毎秒保存しない。

---

## 13. Manual Save

初期版では必須ではない。
必要なら日記帳や就寝時に自然に統合する。

---

## 14. Save Slot

Vertical Slice:
1スロットでよい。

製品版:
複数スロットを検討。

---

## 15. Photo Data

写真本体をSave JSONへ埋め込まない。

保存:

```text
photo_id
file_path
date
time
location
subjects
```

画像ファイルを別管理する。

---

## 16. Corruption

Save読込時:

1. JSON parse確認
2. version確認
3. 必須Field確認
4. Backup確認
5. 失敗時はエラー画面

破損Saveを上書きしない。

---

## 17. Backup

Autosave時に前回データをBackupしてから置換する方式を推奨。

---

## 18. Tests

必須:

- Save → Load round trip
- Event history保持
- Yokai state保持
- DayRecord保持
- Unknown field tolerance
- Version mismatch
- Corrupted JSON
- Missing optional field

---

## 19. Milestone 0 実装範囲

`SaveManager`はv1全体の既定Dictionaryを生成するが、現時点でゲーム状態へ
復元する対象は`calendar.day_index`、`calendar.time_minutes`、Playerの
`scene_id`と`position`のみとする。未実装システムの項目は空の既定値を保持する。

読込時はJSON object、`save_version`、必須calendar field、値域を検証する。
未知fieldは将来拡張のため許容し、非対応versionと破損データは状態へ適用しない。
Backup / migration / atomic replacementはSaveManager拡張Issueで実装する。

---

## 20. Vertical Slice State Integration

Save v1の既存fieldへ以下を接続する。

- `world.flags` / `world.discovered_locations`: WorldState
- `yokai_states`: YokaiManager
- `event_history`: EventManagerのone-shot履歴
- `diary.days`: DiaryManagerのDayRecord
- `player.facing`: Playerの8方向facing
- `weather`: WeatherManagerの当日天気（`sunny` / `cloudy` / `rain` / `thunderstorm`）
- `inventory.items` / `inventory.money`: InventoryManagerの所持と所持金
- `npc_states`: `NpcStateBook` の NPC 状態（`{ "grandma": { "state": "cooking" } }`）

`weather` は既存のSave v1 fieldであり、`save_version` は変更しない。
欠落時は `sunny` を既定復元する。未知の天気IDは `sunny` へsanitizeする。
当日の `DayRecord.weather` はWeatherManagerと同期する。

`inventory` も既存のSave v1 fieldであり、`save_version` は変更しない。
欠落時は初期所持（`bug_net` x1、所持金 0）へ戻す。
明示された空の `{items: {}, money: 0}` はそのまま空として復元する。
Item IDは後から変更しない。

`npc_states` も既存のSave v1 fieldであり、`save_version` は変更しない。
欠落時は空として復元し、未設定NPCは `normal` とする。
`state` 以外の将来値（relationship等）は保持せず、Event条件は `state` だけを見る。

未知field許容とmissing optional fieldの既定値復元は維持する。
Schema fieldとsave_versionは変更しない。

Vertical Slice実ゲームのLoadでは`player.scene_id`を`LocationCatalog`で検証し、
現在地と異なる場合は対応Sceneへ遷移してからposition / facingを適用する。
未知のscene IDは黙って現在Sceneへ適用しない。
`validate_data()`の段階でCatalog未登録の`player.scene_id`を拒否する。

Issue #041の`world.flags.vertical_slice_complete`はVertical Slice一日通しのopt-in終端に使う。
本編のDay 2以降進行ではこのflagを必須条件にしない。Schema fieldとsave_versionは変更しない。
Day 30のReview完了は既存の`vertical_slice_final_day_reviewed` flagで記録する。

---

## 21. Stroll Path Position Compatibility

散歩道ベース移動後もSave v1の`player.position`を維持する。
保存時のPlayerは散歩道上にいるため、従来どおりWorld座標を記録する。
旧Saveまたは手動編集Saveから散歩道外の座標を読み込んだ場合は、Scene読込後に最寄り散歩道へ投影して復元する。
`scene_id`、`position`、`facing`のfieldと`save_version = 1`は変更しない。

# Save Format

セーブデータはGodotの `user://save_01.json` にUTF-8 JSONとして保存する。ルートには必ず `save_version` を持たせ、現在のバージョンは `1` とする。

```json
{
  "save_version": 1,
  "game_state": {},
  "game_clock": {},
  "bug_catching": {},
  "event_history": {},
  "day_records": [],
  "diary_entries": []
}
```

## 保存対象

- 現在日、エリア、進行フェーズ、Player状態
- 現在時刻、時間倍率、一時停止状態
- 種類別の虫捕獲数
- イベント発生回数
- 確定済みDayRecord
- 確定済みDiaryEntry

## 運用規則

- 未来バージョンのデータは読み込まない。
- JSONオブジェクトでないデータやバージョンのないデータは復元しない。
- 日記確定時にオートセーブする。
- Playerの通常行動中に毎フレーム保存しない。
- フォーマット変更時は `save_version` とMigration処理を追加する。

# アーキテクチャ

## 方針

Godot 4.7.1とGDScriptを使用する。シーンは表示と局所的な振る舞い、Autoloadはゲーム全体の状態・サービス、Resourceはコンテンツデータを担当する。単一の巨大な `GameManager` は作らない。

## レイヤー

| レイヤー | 主な配置 | 責務 |
| --- | --- | --- |
| Bootstrap | `scenes/bootstrap/` | 起動、サービス間の最小限の接続、最初のシーン遷移 |
| Scene | `scenes/` | ワールド、キャラクター、UIの構成と局所的挙動 |
| Service | `scripts/core/` | 時刻、進行状態、保存、イベントなどの横断機能 |
| Feature | `scripts/{feature}/` | プレイヤー、NPC、妖怪、日記などの機能ロジック |
| Data | `resources/` | 妖怪、NPC、イベント、場所、アイテム等のResource |
| Asset | `assets/`, `shaders/` | モデル、画像、音声、マテリアル、シェーダー |

依存は原則として Scene → Service / Feature → Data の方向とする。サービス同士を直接密結合させず、signalまたはBootstrapで協調させる。

## 初期Autoload

### GameState

ゲーム全体の軽量な進行状態を保持する。

- 現在日（1〜30日）
- 現在エリア
- 進行フェーズ
- プレイヤー状態
- 新規ゲームへのリセット
- 保存用Dictionaryへの変換と復元の境界

具体的な時刻進行やイベント判定などのゲームロジックは持たない。

### GameClock

1日の時刻進行のみを担当する。

- 分単位の現在時刻
- 一時停止と時間倍率
- 朝・昼・夕方・夜の判定
- `time_changed`、`period_changed`、`day_ended` signal

日付の更新は `day_ended` をBootstrapが受け、GameStateへ伝える。これによりClockはCalendarや保存形式へ依存しない。

## 今後追加するサービス

CalendarManager、WeatherManager、WorldState、EventManager、NPCManager、YokaiManager、DiaryManager、SaveManager、AudioManager、SceneTransitionManagerを、必要になったIssue単位で追加する。未実装の抽象化を先回りして作らない。

## データ駆動

イベント、NPCスケジュール、妖怪の出現条件、会話、アイテムはResourceとして定義する。シーンやNPCスクリプトに日付判定・大量のフラグ・会話本文を直書きしない。

イベントデータは少なくともID、優先度、場所、時間帯、天気、必要/禁止フラグ、単発設定、アクションを表現できる構造を目指す。保存データには必ず `save_version` を持たせる。

## Debug Menu

`scenes/debug/` と `scripts/debug/` に置き、デバッグビルドでのみ有効にする。初期骨格はF3で開閉でき、日付、時刻、一時停止、時間倍率を操作する。天気、テレポート、妖怪段階、イベント、アイテム、保存などは対応するサービスの実装時に拡張する。

## テスト境界

- Unit：時間帯判定、日付繰り越し、条件判定、シリアライズ。
- Integration：Autoload間のsignal接続、シーン遷移、保存復元。
- Manual：移動感、環境音、ライティング、虫取り、河童との遭遇、日記の満足感。

Vertical Sliceでは自動検証に加え、実機での手動プレイテストをDefinition of Doneに含める。


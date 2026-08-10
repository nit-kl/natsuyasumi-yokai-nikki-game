# 夏休み妖怪日記

田舎の祖母の家で過ごす約30日間の夏休みを描く、Godot製の3Dアドベンチャーゲームです。妖怪を倒したり図鑑を埋めたりすることではなく、プレイヤー自身の体験を「自分だけの夏休み妖怪日記」として残すことを目指します。

現在は、河童との出会いを含む「1日版 Vertical Slice」のための基盤を開発しています。

## 必要環境

- Godot 4.7.1 stable
- Git
- 3Dアセットを編集する場合は Blender

## 起動方法

1. Godot Project Managerで、このディレクトリの `project.godot` をImportします。
2. エディタ右上の「プロジェクトを実行」または `F6` / `F5` で起動します。
3. デバッグ実行中に `F3` を押すとDebug Menuを開閉できます。

コマンドラインでは、Godot実行ファイルにパスが通っている場合、次でも起動できます。

```powershell
godot --path .
```

## 開発方針

- まず「河童と出会う1日」を15〜20分で遊べるVertical Sliceとして完成させます。
- 巨大なGameManagerは作らず、状態と機能を小さなサービスへ分離します。
- イベントや妖怪などのコンテンツは、可能な限りResourceによるデータ駆動にします。
- 本編30日分や大量のコンテンツは、Vertical Sliceの面白さを検証してから拡張します。

詳細は [開発計画](docs/DEVELOPMENT_PLAN.md)、[ゲームデザイン](docs/GAME_DESIGN.md)、[アーキテクチャ](docs/ARCHITECTURE.md) を参照してください。

## ディレクトリ概要

```text
assets/      素材（モデル、テクスチャ、音声など）
docs/        仕様・設計文書
resources/   データ駆動用Godot Resource
scenes/      Godotシーン
scripts/     GDScript
shaders/     シェーダー
tests/       自動・手動テスト
tools/       開発補助ツール
```


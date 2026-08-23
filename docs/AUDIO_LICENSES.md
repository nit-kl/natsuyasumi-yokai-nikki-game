# 夏休み妖怪日記 — AUDIO LICENSES

本作へ同梱する外部音声素材と加工内容を記録する。
音声ファイルのライセンスは、それぞれの原音に記載された条件へ従う。

## Vertical Slice Production Audio

### `amb_home_outdoor_daytime.ogg`

- 原音: [Aburazemi 07z7315.ogg](https://commons.wikimedia.org/wiki/File:Aburazemi_07z7315.ogg)
- 作者・帰属: Cory / ISAKA Yoji
- ライセンス: [CC BY 2.1 JP](https://creativecommons.org/licenses/by/2.1/jp/)
- 加工: 10–40秒を使用、2秒crossfade loop、high-pass / low-pass、音量正規化、Ogg Vorbis再圧縮

### `amb_home_outdoor_evening.ogg`

- 原音: [Tanna japonensis v01.ogg](https://commons.wikimedia.org/wiki/File:Tanna_japonensis_v01.ogg)
- 作者・帰属: Σ64
- ライセンス: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
- 加工: 12–42秒を使用、2秒crossfade loop、high-pass / low-pass、音量正規化、Ogg Vorbis再圧縮

### `amb_river_flow.ogg`

- 原音: [Brook sound.ogg](https://commons.wikimedia.org/wiki/File:Brook_sound.ogg)
- 作者・帰属: TwoWings
- ライセンス: [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/)
- 加工: 0–16秒を使用、2秒crossfade loop、high-pass / low-pass、音量正規化、Ogg Vorbis再圧縮

### `amb_grandma_house_interior.ogg`

- 原音: [quiet room.wav](https://freesound.org/s/108400/)
- 作者: filmfan87
- ライセンス: [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/)
- 使用データ: Freesound提供のHQ MP3 preview
- 加工: 0–13.2秒を使用、2秒crossfade loop、high-pass / low-pass、音量正規化、Ogg Vorbis再圧縮

### `sfx_water_ripple.ogg` / `sfx_kappa_subtle_cue.ogg`

- 原音: [Bathtub water splashes.ogg](https://commons.wikimedia.org/wiki/File:Bathtub_water_splashes.ogg)
- 作者: gradha / Grzegorz Adam Hankiewicz
- ライセンス: Public Domain
- 加工: 異なる短い水音を抽出、high-pass / low-pass、fade、音量正規化
- `sfx_kappa_subtle_cue.ogg`のみ、短いechoとpitch変更を加えて使用

### `sfx_bug_net_swing.ogg`

- 原音: プロジェクト内で制作したオリジナル波形（外部素材なし）
- 制作: FFmpeg `anoisesrc`のpink noiseをhigh-pass / low-passし、短いfadeで虫網の風切り音へ整形
- 長さ: 約0.32秒、mono / 48kHz / Ogg Vorbis

### `sfx_bug_catch_success.ogg`

- 原音: プロジェクト内で制作したオリジナル波形（外部素材なし）
- 制作: 1046.5Hzと1568Hzのsineを70msずらして合成し、短い減衰と帯域制限を適用
- 長さ: 約0.43秒、mono / 48kHz / Ogg Vorbis

### `sfx_page_turn.ogg`

- 原音: プロジェクト内で制作したオリジナル波形（外部素材なし）
- 制作: FFmpeg `anoisesrc`のbrown noiseを帯域制限し、紙の擦れに合わせたfadeを適用
- 長さ: 約0.40秒、mono / 48kHz / Ogg Vorbis

### `amb_outdoor_rain.ogg`

- 原音: プロジェクト内で制作したオリジナル波形（外部素材なし）
- 制作: FFmpeg `anoisesrc`のpink noiseをhigh-pass / low-passし、屋外の控えめな雨Loopへ整形
- 長さ: 10秒、mono / 48kHz / Ogg Vorbis

### `amb_outdoor_thunderstorm.ogg`

- 原音: プロジェクト内で制作したオリジナル波形（外部素材なし）
- 制作: FFmpeg `anoisesrc`のbrown noise（低域）とpink noiseを混ぜ、画面フラッシュのない雷雨の遠雷感だけを足す
- 長さ: 10秒、mono / 48kHz / Ogg Vorbis

### `sfx_ui_confirm.ogg` / `sfx_ui_cancel.ogg`

- 原音: プロジェクト内で制作したオリジナル波形（外部素材なし）
- 制作: FFmpegのsineを2音ずつ時間差で合成し、決定音は660Hzから880Hzへ上昇、キャンセル音は620Hzから420Hzへ下降する短い減衰を適用
- 長さ: 決定音 約0.20秒、キャンセル音 約0.23秒、mono / 48kHz / Ogg Vorbis

## 運用

- 新しい外部音源を追加する際は、配布元URL、作者、ライセンス、加工内容を本書へ追記する。
- 帰属必須素材をReleaseから除外する場合も、本書の履歴は削除せず状態を明記する。
- ライセンス不明の音源、Reference動画・画像から抽出した音声、仮の生成音はProductionへ入れない。
- プロジェクト内で波形から制作したオリジナル音は、生成方法と加工内容を本書へ記録する。

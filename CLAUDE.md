# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

AutoHotkey v2 を使った個人用キーボードカスタマイズスクリプト。ラップトップとデスクトップで異なるキーバインドを提供する。

## 起動方法

- `startup.ahk` がエントリーポイント。コンピュータ名 (`A_ComputerName`) で環境を判別し、`TomisukeLaptop.ahk` または `TomisukeDesktop.ahk` を起動する。
- スクリプトのリロード: `Alt+Ctrl+R`
- ゲストモード: `Pause` キーで `TomisukeToQwerty.ahk` に切り替え

## アーキテクチャ

### エントリーポイントと環境分岐

```
startup.ahk
├── TomisukeLaptop.ahk   (A_ComputerName = "tomisukeLaptop")
└── TomisukeDesktop.ahk  (A_ComputerName = "TOMISUKEDESKTOP")
```

両ファイルとも `common/` 以下を `#Include` でロードする。

### common/ の構成

| ファイル | 役割 |
|---|---|
| `common.ahk` | `activeLaptop`/`activeDesktop` グローバル変数の定義、`getRegularApps()` でアプリ起動順序を管理 |
| `runApp.ahk` | `appManager` クラス。アプリ切り替えのコアロジック |
| `AppList.ahk` | `getAppList()` で全アプリの `name`（WinGetList用）と `address`（実行パス）を定義 |
| `appOriginal.ahk` | 特定アプリ向けのホットキー（条件付き `#HotIf`） |
| `IME.ahk` | IME 制御ユーティリティ |
| `ctrlEntertoSend.ahk` | チャットアプリで Ctrl+Enter を送信キーにする |
| `string.ahk` | テキスト展開マクロ（メールアドレス等）。`stringTemplate()` はクリップボードを保存→貼り付け→復元するパターンで副作用を防ぐ |
| `Launcher/bookmark.ahk` | URL・パスのブックマーク定義 |
| `Launcher/launcher.ahk` | InputBox でコマンド入力してブックマーク/パスを開く `launcher()` 関数 |

### appManager クラス（runApp.ahk）

- `apps`: `getAppList()` から取得した全アプリの Map
- `regularApps`: `getRegularApps()` から取得したよく使うアプリ名の配列（インデックス順）
- `anotherApps`: 数値プロパティ（カウンター）。**メソッドではない**
- `runApp(x)`: アプリ名で起動/切り替え。開いているウィンドウを `apps[x].num` でサイクル、なければ起動
- `runRegularApp(index)`: `regularApps` のインデックスで起動
- `activeAnotherApp()`: `regularApps` 以外のウィンドウを順番に切り替える
- `excludeWindow()`: Discord, Twinkle Tray, YouTube Music などバックグラウンドアプリをウィンドウ一覧から除外。新しいバックグラウンドアプリを追加した際はここへの追記も検討する

### キーレイヤー（TomisukeLaptop.ahk）

| レイヤーキー | 用途 |
|---|---|
| `Enter` + キー | 矢印キー・ホーム・エンド・アプリ起動 |
| `Space` + キー | アプリ切り替え（`regularApps` の 1〜10 番）・F1〜F12・音量・輝度 |
| `,` + キー | 数字入力 |
| `.` + キー | 記号入力 |
| `-` + キー | タブ移動 |

### キーバインド（TomisukeDesktop.ahk）

外部キーボードを使うためラップトップと異なる方式。`Ctrl+Alt+F13〜F23` でアプリ切り替え、`Ctrl+Shift+Alt+F*` で追加操作。

### regularApps のインデックス対応（common.ahk）

```
1: chrome  2: memo  3: claude  4: discord  5: notionCalendar
6: zoom    7: ticktick  8: vscode  9: thunderbird  10: onenote
```

### AppList.ahk のパス解決パターン

アプリパスはいくつかの方法で解決している：
- `EnvGet("LOCALAPPDATA")` などの環境変数
- `GetDiscordExe()`: Discord の versioned フォルダ（`app-*`）をスキャンして最新を取得
- `GetClaudeExe()`: PowerShell で `Get-AppxPackage` を実行してインストールパスを照会

新しいアプリでパスが変動する場合（バージョン番号がパスに入るなど）は同様のヘルパー関数を定義する。

## アプリ追加・変更時の手順

1. `AppList.ahk` の `getAppList()` に `name`（WinGetList パターン）と `address`（実行パス）を追加
2. よく使うアプリなら `common.ahk` の `getRegularApps()` に追加（インデックス順序に注意）
3. `CtrlEnterToSend` グループに追加する場合は `AppList.ahk` 冒頭の `GroupAdd` にも追加
4. PC 起動時に自動起動させる場合は `startup.ahk` にも `Run` を追加
5. バックグラウンドで常駐するアプリはウィンドウ切り替えに干渉しないよう `runApp.ahk` の `excludeWindow()` への追加を検討

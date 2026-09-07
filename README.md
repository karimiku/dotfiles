# karimiku/dotfiles

macOS 環境を **Nix で宣言的に管理**。個人 Mac（`#mac`）と仕事用 PC（`#work`）で同じリポジトリを共用。

- **nix-darwin**: システム設定（キーボードリマップ / Dock / ダークモード）+ CLI / GUI パッケージ
- **home-manager**: dotfile シンボリックリンク / zsh 完全構築（oh-my-zsh + p10k + plugins）/ direnv
- **Homebrew**: GUI アプリ（cask）と App Store（masApps）を Nix から `brew bundle` で管理

`setup.sh` は廃止。CLI ツールと設定は `darwin-rebuild switch` 1コマンドに統合。

> **絶対ルール: 仕事用 PC（`#work`）に個人アカウントを持ち込まない。**
> Apple ID / Notion / Codex / 個人 GitHub トークン等はすべて対象外。そのため `~/.agents` `~/.claude` `~/.codex`
> は意図的にこのリポジトリ（PUBLIC）に含めていない。`#work` には App Store アプリ・個人 launchd・趣味アプリも入らない。

## 新しい Mac へのセットアップ

### 手順

1. **Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

2. **Determinate Nix**
   ```bash
   curl -fsSL https://install.determinate.systems/nix | sh -s -- install
   ```

3. **Homebrew（nix-darwin の依存）**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

4. **（個人 Mac のみ）App Store にサインイン**（masApps 用）

5. **リポジトリ clone**
   ```bash
   git clone https://github.com/karimiku/dotfiles.git ~/dotfiles
   ```
   パスは必ず `~/dotfiles`（`mkOutOfStoreSymlink` がこのパスを固定で参照している）。
   `#work` のユーザー名はそのPCのログイン名を自動検出する（`--impure` が必要。`drs` には付いている）。

6. **マシン固有ファイルの作成**
   - `~/.gitconfig.local`: `[user]` セクション（name / email）
   - **仕事用 PC のみ**: `~/.zshenv.local` に `export DOTFILES_HOST=work`

7. **（既存 Mac に初めて当てる場合）キーボードショートカットのバックアップ**
   `CustomUserPreferences` は `com.apple.symbolichotkeys` の辞書を丸ごと書き換えるため、他にカスタムしたショートカットがあると初期値に戻る。
   ```bash
   defaults export com.apple.symbolichotkeys ~/Desktop/symbolichotkeys-backup.plist
   ```

8. **初回適用**
   ```bash
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --impure --flake ~/dotfiles#mac
   ```
   （仕事用は `#work`）

   `nix: command not found` と出たら、Nix インストール直後で PATH が未反映なだけ。ターミナルを開き直すか
   `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh` を実行。`sudo nix` だけ見つからない場合は
   `sudo /nix/var/nix/profiles/default/bin/nix run ...` とフルパスで叩く（初回のみ）。

`brew bundle` は既に手で入っている .app を自動で adopt する。手動版とバージョンが違う場合だけ失敗するので、
その時は `brew install --cask --force <name>` を打ってから cask リストに戻す（現在この理由で外しているのは
mysqlworkbench / blender / arduino-ide / libreoffice。`nix/hosts/mac.nix` にメモあり）。

### Nix 管理外で手動セットアップ（チェックリスト）

- SSH 鍵（`~/.ssh/`）
- `gh auth login`（GitHub CLI）
- `gcloud auth login`（Google Cloud）
- AWS 認証情報
- Raycast 設定（Settings → Advanced → Export/Import）
- Claude Code（`curl -fsSL https://claude.ai/install.sh | bash`）
- volta + Node.js + pnpm
  ```bash
  curl https://get.volta.sh | bash
  volta install node@26 pnpm
  ```
- 日本語入力ソース（システム設定 → キーボード → 入力ソース）
- **個人 Mac のみ**:
  - `~/.agents`（git 管理外・個人アカウント依存、別途コピー）
  - Codex（`npm i -g @openai/codex` + `~/.codex/config.toml` をコピー）

## 日常運用

### dotfile の編集（rebuild 不要）

`config/` と `home/` 配下のファイルは `mkOutOfStoreSymlink` で直接 symlink されるため、編集すると即反映。

```bash
# 編集例
vim ~/dotfiles/home/tmux.conf  # → ~/.tmux.conf がリアルタイム更新
vim ~/dotfiles/config/nvim/init.lua  # → ~/.config/nvim/init.lua が即反映
```

### 新しいツール設定の追加

置き場所ルールだけ覚えればいい。

- `~/.config/foo/` に置く → `config/foo/` を作成して `drs`
- `~/.foo` に置く → `home/foo` を作成して `drs`

### Nix 設定を変更したとき

```bash
drs   # = sudo darwin-rebuild switch --impure --flake ~/dotfiles#${DOTFILES_HOST:-mac}
```

`DOTFILES_HOST` が未設定なら `mac` を使用。仕事用 PC では `~/.zshenv.local` で設定。

### パッケージをアップグレード

```bash
dru   # = cd ~/dotfiles && nix flake update && sudo darwin-rebuild switch --impure --flake .#${DOTFILES_HOST:-mac}
```

## ディレクトリ構成

```
~/dotfiles/
├── flake.nix                           # エントリポイント（mac / work 定義）
├── flake.lock                          # input バージョン pin
├── nix/
│   ├── modules/darwin/common.nix       # 全ホスト共通（macOS 設定 / CLI pkg / Homebrew）
│   └── hosts/
│       ├── mac.nix                     # 個人 Mac（App Store / launchd / 趣味アプリ）
│       └── work.nix                    # 仕事用 PC（個人要素除去）
│
├── config/                             # → ~/.config/ に自動リンク
│   ├── ghostty/
│   ├── nvim/
│   ├── starship.toml
│   └── ...
│
├── home/                               # → ~/ に「.」付きで自動リンク
│   ├── gitconfig                       # [user] は include で ~/.gitconfig.local から読む
│   ├── tmux.conf
│   ├── p10k.zsh
│   └── ...
│
└── zsh/zshrc-extra                     # ~/.zshrc から source（PATH/alias のライブ編集用）
```

## 現在 Nix が面倒を見てくれていること

### macOS システム設定

- キーリピート速度（爆速） / 長押しで連打入力
- ダークモード固定
- 2本指スワイプでブラウザ戻る/進む 無効
- Spotlight の ⌘Space 無効化（Raycast に譲る）
- Dock: 自動隠し / アイコンサイズ / マウスオーバー拡大 / ピン留めアプリ
- スクリーンショット保存先を `~/screenshot` に固定

### CLI ツール（pure Nix）

tmux / neovim / vim / fzf / fd / ripgrep / figlet / git / starship / go / openjdk / python313 / python314 / yarn / awscli2 / terraform / ffmpeg / mysql84 / postgresql_16（postgresql_14 は lowPrio）

※ `gh` は Homebrew 管理（nixpkgs の追従が遅いため）

### GUI アプリ（Homebrew cask）

Ghostty / Dia / Cursor / OrbStack / Docker Desktop / TablePlus / Postman / draw.io / gcloud-cli / ngrok / Wireshark / Claude / ChatGPT / Arc / Chrome / Firefox / Figma / Tailscale / Raycast / Stats / SwiftBar / Ice / MonitorControl（+ フォント）

個人 Mac のみ追加: iTerm2 / UTM / Kiro / Discord / Zoom / Logi Options / GIMP / Unity Hub / MacTeX / Obsidian

### App Store（masApps・個人 Mac のみ）

Slack / LINE / Microsoft Office（Outlook / Word / Excel / PowerPoint）/ Keynote / Numbers / Pages / Kindle / Klack / Contributions / Stickies Pro

### dotfile（home-manager）

`~/` 直下と `~/.config/` 配下のすべてのドット設定ファイル。

### zsh 環境（home-manager）

oh-my-zsh + powerlevel10k + zsh-autosuggestions + zsh-syntax-highlighting + zsh-autopair / direnv + nix-direnv

### ユーザーエージェント（launchd・個人 Mac のみ）

- 毎朝 9:00: 英語学習ノート（eigo スキル）
- 毎月 1 日 8:10: 家計簿（kakeibo スキル）
- 毎日 7:20: 家計簿 keepalive

すべて宣言的にバージョンも含めて再現可能（`flake.lock` で pin）。

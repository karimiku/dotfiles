# karimiku/dotfiles

macOS 環境を **Nix で宣言的に管理**。

- **nix-darwin**: システム設定（キーボードリマップ / Dock / ダークモード）+ CLI / GUI パッケージ（Nix）
- **home-manager**: dotfile シンボリックリンク / zsh 完全構築（oh-my-zsh + p10k + plugins）/ direnv

`setup.sh` は廃止。CLI ツールと設定は `darwin-rebuild switch` 1コマンドに統合。
Homebrew は GUI アプリ（cask: Ghostty / OrbStack / Codex 等）用に併用中。formula は Nix へ移行する方針。

## 新しい Mac へのセットアップ

```bash
# 1. Determinate Nix を入れる
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. このリポジトリを ~/dotfiles に clone
git clone https://github.com/karimiku/dotfiles.git ~/dotfiles

# 3. 全部反映（システム設定 + dotfile + Nix パッケージ）
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#mac
```

### Nix で配れないアプリ（Homebrew cask / 手動 install）

| アプリ | 入手元 |
|---|---|
| Ghostty | `brew install --cask ghostty`（AppKit ビルドが Xcode tooling 依存で Nix 化できない） |
| Microsoft Outlook | Mac App Store |
| Slack | Mac App Store |
| LINE | Mac App Store |
| Dia | https://www.diabrowser.com/ (招待制ベータ) |

## 日常運用

### dotfile の中身を編集する

`config/` `home/` 配下のファイルを直接編集すれば即反映。
`mkOutOfStoreSymlink` のおかげで `~/.tmux.conf → ~/dotfiles/home/tmux.conf` の symlink が live なので **rebuild 不要**。

zsh のユーザカスタム（PATH/関数/env/alias）も `zsh/zshrc-extra` を直接編集 → 新しいシェルから即反映。

### 新しいツールの設定を追加する

置き場所ルールだけ覚えればいい。**nix ファイルの編集は不要**（自動でリンクされる）。

- `~/.config/foo/` に置きたい → `config/foo/` を作って `drs`
- `~/.foo` に置きたい → `home/foo` を作って `drs`（`.` は自動で付く）

### Nix 設定 (`flake.nix` / `nix/**`) を変更したとき

```bash
drs   # = sudo darwin-rebuild switch --flake ~/dotfiles#mac
```

### Nix の input を更新（パッケージのアップグレード）

```bash
dru   # = nix flake update && darwin-rebuild switch
```

## ディレクトリ構成

```
~/dotfiles/
├── flake.nix                # Nix エントリポイント
├── flake.lock               # input バージョン pin（commit 必須）
├── nix/
│   ├── hosts/mac.nix        # nix-darwin（macOS システム設定 + CLI/GUI パッケージ）
│   └── modules/home/        # home-manager（dotfile 自動リンク + zsh + direnv）
│
├── config/                  # → ~/.config/ に自動リンク（ディレクトリ/ファイルを置くだけ）
│   ├── ghostty/             #   → ~/.config/ghostty/
│   ├── nvim/                #   → ~/.config/nvim/
│   ├── git/ignore           #   → ~/.config/git/ignore（グローバル ignore）
│   └── starship.toml        #   → ~/.config/starship.toml
│
├── home/                    # → ~/ 直下に「.」付きで自動リンク
│   ├── gitconfig            #   → ~/.gitconfig
│   ├── p10k.zsh             #   → ~/.p10k.zsh
│   ├── tmux.conf            #   → ~/.tmux.conf
│   └── vimrc                #   → ~/.vimrc
│
└── zsh/zshrc-extra          # ~/.zshrc から source（PATH/alias/関数のライブ編集用）
```

## 現在 Nix が面倒を見てくれていること

### システム (nix-darwin)
- キーリピート速度（爆速）/ 長押し連打有効化
- ダークモード固定
- 2本指スワイプでブラウザ戻る/進む 無効
- Dock: 自動隠し / アイコンサイズ / マウスオーバー拡大
- Dock のピン留めアプリ（Outlook / Mail / Dia / Slack / Codex / OrbStack / Raycast / LINE / Ghostty / System Settings）
- スクリーンショット保存先を `~/screenshot` に固定

### CLI ツール (environment.systemPackages, pure Nix)
- 汎用 CLI: tmux / neovim / vim / fzf / fd / ripgrep / figlet / gh / git / starship
- 言語ランタイム: go / openjdk / python313 / python314 / yarn
- クラウド/インフラ: awscli2 / terraform
- メディア: ffmpeg
- DB: mysql84 / postgresql_16（`postgresql_14` は `lowPrio` で同梱、必要時 `nix shell nixpkgs#postgresql_14`）

GUI アプリは Nix で配らない（tmux 内での rebuild が Full Disk Access エラーになるため）。
Raycast 等は Homebrew cask で管理。

### dotfile (home-manager)
- `~/` 直下のドットファイル（p10k / tmux / vim / git 系）
- `~/.config/` 配下（ghostty / nvim / starship / git）

### zsh まわり (programs.zsh)
- oh-my-zsh + powerlevel10k + zsh-autosuggestions + zsh-syntax-highlighting + zsh-autopair
- direnv + nix-direnv

すべて宣言的にバージョンも含めて再現可能（`flake.lock` で pin）。

# karimiku/dotfiles

macOS 環境を **Nix で宣言的に管理**。

- **nix-darwin**: システム設定（キーボードリマップ / Dock / ダークモード）+ CLI / GUI パッケージ（Nix）
- **home-manager**: dotfile シンボリックリンク / zsh 完全構築（oh-my-zsh + p10k + plugins）/ direnv

`setup.sh` は廃止。Homebrew にも依存しない。すべて `darwin-rebuild switch` 1コマンドに統合。

## 新しい Mac へのセットアップ

```bash
# 1. Determinate Nix を入れる
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. このリポジトリを ~/dotfiles に clone
git clone https://github.com/karimiku/dotfiles.git ~/dotfiles

# 3. 全部反映（システム設定 + dotfile + Nix パッケージ）
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#mac
```

### Nix で配れないアプリ（手動 install）

| アプリ | 入手元 |
|---|---|
| Ghostty | https://ghostty.org/ （AppKit ビルドが Xcode tooling 依存で Nix 化できない） |
| Microsoft Outlook | Mac App Store |
| Slack | Mac App Store |
| LINE | Mac App Store |
| Dia | https://www.diabrowser.com/ (招待制ベータ) |

## 日常運用

### dotfile の中身を編集する

`~/dotfiles/{nvim,tmux,ghostty,starship,git,vim}/dot-*` を直接編集すれば即反映。
`mkOutOfStoreSymlink` のおかげで `~/.tmux.conf → ... → ~/dotfiles/tmux/dot-tmux.conf` の symlink チェーンが live なので **rebuild 不要**。

zsh のユーザカスタム（PATH/関数/env）も `zsh/dot-zshrc-extra` を直接編集 → 即反映。

### Nix 設定 (`flake.nix` / `nix/**`) を変更したとき

```bash
sudo darwin-rebuild switch --flake ~/dotfiles#mac
```

### Nix の input を更新（パッケージのアップグレード）

```bash
cd ~/dotfiles && nix flake update
sudo darwin-rebuild switch --flake .#mac
```

## ディレクトリ構成

```
~/dotfiles/
├── flake.nix                            # Nix エントリポイント
├── flake.lock                           # input バージョン pin（commit 必須）
├── nix/
│   ├── hosts/mac.nix                    # nix-darwin（macOS システム設定 + CLI/GUI パッケージ）
│   └── modules/home/default.nix         # home-manager（dotfile + zsh + direnv）
│
├── ghostty/dot-config/ghostty/          # → ~/.config/ghostty/
├── nvim/dot-config/nvim/                # → ~/.config/nvim/
├── starship/dot-config/starship.toml    # → ~/.config/starship.toml
├── git/dot-config/git/ignore            # → ~/.config/git/ignore
├── git/dot-gitconfig                    # → ~/.gitconfig
├── git/dot-gitignore                    # → ~/.gitignore
├── tmux/dot-tmux.conf                   # → ~/.tmux.conf
├── vim/dot-vimrc                        # → ~/.vimrc
└── zsh/
    ├── dot-p10k.zsh                     # → ~/.p10k.zsh（p10k テーマ設定）
    └── dot-zshrc-extra                  # programs.zsh.initContent から source される
```

## 現在 Nix が面倒を見てくれていること

### システム (nix-darwin)
- キーリピート速度（爆速）/ 長押し連打有効化
- ダークモード固定
- 2本指スワイプでブラウザ戻る/進む 無効
- Dock: 自動隠し / アイコンサイズ / マウスオーバー拡大
- Dock のピン留めアプリ（Outlook / Mail / Dia / Slack / Codex / OrbStack / Raycast / LINE / Ghostty / System Settings）
- スクリーンショット保存先を `~/screenshot` に固定

### CLI ツール + GUI アプリ (environment.systemPackages, pure Nix)
- 汎用 CLI: tmux / neovim / vim / fzf / fd / ripgrep / figlet / gh / git / starship
- 言語ランタイム: go / openjdk / python313 / python314 / yarn
- クラウド/インフラ: awscli2 / terraform
- メディア: ffmpeg
- DB: mysql84 / postgresql_16（`postgresql_14` は `lowPrio` で同梱、必要時 `nix shell nixpkgs#postgresql_14`）
- GUI: raycast（`/Applications/Nix Apps/` に配置）

### dotfile (home-manager)
- `~/` 直下のドットファイル（p10k / tmux / vim / git 系）
- `~/.config/` 配下（ghostty / nvim / starship / git）

### zsh まわり (programs.zsh)
- oh-my-zsh + powerlevel10k + zsh-autosuggestions + zsh-syntax-highlighting + zsh-autopair
- direnv + nix-direnv

すべて宣言的にバージョンも含めて再現可能（`flake.lock` で pin）。

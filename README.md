# karimiku/dotfiles

macOS 環境を Nix で宣言的に管理。nix-darwin がシステム設定、home-manager が dotfiles を担当。

## 新しい Mac へのセットアップ

```bash
# 1. Determinate Nix を入れる
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. このリポジトリを ~/dotfiles に clone
git clone https://github.com/karimiku/dotfiles.git ~/dotfiles

# 3. nix-darwin で全部反映（システム設定 + dotfiles シンボリックリンク）
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/dotfiles#kamirikunoMacBook-Pro

# 4. まだ Nix 化していない依存（brew / oh-my-zsh / plugin 類）を入れる
~/dotfiles/setup.sh
```

> ホスト名が違う Mac の場合は `#kamirikunoMacBook-Pro` の部分を新しい hostname に合わせて変更するか、flake に新ホスト config を追加する。

## 日常運用

### dotfile の中身を編集する

`~/dotfiles/{zsh,nvim,tmux,...}/dot-*` を直接編集すれば即反映。
`mkOutOfStoreSymlink` で `~/.zshrc → … → ~/dotfiles/zsh/dot-zshrc` の symlink チェーンが通っているので **rebuild 不要**。

### Nix 設定 (`flake.nix` / `nix/**`) を変更したとき

```bash
sudo darwin-rebuild switch --flake ~/dotfiles#kamirikunoMacBook-Pro
```

### Nix の input を更新したいとき

```bash
cd ~/dotfiles && nix flake update
sudo darwin-rebuild switch --flake .#kamirikunoMacBook-Pro
```

## ディレクトリ構成

```
~/dotfiles/
├── flake.nix                            # Nix エントリポイント
├── flake.lock                           # input バージョン pin（commit 必須）
├── nix/
│   ├── hosts/kamirikunoMacBook-Pro.nix  # nix-darwin 側（macOS システム設定）
│   └── modules/home/default.nix         # home-manager 側（dotfile symlink）
│
├── ghostty/dot-config/ghostty/          # → ~/.config/ghostty/
├── nvim/dot-config/nvim/                # → ~/.config/nvim/
├── starship/dot-config/starship.toml    # → ~/.config/starship.toml
├── git/dot-config/git/ignore            # → ~/.config/git/ignore
├── git/dot-gitconfig                    # → ~/.gitconfig
├── git/dot-gitignore                    # → ~/.gitignore
├── tmux/dot-tmux.conf                   # → ~/.tmux.conf
├── vim/dot-vimrc                        # → ~/.vimrc
└── zsh/dot-{zshrc,zshenv,zprofile,p10k.zsh}  # → ~/.<name>
```

## 現在 Nix が面倒を見てくれていること

**システム設定 (nix-darwin):**
- Caps Lock → Control リマップ
- キーリピート速度（爆速）/ 長押し連打有効化
- ダークモード固定
- 2本指スワイプでブラウザ戻る/進む 無効
- Dock: 自動隠し / アイコンサイズ / マウスオーバー拡大
- Dock のピン留めアプリ（Outlook / Mail / Dia / Slack / Codex / OrbStack / Raycast / LINE / Ghostty / System Settings 等）
- スクリーンショット保存先を `~/screenshot` に固定

**dotfiles (home-manager):**
- `~/` 直下の dotfile 8 個（zsh系 / tmux / vim / git）
- `~/.config/` 配下の dir/file 4 個（ghostty / nvim / starship / git）
- 編集はリポジトリ側を直接いじる（symlink チェーンで即反映、rebuild 不要）

## まだ Nix 化していない（`setup.sh` が必要）

- Homebrew パッケージ: `tmux`, `neovim`, `fzf`, `ripgrep`, `figlet`, `go`
- Cask: `ghostty`
- Oh My Zsh + Powerlevel10k
- zsh プラグイン: zsh-autosuggestions, zsh-syntax-highlighting, zsh-autopair
- vim-plug + Neovim プラグイン（lazy.nvim）

これらは順次 nix-darwin の `homebrew.brews` / home-manager の `programs.zsh.plugins` 等で置き換えていって、最終的に `setup.sh` を消すのが目標。

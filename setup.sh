#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== dotfiles setup ==="
echo "Source: $DOTFILES_DIR"
echo ""

# ----- Homebrew -----
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ----- Brew packages -----
echo "Installing brew packages..."
brew install --quiet tmux neovim stow fzf ripgrep figlet go

# Ghostty (cask)
brew install --cask --quiet ghostty 2>/dev/null || true

# ----- Oh My Zsh -----
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ----- Powerlevel10k -----
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# ----- zsh plugins -----
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ----- zsh-autopair -----
if [ ! -d "$HOME/.zsh/zsh-autopair" ]; then
  echo "Installing zsh-autopair..."
  mkdir -p "$HOME/.zsh"
  git clone https://github.com/hlissner/zsh-autopair "$HOME/.zsh/zsh-autopair"
fi

# ----- vim-plug (for Vim) -----
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  echo "Installing vim-plug..."
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# ----- Stow でシンボリックリンク作成 -----
echo ""
echo "Stowing dotfiles..."

# dot-* を .* にリネームしてリンクする stow の dot convention
STOW_OPTS="--dotfiles --restow --target=$HOME --dir=$DOTFILES_DIR"

for pkg in zsh vim tmux git ghostty nvim; do
  echo "  stow $pkg"
  stow $STOW_OPTS "$pkg" 2>&1 | grep -v "BUG" || true
done

# ----- Neovim プラグインインストール -----
echo ""
echo "Installing Neovim plugins (lazy.nvim)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

# Vim プラグインは手動: vim → :PlugInstall

echo ""
echo "=== Done! ==="
echo "Restart your terminal or run: source ~/.zshrc"

{ config, pkgs, ... }:

let
  # ~/dotfiles 直下の生ファイルへ直接 symlink を貼るヘルパー。
  # /nix/store にコピーしないので、編集したら即反映（rebuild不要）。
  dot = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";
in
{
  home.username = "kamiriku";
  home.homeDirectory = "/Users/kamiriku";
  home.stateVersion = "24.05";

  # ~/.config/ 配下
  xdg.configFile = {
    "starship.toml".source = dot "starship/dot-config/starship.toml";
    "ghostty".source       = dot "ghostty/dot-config/ghostty";
    "nvim".source          = dot "nvim/dot-config/nvim";
    "git/ignore".source    = dot "git/dot-config/git/ignore";
  };

  # ~/ 直下のドットファイル
  home.file = {
    ".tmux.conf".source = dot "tmux/dot-tmux.conf";
    ".vimrc".source     = dot "vim/dot-vimrc";
    ".zshrc".source     = dot "zsh/dot-zshrc";
    ".zshenv".source    = dot "zsh/dot-zshenv";
    ".zprofile".source  = dot "zsh/dot-zprofile";
    ".p10k.zsh".source  = dot "zsh/dot-p10k.zsh";
    ".gitconfig".source = dot "git/dot-gitconfig";
    ".gitignore".source = dot "git/dot-gitignore";
  };
}

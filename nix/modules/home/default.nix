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

  # ~/ 直下のドットファイル（zsh 系は programs.zsh 管理に移行したので除外）
  home.file = {
    ".tmux.conf".source = dot "tmux/dot-tmux.conf";
    ".vimrc".source     = dot "vim/dot-vimrc";
    ".p10k.zsh".source  = dot "zsh/dot-p10k.zsh";
    ".gitconfig".source = dot "git/dot-gitconfig";
    ".gitignore".source = dot "git/dot-gitignore";
  };

  # direnv: 公式統合（hook も自動セット、Nix 版 direnv が入る）
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # zsh: oh-my-zsh + plugins + theme を全部宣言的に
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    plugins = [
      {
        # powerlevel10k テーマ本体
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        # 括弧自動補完
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }
    ];

    # ~/.zprofile 相当（login shell 起動時）
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
      source ~/.orbstack/shell/init.zsh 2>/dev/null || :
    '';

    # ~/.zshenv 相当（全 zsh 起動時、最初に評価）
    envExtra = ''
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      export VOLTA_HOME="$HOME/.volta"
      export PATH="$VOLTA_HOME/bin:$PATH"
    '';

    # ユーザカスタム部分は別ファイルから source（ライブ編集のため）
    initContent = ''
      [ -r ~/dotfiles/zsh/dot-zshrc-extra ] && source ~/dotfiles/zsh/dot-zshrc-extra

      # Nix を最優先（brew や他ツールが PATH を弄っても Nix CLI が勝つように）
      export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$HOME/.nix-profile/bin:$PATH"
    '';
  };
}

{ config, pkgs, username, ... }:

let
  # ~/dotfiles 直下の生ファイルへ直接 symlink を貼るヘルパー。
  # /nix/store にコピーしないので、編集したら即反映（rebuild不要）。
  dot = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";

  # ディレクトリ直下のエントリ名一覧（自動リンク用）
  entriesOf = dir: builtins.attrNames (builtins.readDir dir);
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.stateVersion = "24.05";

  # config/ 配下を ~/.config/ へ自動リンク。
  # 例: config/ghostty → ~/.config/ghostty、config/starship.toml → ~/.config/starship.toml
  # 新しいツールの設定は config/ に置いて rebuild するだけでリンクされる。
  xdg.configFile = builtins.listToAttrs (map (name: {
    inherit name;
    value.source = dot "config/${name}";
  }) (entriesOf ../../../config));

  # home/ 配下を ~/ 直下へ「.」付きで自動リンク。
  # 例: home/tmux.conf → ~/.tmux.conf、home/gitconfig → ~/.gitconfig
  home.file = builtins.listToAttrs (map (name: {
    name = ".${name}";
    value.source = dot "home/${name}";
  }) (entriesOf ../../../home));

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
      # マシン固有の環境変数（DOTFILES_HOST=work など）。Nix 管理外
      [ -f "$HOME/.zshenv.local" ] && . "$HOME/.zshenv.local"
      [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
      export VOLTA_HOME="$HOME/.volta"
      export PATH="$VOLTA_HOME/bin:$PATH"
    '';

    # ユーザカスタム部分は別ファイルから source（ライブ編集のため）
    initContent = ''
      [ -r ~/dotfiles/zsh/zshrc-extra ] && source ~/dotfiles/zsh/zshrc-extra

      # Nix を最優先（brew や他ツールが PATH を弄っても Nix CLI が勝つように）
      export PATH="/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$HOME/.nix-profile/bin:$PATH"
    '';
  };
}

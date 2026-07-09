{ pkgs, lib, ... }:

{
  # ----- macOS Preferences (defaults) -----
  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 1;                                # 爆速キーリピート
      ApplePressAndHoldEnabled = false;             # 長押しで連打入力
      AppleInterfaceStyle = "Dark";                 # ダークモード
      AppleEnableSwipeNavigateWithScrolls = false;  # 2本指でブラウザ戻る/進む 無効
    };

    dock = {
      autohide = true;
      tilesize = 51;
      magnification = true;
      largesize = 66;
      persistent-apps = [
        "/Applications/Microsoft Outlook.app"
        "/System/Applications/Apps.app"
        "/System/Applications/Mail.app"
        "/Applications/Dia.app"
        "/Applications/Slack.app"
        "/Applications/Codex.app"
        "/Applications/OrbStack.app"
        "/Applications/Raycast.app"
        "/Applications/LINE.app"
        "/Applications/Ghostty.app"
        "/System/Applications/System Settings.app"
      ];
    };

    screencapture.location = "~/screenshot";
  };

  # ----- パッケージ (CLI) -----
  # GUI アプリは Homebrew cask で管理（Nix の app 配置は tmux 内 rebuild で
  # Full Disk Access エラーになるため使わない）。
  # アップデートは `nix flake update` → `darwin-rebuild switch`。
  environment.systemPackages = with pkgs; [
    # CLI (汎用)
    tmux
    neovim
    vim
    fzf
    fd
    ripgrep
    figlet
    gh
    git
    starship
    # 言語ランタイム / ビルドツール
    go
    openjdk
    python313
    python314
    yarn
    # クラウド / インフラ
    awscli2
    terraform
    # メディア
    ffmpeg
    # DB
    mysql84
    postgresql_16
    (lib.lowPrio postgresql_14)  # 14 は lowPrio で衝突回避（必要時 `nix shell nixpkgs#postgresql_14`）
  ];

  # ----- nix-darwin メタ情報 -----
  system.stateVersion = 6;
  system.primaryUser = "kamiriku";
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Determinate Nix と共存（Nix インストール自体は Determinate に任せる）
  nix.enable = false;

  # nixpkgs の unfree ライセンス（Slack 等）を許可
  nixpkgs.config.allowUnfree = true;

  users.users.kamiriku.home = "/Users/kamiriku";
}

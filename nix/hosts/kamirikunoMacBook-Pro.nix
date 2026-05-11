{ pkgs, ... }:

{
  # ----- キーボード -----
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

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

  # ----- CLI ツール (pure Nix) -----
  environment.systemPackages = with pkgs; [
    tmux
    neovim
    fzf
    ripgrep
    figlet
    go
  ];

  # ----- GUI アプリ (Homebrew Cask 経由) -----
  # nix-darwin の homebrew モジュール: brew 本体は別途インストール必要
  # （README の setup 手順参照）
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;   # switch のたびに brew update しない
      upgrade = false;      # 既存のbrewパッケージを勝手にアップグレードしない
      cleanup = "none";     # 宣言してないものは触らない（安全側）
    };
    casks = [
      "ghostty"
      "raycast"
      "orbstack"
      "slack"
      "dia"
      "codex"
      "line"
      "microsoft-outlook"
    ];
  };

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

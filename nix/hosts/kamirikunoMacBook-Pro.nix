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

  # ----- パッケージ (CLI + Nix で取れる GUI) -----
  # GUI は /Applications/Nix Apps/ に配置。
  # アップデートは `nix flake update` → `darwin-rebuild switch`。
  environment.systemPackages = with pkgs; [
    # CLI
    tmux
    neovim
    fzf
    ripgrep
    figlet
    go
    # GUI (nixpkgs に darwin ビルドあり)
    raycast
  ];

  # ----- Homebrew (ghostty 専用、他に手段なし) -----
  # ghostty 公式 flake は macOS では libghostty-vt のみ提供で GUI app は出してない
  # (AppKit ビルドが Xcode tooling 依存のため Nix 化できない)。
  # → 現状 brew cask が唯一の実用解。raycast は Nix へ移行済。
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    casks = [ "ghostty" ];
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

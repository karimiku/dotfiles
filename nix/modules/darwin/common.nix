{ pkgs, lib, username, ... }:

# 全ホスト共通: macOS 設定 / 設定ファイルが前提にする最小 CLI / Homebrew の共通分
{
  # ----- キーボード: CapsLock → Control -----
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
      # persistent-apps はホスト毎（hosts/*.nix）
    };

    screencapture.location = "~/screenshot";

    # nix-darwin にオプションが無い設定は生の defaults として書く
    CustomUserPreferences = {
      # Spotlight の ⌘Space を無効化（Raycast に譲る）
      "com.apple.symbolichotkeys".AppleSymbolicHotKeys."64" = {
        enabled = false;
        value = { parameters = [ 32 49 1048576 ]; type = "standard"; };
      };
      # Raycast を ⌘Space に
      "com.raycast.macos".raycastGlobalHotkey = "Command-49";
      # 日本語IME: ライブ変換オフ / 句読点で自動確定しない
      "com.apple.inputmethod.Kotoeri" = {
        JIMPrefLiveConversionKey = 0;
        JIMPrefConvertWithPunctuationKey = 0;
      };
    };
  };

  # ----- パッケージ (CLI, pure Nix) -----
  # GUI アプリは Homebrew cask で管理（Nix の app 配置は tmux 内 rebuild で
  # Full Disk Access エラーになるため使わない）。
  # 全ホスト共通は「dotfiles の設定が前提にしているもの」だけ。
  # 開発ツールは PC ごとに入れる方針なので hosts/mac.nix 側に置く。
  environment.systemPackages = with pkgs; [
    tmux  # home/tmux.conf、Ghostty / Orca からの自動起動が /run/current-system/sw/bin/tmux を使う
    git   # home/gitconfig、flake の取得
  ];

  # ----- Homebrew (nix-darwin が brew bundle を実行) -----
  # Homebrew 本体は README の手順で先に入れる。
  # 既に手動で入っている .app は brew bundle が自動で --adopt する（バージョンが
  # 一致しない場合だけ失敗するので、その時は `brew install --cask --force <name>`）。
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";  # 宣言外を勝手に消さない（慣れたら "zap" に）
    };
    taps = [
    ];
    # CLI は PC ごとに入れる方針なので全部 hosts/mac.nix 側
    brews = [ ];
    # GUI アプリ（全ホスト共通の最小セット）
    casks = [
      "ghostty"
      "raycast"
      "thebrowsercompany-dia"
      "claude"
      "font-meslo-lg-nerd-font"
    ];
  };

  # ----- nix-darwin メタ情報 -----
  system.stateVersion = 6;
  system.primaryUser = username;
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Determinate Nix と共存（Nix インストール自体は Determinate に任せる）
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  users.users.${username}.home = "/Users/${username}";
}

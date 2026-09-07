{ pkgs, lib, username, ... }:

# 全ホスト共通: macOS 設定 / CLI パッケージ / Homebrew の共通分
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
    };
  };

  # ----- パッケージ (CLI, pure Nix) -----
  # GUI アプリは Homebrew cask で管理（Nix の app 配置は tmux 内 rebuild で
  # Full Disk Access エラーになるため使わない）。
  environment.systemPackages = with pkgs; [
    # CLI (汎用)
    tmux
    neovim
    vim
    fzf
    fd
    ripgrep
    figlet
    # gh は Homebrew で管理（nixpkgs の追従が遅く、最新機能を即使いたいため）
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
      "homebrew/services"
      "ngrok/ngrok"
      "randomplum/gtkwave"
    ];
    # formula: `brew leaves` から Nix 管理分（tmux neovim go figlet）を除いたもの
    brews = [
      "mas"
      "gh"                 # nixpkgs の追従が遅いので brew
      "jq"
      "uv"
      "lazygit"
      "glow"
      "httpie"
      "pandoc"
      "poppler"
      "weasyprint"
      "mkcert"
      "protobuf"
      "sqlc"
      "semgrep"
      "watchman"
      "ollama"
      "cocoapods"
      "maven"
      "git-filter-repo"
      "cloud-sql-proxy"
      "wireguard-tools"
      "smartmontools"
      "gnuplot"
      "jp2a"
      "lv"
      "nkf"
      "grok"
      "gtk+3"
      "clisp"
      "swi-prolog"
      "icarus-verilog"
      "randomplum/gtkwave/gtkwave"
      "povray"
    ];
    # GUI アプリ（開発・仕事で使う共通分）
    casks = [
      "ghostty"
      "cursor"
      "orbstack"
      "docker-desktop"
      "tableplus"
      "postman"
      "drawio"
      "gcloud-cli"
      "ngrok"
      "wireshark-app"
      "claude"
      "chatgpt"
      "thebrowsercompany-dia"   # Dia ブラウザ
      "arc"
      "google-chrome"
      "firefox"
      "figma"
      "tailscale-app"
      "raycast"
      "stats"
      "swiftbar"
      "jordanbaird-ice"
      "monitorcontrol"
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

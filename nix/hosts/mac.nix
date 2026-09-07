{ ... }:

# 個人 Mac 専用: App Store アプリ / 趣味アプリ / 個人アカウント依存の launchd
{
  system.defaults.dock.persistent-apps = [
    "/Applications/Microsoft Outlook.app"
    "/System/Applications/Apps.app"
    "/System/Applications/Mail.app"
    "/Applications/Dia.app"
    "/Applications/Slack.app"
    "/Applications/OrbStack.app"
    "/Applications/Raycast.app"
    "/Applications/LINE.app"
    "/Applications/Ghostty.app"
    "/System/Applications/System Settings.app"
  ];

  homebrew = {
    casks = [
      "iterm2"
      "utm"
      "kiro"
      "discord"
      "zoom"
      "logi-options+"
      "gimp"
      "unity-hub"
      "mactex-no-gui"
      "obsidian"
      # 手動インストール版とバージョンが違い adopt できないもの。
      # 移行するときは `brew install --cask --force <name>` を打ってからここに戻す:
      #   mysqlworkbench blender arduino-ide libreoffice
    ];
    # App Store (`mas list` の ID)。個人 Apple ID が必要
    masApps = {
      "Slack" = 803453959;
      "LINE" = 539883307;
      "Microsoft Outlook" = 985367838;
      "Microsoft Word" = 462054704;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Kindle" = 302584613;
      "Klack" = 6446206067;
      "Contributions" = 1153432612;
      "Stickies Pro" = 1482080766;
    };
  };

  # ----- launchd (ユーザーエージェント) -----
  # スクリプト本体は ~/.agents（Nix 管理外・個人用）/ ~/my_projects/mylife にある。
  launchd.user.agents = let
    home = "/Users/kamiriku";
    job = script: log: cal: {
      serviceConfig = {
        ProgramArguments = [ "/bin/bash" script ];
        StartCalendarInterval = [ cal ];
        StandardOutPath = log;
        StandardErrorPath = log;
      };
    };
    kakeibo = "${home}/my_projects/mylife/.agents/skills/kakeibo";
  in {
    # 毎朝9時: 英語学習ノート（eigo スキル）
    eigo = job "${home}/.agents/skills/eigo/scripts/run_daily.sh"
               "${home}/.agents/skills/eigo/logs/launchd.log" { Hour = 9; Minute = 0; };
    # 毎月1日 8:10: 家計簿
    kakeibo = job "${kakeibo}/scripts/run_monthly.sh" "${kakeibo}/logs/launchd.log"
                  { Day = 1; Hour = 8; Minute = 10; };
    # 毎日 7:20: 家計簿 keepalive
    kakeibo-keepalive = job "${kakeibo}/scripts/keepalive.sh" "${kakeibo}/logs/launchd.log"
                            { Hour = 7; Minute = 20; };
  };

  # 手書きだった旧 plist（com.kamiriku.*）を掃除。Nix 側は org.nixos.* ラベルで登録されるので二重起動を防ぐ
  system.activationScripts.postActivation.text = ''
    for l in com.kamiriku.eigo com.kamiriku.kakeibo com.kamiriku.kakeibo-keepalive; do
      p="/Users/kamiriku/Library/LaunchAgents/$l.plist"
      if [ -f "$p" ]; then
        launchctl bootout "gui/$(id -u kamiriku)/$l" 2>/dev/null || true
        rm -f "$p"
      fi
    done
  '';
}

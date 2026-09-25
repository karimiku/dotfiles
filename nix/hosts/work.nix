{ ... }:

# 別 PC（仕事用）: 設定と macOS 設定だけ。開発ツールと個人アカウント依存のもの（App Store / launchd / 趣味アプリ）は含まない
{
  system.defaults.dock.persistent-apps = [
    "/Applications/Dia.app"
    "/Applications/Slack.app"
    "/Applications/Raycast.app"
    "/Applications/Ghostty.app"
    "/System/Applications/System Settings.app"
  ];

  # 仕事用に追加で欲しい cask があればここへ
  homebrew.casks = [ "slack" ];
}

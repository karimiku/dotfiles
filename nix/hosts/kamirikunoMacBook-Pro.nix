{ pkgs, ... }:

{
  # Caps Lock → Control（最小ゴール: これが動けばOK）
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # nix-darwin が要求するメタ情報
  system.stateVersion = 6;
  system.primaryUser = "kamiriku";
  nixpkgs.hostPlatform = "aarch64-darwin";

  # flakes & nix-command を有効化（Determinate Nix で既に有効だが宣言しておく）
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # このマシンで Nix を管理するユーザ
  users.users.kamiriku.home = "/Users/kamiriku";
}

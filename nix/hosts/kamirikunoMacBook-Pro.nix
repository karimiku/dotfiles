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

  # Determinate Nix と共存（Nix インストール自体は Determinate に任せる）
  nix.enable = false;

  # このマシンで Nix を管理するユーザ
  users.users.kamiriku.home = "/Users/kamiriku";
}

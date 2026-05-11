{ config, pkgs, ... }:

{
  home.username = "kamiriku";
  home.homeDirectory = "/Users/kamiriku";
  home.stateVersion = "24.05";

  # 最小ゴール: starship.toml を home-manager 管理化
  # → switch すると ~/.config/starship.toml が /nix/store への symlink になる
  xdg.configFile."starship.toml".source = ../../../starship/dot-config/starship.toml;
}

{
  description = "kamiriku's Mac, declared in Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager }:
    let
      # ホスト定義ヘルパー。username は macOS のログインユーザー名（`whoami`）。
      mkHost = { username, modules }: nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit username; };
        modules = [
          ./nix/modules/darwin/common.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.extraSpecialArgs = { inherit username; };
            home-manager.users.${username} = import ./nix/modules/home;
          }
        ] ++ modules;
      };
    in {
      darwinConfigurations = {
        # 個人 Mac（フル構成）
        mac = mkHost { username = "kamiriku"; modules = [ ./nix/hosts/mac.nix ]; };
        # 別 PC（仕事用）。ユーザー名が違う場合はここを `whoami` の値に変える
        work = mkHost { username = "kamiriku"; modules = [ ./nix/hosts/work.nix ]; };
      };
    };
}

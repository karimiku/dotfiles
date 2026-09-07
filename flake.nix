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
      # ログインユーザー名を自動検出（`--impure` 付きで評価したときだけ有効）。
      # sudo 経由なら SUDO_USER が本人。取れなければ kamiriku。
      detectedUser =
        let
          su = builtins.getEnv "SUDO_USER";
          u = builtins.getEnv "USER";
        in if su != "" then su else if u != "" then u else "kamiriku";

      # ホスト定義ヘルパー。username 未指定なら自動検出
      mkHost = { username ? detectedUser, modules }: nix-darwin.lib.darwinSystem {
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
        # 別 PC（仕事用）。ユーザー名はそのPCのログイン名を自動検出（drs は --impure 付き）
        work = mkHost { modules = [ ./nix/hosts/work.nix ]; };
      };
    };
}

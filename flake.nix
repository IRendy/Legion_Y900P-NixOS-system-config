{
  description = "A very basic flake";

  nixConfig = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ha.edu.cn/nix-channels/store"
      "https://mirror.nju.edu.cn/nix-channels/store"
      "https://mirror.nyist.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";
    # home-manager = {
    #   url = "github:nix-community/home-manager/release-26.05";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    {
      self,
      nixpkgs,
      # home-manager,
      # nix-flatpak,
      ...
    }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          # nix-flatpak.nixosModules.nix-flatpak

          ./configuration.nix

          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.users.irendy = import ./users/irendy/home.nix;
          # }
          {
            nix.settings.trusted-users = [ "irendy" ];
          }
        ];
      };
    };
}

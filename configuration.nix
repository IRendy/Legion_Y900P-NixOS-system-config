{ config, pkgs, ... }:

{
  imports =
    [
      ./modules/system/default.nix
      ./pkgs/default.nix
      ./users/irendy/configuration.nix
      ./hosts/Legion_Y9000P/default.nix
      # ./hosts/Thinkpad_X230/default.nix
    ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ha.edu.cn/nix-channels/store"
      "https://mirror.nju.edu.cn/nix-channels/store"
      "https://mirror.nyist.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  system.stateVersion = "26.05";
}

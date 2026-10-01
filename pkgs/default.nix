{
  config,
  lib,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      # ncmdump = final.callPackage ./ncmdump/package.nix { };
      # ncmdump-go = final.callPackage ./ncmdump-go/package.nix { };
      # ch341ser = final.callPackage ./ch341ser/package.nix { };
      bilibili-video-downloader = final.callPackage ./profile/bilibili-video-downloader/package.nix {};
      ncmdump = final.callPackage ./ncmdump/package.nix {};
      ncmdump-go = final.callPackage ./ncmdump-go/package.nix {};
    })
  ];
}

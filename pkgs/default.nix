{
  config,
  lib,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      bilibili-video-downloader = final.callPackage ./profile/bilibili-video-downloader/package.nix { };
      ncmdump = final.callPackage ./ncmdump/package.nix { };
      ncmdump-go = final.callPackage ./ncmdump-go/package.nix { };
    })
    (import (
      builtins.fetchGit {
        url = "https://github.com/nix-community/emacs-overlay.git";
        ref = "master";
        rev = "dca11cacb9d23a09630154d31c2c395bc9adbb28";
      }
    ))
  ];
}

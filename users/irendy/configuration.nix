{ config, pkgs, ... }:
{
  users.users."irendy" = {
    isNormalUser = true;
    description = "irendy";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      fastfetch
      qbittorrent
      peazip
      zip
      unzip
      rar
      unrar
      sqlite
      bluetui
      usbutils
      pciutils
      poppler-utils
      wineWow64Packages.stable
      wl-clipboard
      fish
      elvish
      bat
      dust
      fzf
      ripgrep
      zoxide
      eza
      resvg
      imagemagick
      gimp
      kitty
      foot
      alacritty
      btop
      htop
      cyberchef
      hexyl
      just
      gnumake
      nixfmt
      uiua
      zig
      gfortran
      lua
      # nodejs
      ranger
      rustup
      file
      ffmpeg
      jq
      fd
      tmux
      zellij
      lazygit
      qgis
      anki-bin
      stellarium
      bc
      goldendict-ng
      android-tools
      jdk
      uv
      ruff
      (cutter.withPlugins (
        ps: with ps; [
          jsdec
          rz-ghidra
          sigdb
        ]
      ))
      (ghidra.withExtensions (p: with p; [ ret-sync findcrypt ]))
      (python313.withPackages (python-pkgs: with python-pkgs; [ pyproj ]))
      (python314.withPackages (
        python-pkgs: with python-pkgs; [
          pandas
          openpyxl
          xlrd
          requests
          numpy
          matplotlib
          tkinter
          numba
          modelscope
        ]
      ))
      haskellPackages.ghc
      haskellPackages.cabal-install
      haskellPackages.haskell-language-server
      bilibili-video-downloader
      ncmdump
      ncmdump-go
    ];
  };

  networking.hosts = {
    "101.42.138.7" = [ "server1" ];
  };
  services.flatpak.enable = true;
  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  programs.nix-ld.enable = true;
  programs.clash-verge = {
    enable = true;
    tunMode = true;
    serviceMode = true;
    group = "users";
    package = pkgs.clash-verge-rev;
  };
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "sudo"
        "git"
        "zoxide"
        "fzf"
        "eza"
        "extract"
      ];
      theme = "michelebologna";
    };
    shellAliases = {
      cls = "clear";
    };
    shellInit = ''
      EDITOR='hx'
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }
    '';
  };
  programs.yazi = {
    enable = true;
    plugins = {
      inherit (pkgs.yaziPlugins) mount lazygit;
    };
    settings = import ../../pkgs/yazi/settings.nix;
  };
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
}

{ config, pkgs, ... }: {
  users.users."irendy" = {
    isNormalUser = true;
    description = "irendy";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      fastfetch # general
      usbutils
      pciutils
      btop
      htop
      file
      ffmpeg
      jq
      fd
      tmux
      zellij
      lazygit
      ranger
      fish # shell
      elvish
      bat
      dust
      fzf
      ripgrep
      zoxide
      eza
      resvg
      imagemagick
      kitty # terminal
      foot
      alacritty
      poppler-utils
      qbittorrent
      peazip # archive
      zip
      unzip
      rar
      unrar
      sqlite
      csvlens
      bluetui # bluetooth
      wineWow64Packages.stable
      wl-clipboard
      wifitui # network
      qemu # virtual
      gimp # image
      inkscape
      zig # dev
      gnumake
      nixfmt
      uiua
      gfortran
      lua
      nodejs
      go
      cyberchef
      hexyl
      just
      racket
      rustup
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
      # (python313.withPackages (python-pkgs: with python-pkgs; [ pyproj ]))
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
      (ghidra.withExtensions (
        p: with p; [
          ret-sync
          findcrypt
        ]
      )) # reverse
      qgis # study
      anki-bin
      stellarium
      bc
      goldendict-ng
      hledger # finance
      hledger-ui
      hledger-web
      android-tools

      # overlays
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
      lgens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      delgens = "sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system";
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
    interactiveShellInit = ''
      export PATH="$HOME/.npm-global/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/go/bin:$PATH"
    '';
  };
  programs.yazi = {
    enable = true;
    plugins = { inherit (pkgs.yaziPlugins) mount lazygit; };
    settings = import ../../pkgs/yazi/settings.nix;
  };
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
}

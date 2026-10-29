{
  config,
  pkgs,
  lib,
  ...
}:
{
  users.users."irendy" = {
    isNormalUser = true;
    description = "irendy";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "plugdev"
      "dialout"
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
      libxml2
      prettier
      nixfmt
      carapace
      taplo
      stylua
      fd
      tmux
      zellij
      lazygit
      ranger
      bc
      qbittorrent
      emacs-git
      librewolf
      chromium
      jellyfin
      jellyfin-web
      jellyfin-ffmpeg
      jellyfin-desktop
      arion
      docker-client
      docker-compose
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
      peazip # archive
      zip
      unzip
      rar
      unrar
      sqlite
      csvlens
      visidata
      tabularis
      bluetui # bluetooth
      wineWow64Packages.stable
      wl-clipboard
      wifitui # network
      wireshark
      nmap
      zenmap
      dig
      rustscan
      arp-scan
      netscanner
      urlscan
      hashcat # secure
      john
      qemu # virtual
      gimp # image
      inkscape
      zig # dev
      gnumake
      xmake
      cmake
      ninja
      uiua
      gfortran
      lua
      nodejs
      go
      cyberchef
      openssl
      hexyl
      just
      racket
      cargo
      rustc
      rustfmt
      rust-analyzer
      clippy
      go
      jdk
      uv
      ruff
      ruby
      (cutter.withPlugins (
        ps: with ps; [
          jsdec
          rz-ghidra
          sigdb
        ]
      ))
      (python314.withPackages (
        python-pkgs: with python-pkgs; [
          pydantic
          pandas
          tabulate
          openpyxl
          xlrd
          pyyaml
          pydantic
          requests
          httpx
          aiohttp
          beautifulsoup4
          lxml
          playwright
          django
          flask
          numpy
          matplotlib
          tkinter
          numba
          modelscope
          rich
          click
          tqdm
          loguru
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
      goldendict-ng
      hledger # finance
      hledger-ui
      hledger-web
      android-tools
      aapt
      apktool
      apksigner
      jadx

      # overlays
      bilibili-video-downloader
      ncmdump
      ncmdump-go
      # onair # SDR receiver (package in pkgs/onair)
    ];
  };

  networking.hosts = {
    "101.42.138.7" = [ "server1" ];
  };
  services.flatpak.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
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
      export RUSTUP_DIST_SERVER="https://rsproxy.cn"
      export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
      export GO111MODULE=on
      export GOPROXY=https://goproxy.cn
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
    # baidupcs-go on PATH for the baidu plugin, whatever shell yazi is started from
    package = pkgs.yazi.override { extraPackages = [ pkgs.baidupcs-go ]; };
    plugins = {
      inherit (pkgs.yaziPlugins) mount lazygit;
      baidu = ../../pkgs/yazi/plugins/baidu.yazi;
    };
    settings = import ../../pkgs/yazi/settings.nix;
  };
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
  virtualisation = {
    docker.enable = false;
    podman = {
      enable = true;
      dockerSocket.enable = true;
    };
  };

  environment.etc."containers/registries.conf".text = lib.mkForce ''
    unqualified-search-registries = ["docker.io"]

    [[registry]]
    prefix = "docker.io"
    location = "docker.io"

    [[registry.mirror]]
    location = "docker.xuanyuan.me"

    [[registry.mirror]]
    location = "docker.1ms.run"
  '';
}

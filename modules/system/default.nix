{ config, pkgs, ... }:
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-mozc
      fcitx5-nord
      fcitx5-lua
      fcitx5-m17n
      fcitx5-hangul
      fcitx5-pinyin-moegirl
      qt6Packages.fcitx5-qt
      qt6Packages.fcitx5-chinese-addons
    ];
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    neovim
    helix
    git
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 8080 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.adwaita-mono
    nerd-fonts.fira-mono
    nerd-fonts.fira-code
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.hurmit
    nerd-fonts.hack
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    arkpandora_ttf
    lxgw-neoxihei
    jetbrains-mono
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    source-han-sans

    vista-fonts
    carlito
    corefonts
    dejavu_fonts
    courier-prime
    liberation_ttf_v2
    wine64Packages.fonts
    nerd-fonts.symbols-only
    font-awesome_6
    open-sans
  ];
  fonts.fontconfig.useEmbeddedBitmaps = true;
}

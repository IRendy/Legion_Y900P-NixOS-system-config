{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];
 
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = false;
  hardware.nvidia.prime = {
    intelBusId = "PCI:0@0:2:0";
    nvidiaBusId = "PCI:1@0:0:0";
  };
  hardware.nvidia.modesetting.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  environment.systemPackages = with pkgs; [
    hicolor-icon-theme
    adwaita-icon-theme
  ];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;

  users.users."irendy" = {
    packages = with pkgs; [
      thunderbird
      mpv
      kdePackages.elisa
      termusic
      deadbeef
      exiftool
      qrrs
      filezilla
      yacreader
      obs-studio
      blender
      godot
    ];
  };

}

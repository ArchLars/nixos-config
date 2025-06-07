{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  ################################################################################
  # Nixpkgs & licensing
  ################################################################################
  # Allow unfree packages (required for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  ################################################################################
  # Boot loader
  ################################################################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ################################################################################
  # Kernel
  ################################################################################
  boot.kernelPackages = pkgs.linuxPackages;

  ################################################################################
  # Memory (compressed swap-in-RAM)
  ################################################################################
  zramSwap = {
    enable = true;
    memoryPercent = 50;                        # up to half RAM …
    memoryMax = 4 * 1024 * 1024 * 1024;        # … but never above 4 GiB
    algorithm  = "zstd";
    priority   = 5;
  };

  ################################################################################
  # Networking
  ################################################################################
  networking.hostName = "bigboy";
  networking.networkmanager.enable = true;

  ################################################################################
  # Locale / time
  ################################################################################
  time.timeZone = "Europe/Oslo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "nb_NO.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_MESSAGES    = "en_US.UTF-8";
      LC_TIME        = "nb_NO.UTF-8";
      LC_MONETARY    = "nb_NO.UTF-8";
      LC_PAPER       = "nb_NO.UTF-8";
      LC_MEASUREMENT = "nb_NO.UTF-8";
      LC_ADDRESS     = "nb_NO.UTF-8";
      LC_TELEPHONE   = "nb_NO.UTF-8";
      LC_NAME        = "nb_NO.UTF-8";
      LC_NUMERIC     = "nb_NO.UTF-8";
    };
  };

  ################################################################################
  # X11 / keyboard
  ################################################################################
  services.xserver = {
    enable       = true;
    xkb.layout   = "no";
    xkb.variant  = "";
    videoDrivers = [ "nvidia" ];
  };

  console.keyMap = "no-latin1";

  ################################################################################
  # Hardware bits
  ################################################################################
  hardware = {
    enableRedistributableFirmware = true;

    cpu.amd.updateMicrocode = true;

    # New graphics module (replaces hardware.opengl.*)
    graphics = {
      enable      = true;  # 3‑D acceleration, Vulkan, etc.
      enable32Bit = true;  # install 32‑bit driver set for Wine / Steam
      # Derived automatically, but we pin explicitly for clarity
      package32   = config.boot.kernelPackages.nvidiaPackages.stable_32;
    };

    # NVIDIA-specific toggles
    nvidia = {
      modesetting.enable      = true;
      powerManagement.enable  = false;
      powerManagement.finegrained = false;
      open            = true;   # Open-kernel module on RTX 40‑series
      nvidiaSettings  = true;
      package         = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  ################################################################################
  # Power
  ################################################################################
  powerManagement.cpuFreqGovernor = "performance";

  ################################################################################
  # Desktop stack
  ################################################################################
  services.displayManager.sddm.enable    = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  ################################################################################
  # Audio (PipeWire)
  ################################################################################
  security.rtkit.enable = true;
  services.pipewire = {
    enable       = true;
    alsa.enable  = true;
    alsa.support32Bit = true;   # ALSA compatibility for 32‑bit apps
    pulse.enable = true;
  };

  ################################################################################
  # Users
  ################################################################################
  users.users.lars = {
    isNormalUser = true;
    description  = "Lars";
    extraGroups  = [ "networkmanager" "wheel" "audio" "video" "input" ];
    packages = with pkgs; [ firefox kate konsole ];
  };

  ################################################################################
  # System‑wide packages (CLI)
  ################################################################################
  environment.systemPackages = with pkgs; [ nano wget git ];

  ################################################################################
  # Garbage collection housekeeping
  ################################################################################
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 30d";
  };

  ################################################################################
  # Do not change after install
  ################################################################################
  system.stateVersion = "25.05";
}

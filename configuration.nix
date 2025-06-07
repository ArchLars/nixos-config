{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Enable unfree packages (required for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # Boot loader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel configuration
  boot.kernelPackages = pkgs.linuxPackages;

  # zram swap configuration (no traditional swap)
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    memoryMax = 4 * 1024 * 1024 * 1024;  # 4GB cap (matches min(ram / 2, 4096))
    algorithm = "zstd";
    priority = 5;
  };

  # Network configuration
  networking.hostName = "bigboss";
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "Europe/Oslo";

  # Internationalization (Norwegian keyboard, English system)
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "nb_NO.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_MESSAGES = "en_US.UTF-8";
    LC_TIME = "nb_NO.UTF-8";
    LC_MONETARY = "nb_NO.UTF-8";
    LC_PAPER = "nb_NO.UTF-8";
    LC_MEASUREMENT = "nb_NO.UTF-8";
    LC_ADDRESS = "nb_NO.UTF-8";
    LC_TELEPHONE = "nb_NO.UTF-8";
    LC_NAME = "nb_NO.UTF-8";
    LC_NUMERIC = "nb_NO.UTF-8";
  };

  # Keyboard configuration
  services.xserver = {
    enable = true;
    xkb.layout = "no";
    xkb.variant = "";
    videoDrivers = [ "nvidia" ];
  };

  console.keyMap = "no-latin1";

  # Hardware configuration
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  # CPU performance
  powerManagement.cpuFreqGovernor = "performance";

  # NVIDIA configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Display manager and desktop environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Audio configuration with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User configuration
  users.users.lars = {
    isNormalUser = true;
    description = "Lars";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "input" ];
    packages = with pkgs; [
      firefox
      kate
      konsole
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    nano
    wget
    git
  ];

  # System state version (DO NOT CHANGE after installation)
  system.stateVersion = "25.05";
}

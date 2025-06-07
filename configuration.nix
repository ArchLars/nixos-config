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
  boot.kernelModules = [ "kvm-amd" ];

  # zram swap configuration (no traditional swap)
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
    priority = 5;
  };

  # Network configuration
  networking.hostName = "nixos";
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

  # NVIDIA configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
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
  users.users.user = {
    isNormalUser = true;
    description = "User";
    extraGroups = [ "networkmanager" "wheel" ];
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
    linux-headers
    nvidia-settings
    nvidia-system-monitor-qt
  ];

  # Services
  services.openssh.enable = true;
  services.printing.enable = true;

  # System state version (DO NOT CHANGE after installation)
  system.stateVersion = "24.05";
}
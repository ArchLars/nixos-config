{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  ##############################################################################
  # Nixpkgs & licensing
  ##############################################################################
  nixpkgs.config.allowUnfree = true;

  ##############################################################################
  # Boot loader
  ##############################################################################
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  ##############################################################################
  # Kernel
  ##############################################################################
  boot.kernelPackages = pkgs.linuxPackages;   # switch to linuxPackages_latest if need bleeding-edge NVIDIA

  ##############################################################################
  # Memory (compressed swap-in-RAM)
  ##############################################################################
  zramSwap = {
    enable        = true;
    memoryPercent = 50;                       # up to half of RAM …
    memoryMax     = 4 * 1024 * 1024 * 1024;   # … but never above 4 GiB
    algorithm     = "zstd";
    priority      = 5;
  };

  ##############################################################################
  # Networking
  ##############################################################################
  networking = {
    hostName = "bigboy";
    networkmanager.enable = true;
  };

  ##############################################################################
  # Locale / time
  ##############################################################################
  time.timeZone = "Europe/Oslo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "nb_NO.UTF-8/UTF-8" ];
    extraLocaleSettings = lib.genAttrs [
      "LC_TIME" "LC_MONETARY" "LC_PAPER" "LC_MEASUREMENT"
      "LC_ADDRESS" "LC_TELEPHONE" "LC_NAME" "LC_NUMERIC"
    ] (_: "nb_NO.UTF-8") // {
      LC_MESSAGES = "en_US.UTF-8";
    };
  };

  ##############################################################################
  # X11 / keyboard
  ##############################################################################
  services.xserver = {
    enable       = true;
    xkb.layout   = "no";
    xkb.variant  = "";
    videoDrivers = [ "nvidia" ];
  };
  console.keyMap = "no-latin1";

  ##############################################################################
  # Hardware bits
  ##############################################################################
  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;

    graphics = {
      enable      = true;    # 3-D/Vulkan
      enable32Bit = true;    # 32-bit driver set for Wine / Steam
      # package32 left unset — module auto-selects the matching 32-bit driver
    };

    nvidia = {
      modesetting.enable       = true;
      powerManagement.enable   = false;
      powerManagement.finegrained = false;
      open            = true;             # set false for pre-Ampere GPUs
      nvidiaSettings  = true;
      package         = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  ##############################################################################
  # Power
  ##############################################################################
  powerManagement.cpuFreqGovernor = "performance";

  ##############################################################################
  # Desktop stack
  ##############################################################################
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  ##############################################################################
  # Audio (PipeWire)
  ##############################################################################
  security.rtkit.enable = true;
  services.pipewire = {
    enable          = true;
    alsa.enable     = true;
    alsa.support32Bit = true;
    pulse.enable    = true;
  };

  ##############################################################################
  # Users
  ##############################################################################
  users.users.lars = {
    isNormalUser = true;
    description  = "Lars";
    extraGroups  = [ "networkmanager" "wheel" "audio" "video" "input" ];
    packages     = with pkgs; [ firefox kate konsole ];
  };

  ##############################################################################
  # System-wide CLI packages
  ##############################################################################
  environment.systemPackages = with pkgs; [ nano wget git ];

  ##############################################################################
  # Garbage-collection housekeeping
  ##############################################################################
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 30d";
  };

  ##############################################################################
  # Do not change after install
  ##############################################################################
  system.stateVersion = "25.05";
}

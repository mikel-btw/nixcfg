{ config, pkgs, inputs, ... }:

{
  imports = [
     ./hardware-configuration.nix
     ./fan5500.nix
  ];

  # ── ZRAM ──────────────────────────────────────────────────────────────────
  zramSwap.enable = true;
  zramSwap.memoryPercent = 50; # 8GB de tus 16GB

  # ── Bootloader ────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── Kernel ────────────────────────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  # ── Red ───────────────────────────────────────────────────────────────────
  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  # Broadcom WiFi (MacBook Pro 13" 2012 usa BCM4331)
  hardware.enableRedistributableFirmware = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" "brcmsmac" ];

  # ── Localización ──────────────────────────────────────────────────────────
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "es_CO.UTF-8";
  console.keyMap = "es";

  # ── Gráficos - Intel HD 4000 ──────────────────────────────────────────────
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "intel" ];

  # ── Escritorio ────────────────────────────────────────────────────────────
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # ── Bluetooth ─────────────────────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ── Camara (FaceTime HD - uvcvideo) ───────────────────────────────────────
  boot.kernelModules = [ "wl" "uvcvideo" "apple_gmux" ];

  # ── Audio ─────────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Podman ────────────────────────────────────────────────────────────────
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    dockerSocket.enable = true;
  };
  virtualisation.containers.registries.search = [ "docker.io" "quay.io" ];

  # ── Virtualbox ────────────────────────────────────────────────────────────

  virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];

  # ── Tailscale ─────────────────────────────────────────────────────────────

  services.tailscale = {
    # Enable tailscale at startup
    enable = true;

    # If you would like to use a preauthorized key, set
    # authKeyFile = "/run/secrets/tailscale_key";
    # Note: maximum expire time is 90 days
  };


  # ── Usuario ───────────────────────────────────────────────────────────────
  users.users.mikel = {
    hashedPassword = "$y$j9T$mYiOYCciCxYTAeVRx2O9Z0$nZUAbQxiut5AT8bep0ggvLHfKX6cxCuEQO3rfwC/aj7";
    isNormalUser = true;
    description = "Mikel";
    extraGroups = [ "wheel" "networkmanager" "dialout" ]; # dialout para Arduino
    shell = pkgs.bash;
  };

  # ── Paquetes del sistema ───────────────────────────────────────────────────
  # Los paquetes de usuario van en home.nix
  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    podman-compose
  ];

  # ── Programas ─────────────────────────────────────────────────────────────
  programs.firefox.enable = true;

  # Permite paquetes con licencias no libres (necesario para broadcom_sta, vscode, arduino)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "broadcom-sta-6.30.223.271-63-6.12.112" ];

  # ── Nix ───────────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

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
  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
  boot.blacklistedKernelModules = [ "b43" "bcma" "ssb" "brcmsmac" ];

  # ── Localización ──────────────────────────────────────────────────────────
  time.timeZone = "Europe/Madrid"; # ajusta si es necesario
  i18n.defaultLocale = "es_ES.UTF-8";
  console.keyMap = "es";

  # ── Gráficos - Intel HD 4000 ──────────────────────────────────────────────
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "intel" ];

  # ── Escritorio ────────────────────────────────────────────────────────────
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # ── Audio ─────────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Usuario ───────────────────────────────────────────────────────────────
  users.users.mikel = {
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
  ];

  # ── Programas ─────────────────────────────────────────────────────────────
  programs.firefox.enable = true;

  # Permite paquetes con licencias no libres (necesario para broadcom_sta, vscode, arduino)
  nixpkgs.config.allowUnfree = true;

  # ── Nix ───────────────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}

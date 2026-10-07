{ pkgs, ... }:

{
  home.username = "mikel";
  home.homeDirectory = "/home/mikel";
  home.stateVersion = "24.11";

  # ── Paquetes de usuario ───────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Navegadores
    librewolf
    tor-browser

    # Editores e IDEs
    vscode
    neovim
    nano

    # Desarrollo
    jdk25
    python3
    arduino

    # Multimedia
    vlc

    # Ofimática
    libreoffice
  ];

  # ── Kitty ─────────────────────────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      font_size = "12.0";
      scrollback_lines = 10000;
      enable_audio_bell = false;
    };
  };

  # ── Git ───────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "mikel";
    userEmail = "angeloso74@hotmail.com";
  };

  # ── Home-manager se gestiona a si mismo ───────────────────────────────────
  programs.home-manager.enable = true;
}

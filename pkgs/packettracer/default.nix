{ stdenv
, lib
, dpkg
, appimageTools
, requireFile
, qt6
, stdenvNoCC
}:

let
  pname = "cisco-packet-tracer";
  version = "9.0.1";

  src = requireFile {
    name = "CiscoPacketTracer_901_Ubuntu_64bit.deb";
    sha256 = "3683dd87e779885372ae9a35c1a6e594d12f493e649e7c697408729c1459479b";
    message = ''
      El archivo no está disponible en el Nix Store. 
      Añádelo localmente ejecutando:
      nix-store --add-fixed sha256 /etc/nixos/pkgs/packettracer/CiscoPacketTracer_901_Ubuntu_64bit.deb
    '';
  };

  unpackedDeb = stdenvNoCC.mkDerivation {
    name = "${pname}-unpacked-${version}";
    inherit src;
    nativeBuildInputs = [ dpkg ];
    buildCommand = ''
      dpkg-deb -x $src $out
    '';
  };

  appimageFile = "${unpackedDeb}/opt/pt/packettracer.AppImage";

  extractedAppImage = appimageTools.extract {
    inherit pname version;
    src = appimageFile;
  };

in appimageTools.wrapType2 {
  inherit pname version;
  src = appimageFile;

  extraPkgs = pkgs: with pkgs; [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwebengine
    qt6.qtmultimedia
    libglvnd
    alsa-lib
    nspr
    nss
    libx11
    libxext
    libxrender
    libxi
    libxrandr
    libxcursor
    libxfixes
    libxcomposite
    libxdamage
    libxtst
    libxkbfile
    libxkbcommon
    libpng
    freetype
    fontconfig
    dbus
    glib
    zlib
    expat
    libdrm
    mesa
  ];

  extraInstallCommands = ''
    ln -s $out/bin/${pname} $out/bin/packettracer

    mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps

    desktopFile=$(find ${extractedAppImage} -maxdepth 1 -name "*.desktop" | head -n 1)
    if [ -n "$desktopFile" ]; then
      cp "$desktopFile" $out/share/applications/cisco-packet-tracer.desktop
      substituteInPlace $out/share/applications/cisco-packet-tracer.desktop \
        --replace-quiet "Exec=PacketTracer" "Exec=packettracer" \
        --replace-quiet "Exec=packettracer" "Exec=packettracer" \
        --replace-quiet "Exec=CiscoPacketTracer" "Exec=packettracer"
    fi

    find ${extractedAppImage} -maxdepth 2 \( -name "*.png" -o -name "*.svg" \) -exec cp {} $out/share/icons/hicolor/512x512/apps/ \; 2>/dev/null || true
  '';

  meta = with lib; {
    description = "Cisco Packet Tracer simulation tool (AppImage version)";
    homepage = "https://www.netacad.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}

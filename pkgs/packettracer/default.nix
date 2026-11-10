{ stdenv
, lib
, dpkg
, appimageTools
, makeWrapper
, qt6
, stdenvNoCC
}:

let
  pname = "cisco-packet-tracer";
  version = "9.0.1";
  src = ./CiscoPacketTracer_901_Ubuntu_64bit.deb;

  # Extraemos temporalmente el AppImage del .deb usando un derivation auxiliar o dpkg
  unpackedDeb = stdenvNoCC.mkDerivation {
    name = "${pname}-unpacked-${version}";
    inherit src;
    nativeBuildInputs = [ dpkg ];
    buildCommand = ''
      dpkg-deb -x $src $out
    '';
  };

  appimageFile = "${unpackedDeb}/opt/pt/packettracer.AppImage";

in appimageTools.wrapType2 {
  inherit pname version;
  src = appimageFile;

  # Si Packet Tracer 9 requiere dependencias adicionales de Qt6 o gráficas, 
  # appimageTools se encarga de inyectarlas en el entorno de ejecución.
  extraPkgs = pkgs: with pkgs; [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwebengine
    qt6.qtmultimedia
    libglvnd
    alsa-lib
    nspr
    nss
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXi
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXfixes
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXtst
  ];

  meta = with lib; {
    description = "Cisco Packet Tracer simulation tool (AppImage version)";
    homepage = "https://www.netacad.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}

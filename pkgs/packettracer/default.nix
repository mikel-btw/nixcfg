{ stdenv
, lib
, dpkg
, appimageTools
, qt6
, stdenvNoCC
}:

let
  pname = "cisco-packet-tracer";
  version = "9.0.1";
  src = ./CiscoPacketTracer_901_Ubuntu_64bit.deb;

  unpackedDeb = stdenvNoCC.mkDerivation {
    name = "${pname}-unpacked-${version}";
    inherit src;
    nativeBuildInputs = [ dpkg ];
    buildCommand = ''
      dpkg-deb -x $src $out
    '';
  };

  appimageFile = "${unpackedDeb}/opt/pt/packettracer.AppImage";

  # Extraemos el contenido del AppImage para obtener el archivo .desktop e iconos
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

  extraInstallCommands = ''
    # 1. Crear el enlace simbólico para que el comando 'packettracer' funcione en terminal
    ln -s $out/bin/${pname} $out/bin/packettracer

    # 2. Copiar el archivo .desktop e icono para que aparezca en el menú del sistema
    mkdir -p $out/share/applications $out/share/icons/hicolor/512x512/apps
    
    if [ -f ${extractedAppImage}/cisco-pt.desktop ]; then
      cp ${extractedAppImage}/cisco-pt.desktop $out/share/applications/cisco-packet-tracer.desktop
    elif [ -f ${extractedAppImage}/*.desktop ]; then
      cp ${extractedAppImage}/*.desktop $out/share/applications/cisco-packet-tracer.desktop
    fi

    # 3. Ajustar la línea Exec del .desktop para que apunte a nuestro ejecutable
    substituteInPlace $out/share/applications/cisco-packet-tracer.desktop \
      --replace-quiet "Exec=PacketTracer" "Exec=packettracer" \
      --replace-quiet "Exec=packettracer" "Exec=packettracer"
  '';

  meta = with lib; {
    description = "Cisco Packet Tracer simulation tool (AppImage version)";
    homepage = "https://www.netacad.com";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}

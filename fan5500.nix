{ pkgs, ... }:
let
  hw = "/sys/devices/platform/applesmc.768";

  fanScript = pkgs.writeShellScript "fan5500" ''
    restore() { echo 0 > ${hw}/fan1_manual; }
    trap 'restore; exit 0' INT TERM EXIT

    until [ -w ${hw}/fan1_manual ]; do sleep 1; done

    echo 1 > ${hw}/fan1_manual
    while true; do
      echo 5500 > ${hw}/fan1_output
      sleep 2
    done
  '';

  restoreScript = pkgs.writeShellScript "fan5500-restore" ''
    echo 0 > ${hw}/fan1_manual
  '';
in
{
  systemd.services.fan5500 = {
    description = "Mantener ventilador a 5500 rpm";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      ExecStart = fanScript;
      ExecStopPost = restoreScript;
      Restart = "always";
      RestartSec = 5;
    };
  };
}

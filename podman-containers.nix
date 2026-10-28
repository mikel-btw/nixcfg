{ config, pkgs, ... }:

{
  virtualisation.oci-containers.backend = "podman";

  systemd.services.podman-parqueadero-net = {
    description = "Crear red podman parqueadero-net";
    before = [
      "podman-parqueadero-db.service"
      "podman-parqueadero-php.service"
      "podman-parqueadero-pma.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      ${pkgs.podman}/bin/podman network exists parqueadero-net || \
      ${pkgs.podman}/bin/podman network create parqueadero-net
    '';
  };

  virtualisation.oci-containers.containers = {

    parqueadero-db = {
      image = "mariadb:11";
      networks = [ "parqueadero-net" ];
      environment = {
        MYSQL_ROOT_PASSWORD = "root";
        MYSQL_DATABASE      = "trabajo30";
        MYSQL_USER          = "parqueadero";
        MYSQL_PASSWORD      = "parqueadero123";
      };
      volumes = [ "/home/mikel/Documentos/ParqueaderoMySQL:/var/lib/mysql" ];
      ports   = [ "3306:3306" ];
    };

    parqueadero-php = {
      image     = "php:8.2-apache";
      networks  = [ "parqueadero-net" ];
      volumes   = [ "/home/mikel/Documentos/ParqueaderoPHP:/var/www/html" ];
      ports     = [ "8080:80" ];
      dependsOn = [ "parqueadero-db" ];
    };

    parqueadero-pma = {
      image    = "phpmyadmin:latest";
      networks = [ "parqueadero-net" ];
      environment = {
        PMA_HOST     = "parqueadero-db";
        PMA_USER     = "parqueadero";
        PMA_PASSWORD = "parqueadero123";
      };
      ports     = [ "8081:80" ];
      dependsOn = [ "parqueadero-db" ];
    };
  };
}

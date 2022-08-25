{ config, lib, pkgs, ... }:

with lib; let
  cfg = config.services.tg-captcha;
  tg-captcha = pkgs.callPackage ./package.nix { };
in
{
  options.services.tg-captcha = {
    enable = mkEnableOption "Enable tg captcha";

    envFile = mkOption {
      type = types.path;
      description = "Path to env secrets";
    };

    datadir = mkOption {
      type = types.path;
      default = "/var/lib/tg-captcha";
      description = "Data directory";
    };

    package = mkOption {
      type = types.package;
      default = tg-captcha;
      description = "Captcha package to use";
    };
  };

  config.systemd.services = mkIf cfg.enable {
    tg-captcha = {
      enable = true;
      description = "Simple telegram captcha";
      unitConfig = {
        Type = "simple";
      };
      serviceConfig = {
        User = "tg-captcha";
        Group = "tg-captcha";
        WorkingDirectory = cfg.datadir;
        ExecStart = "${cfg.package}/bin/tgcaptcha";
        Restart = "on-failure";
        RestartSec = "1s";
        EnvironmentFile = cfg.envFile;
      };
      wantedBy = [ "multi-user.target" ];
    };
  };

  config.users = mkIf cfg.enable {
    users.tg-captcha = {
      isSystemUser = true;
      description = "tg-captcha user";
      home = cfg.datadir;
      createHome = true;
      group = "tg-captcha";
    };

    groups.tg-captcha = { };
  };
}

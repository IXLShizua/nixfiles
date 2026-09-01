{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.mediamtx;
  format = pkgs.formats.yaml_1_2 { };
  confFile = format.generate "mediamtx.yaml" cfg.settings;
in
{
  options.services.mediamtx = {
    enable = lib.mkEnableOption "MediaMTX";

    package = lib.mkPackageOption pkgs "mediamtx" { };

    settings = lib.mkOption {
      description = ''
        Settings for MediaMTX. Refer to the defaults at
        <https://github.com/bluenviron/mediamtx/blob/main/mediamtx.yml>.
      '';
      type = format.type;
      default = { };
    };

    env = lib.mkOption {
      type = with lib.types; attrsOf anything;
      description = "Extra environment variables for MediaMTX";
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."mediamtx/mediamtx.yaml".source = confFile;

    systemd.user.services.mediamtx = {
      Unit = {
        Description = "MediaMTX Media Server";
        After = [ "network.target" ];
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        Environment = lib.mapAttrsToList (n: v: "${n}=${toString v}") cfg.env;
        ExecStart = "${cfg.package}/bin/mediamtx ${config.xdg.configHome}/mediamtx/mediamtx.yaml";
        Restart = "on-failure";
      };
    };
  };
}

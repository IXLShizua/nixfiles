{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.internet-accelerator;
in
{
  options.services.internet-accelerator = {
    enable = lib.mkEnableOption "Internet Accelerator";

    secretFile = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression "./secrets/internet-accelerator.json.age";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets."internet-accelerator.json" = {
      file = cfg.secretFile;
      owner = "sing-box";
    };

    services.sing-box.enable = true;

    networking.nftables = {
      enable = true;
      rulesetFile = ./accelerator.conf;
    };

    systemd.services.sing-box = {
      preStart = ''
        ${pkgs.iproute2}/bin/ip rule add fwmark 1 table 100 || true
        ${pkgs.iproute2}/bin/ip route add local default dev lo table 100 || true

        ${pkgs.iproute2}/bin/ip -6 rule add fwmark 1 table 100 || true
        ${pkgs.iproute2}/bin/ip -6 route add local default dev lo table 100 || true

        ${pkgs.iproute2}/bin/ip link add sbdummy0 type dummy || true
        ${pkgs.iproute2}/bin/ip link set sbdummy0 up || true
        ${pkgs.iproute2}/bin/ip -6 route replace default dev sbdummy0 metric 4294967294 || true
      '';

      postStop = ''
        ${pkgs.iproute2}/bin/ip rule del fwmark 1 table 100 || true
        ${pkgs.iproute2}/bin/ip route del local default dev lo table 100 || true

        ${pkgs.iproute2}/bin/ip -6 rule del fwmark 1 table 100 || true
        ${pkgs.iproute2}/bin/ip -6 route del local default dev lo table 100 || true

        ${pkgs.iproute2}/bin/ip -6 route del default dev sbdummy0 || true
        ${pkgs.iproute2}/bin/ip link del sbdummy0 || true
      '';

      serviceConfig.ExecStart = lib.mkForce [
        ""
        "${pkgs.sing-box}/bin/sing-box run -c ${config.age.secrets."internet-accelerator.json".path}"
      ];
    };
  };
}

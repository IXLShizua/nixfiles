{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.internet-accelerator;

  markType = lib.types.strMatching "^(0x[0-9a-fA-F]+|[0-9]+)$";

  nftBypassRules = lib.concatStringsSep "\n" (
    map (mark: ''
      meta mark ${mark} ct mark set ${cfg.autoRedirectBypassMark} counter return
    '') cfg.excludeFwMarks
  );

  fwmarkBypassRuleset = pkgs.writeText "internet-accelerator-fwmark-bypass.nft" ''
    table inet internet_accelerator_bypass {
      chain output {
        type filter hook output priority mangle - 2; policy accept;
        ${nftBypassRules}
      }

      chain prerouting {
        type filter hook prerouting priority dstnat - 2; policy accept;
        ${nftBypassRules}
      }
    }
  '';
in
{
  options.services.internet-accelerator = {
    enable = lib.mkEnableOption "Internet Accelerator";

    secretFile = lib.mkOption {
      type = lib.types.path;
      example = lib.literalExpression "./secrets/internet-accelerator.json.age";
    };

    excludeFwMarks = lib.mkOption {
      type = lib.types.listOf markType;
      default = [ ];
      example = [
        "0x66"
        "0x100"
        "1234"
      ];
      description = ''
        fwmark values that must bypass sing-box auto_redirect/TUN proxying.
        For matched packets, this module sets conntrack mark to sing-box
        auto_redirect_output_mark before sing-box nft hooks run.
      '';
    };

    autoRedirectBypassMark = lib.mkOption {
      type = markType;
      default = "0x2024";
      example = "0x2024";
      description = ''
        Must match sing-box auto_redirect_output_mark from the JSON config.
        Leave default if you did not override it in sing-box.
      '';
    };
  };

  config = lib.mkIf cfg.enable ({
    age.secrets."internet-accelerator.json" = {
      file = cfg.secretFile;
      owner = "sing-box";
    };

    services.sing-box.enable = true;
    networking.nftables.enable = true;

    systemd.services.sing-box = {
      serviceConfig.ExecStart = lib.mkForce [
        ""
        "${pkgs.sing-box}/bin/sing-box run -c ${config.age.secrets."internet-accelerator.json".path}"
      ];
    }
    // lib.optionalAttrs (cfg.excludeFwMarks != [ ]) {
      postStart = lib.mkAfter ''
        set -eu

        ${pkgs.nftables}/bin/nft delete table inet internet_accelerator_bypass 2>/dev/null || true
        ${pkgs.nftables}/bin/nft -f ${fwmarkBypassRuleset}
      '';

      postStop = lib.mkAfter ''
        ${pkgs.nftables}/bin/nft delete table inet internet_accelerator_bypass 2>/dev/null || true
      '';
    };
  });
}

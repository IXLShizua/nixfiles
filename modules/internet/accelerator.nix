{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.internet-accelerator;

  markType = lib.types.strMatching "^(0x[0-9a-fA-F]+|[0-9]+)$";

  fwMarkRuleType = lib.types.submodule {
    options = {
      mark = lib.mkOption {
        type = markType;
        example = "0x80000";
        description = "fwmark value to match";
      };

      mask = lib.mkOption {
        type = markType;
        example = "0xff0000";
        description = "fwmark mask to apply before comparison";
      };
    };
  };

  exactFwMarkRules =
    map (mark: ''
      meta mark ${mark} ct mark set ${cfg.autoRedirectBypassMark} counter return
    '') cfg.excludeFwMarks;

  maskedFwMarkRules =
    map (rule: ''
      meta mark & ${rule.mask} == ${rule.mark} ct mark set ${cfg.autoRedirectBypassMark} counter return
    '') cfg.excludeFwMarkMasked;

  allFwMarkRules = exactFwMarkRules ++ maskedFwMarkRules;

  nftBypassRules = lib.concatStringsSep "\n" allFwMarkRules;

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
      example = [ "0x66" "0x100" ];
      description = ''
        Exact fwmark values that must bypass sing-box auto_redirect/TUN proxying.
      '';
    };

    excludeFwMarkMasked = lib.mkOption {
      type = lib.types.listOf fwMarkRuleType;
      default = [ ];
      example = [
        { mark = "0x80000"; mask = "0xff0000"; }
        { mark = "0x400"; mask = "0xff00"; }
      ];
      description = ''
        fwmark match rules with mask. For matched packets, this module sets
        conntrack mark to sing-box auto_redirect_output_mark before sing-box
        nft hooks run.
      '';
    };

    autoRedirectBypassMark = lib.mkOption {
      type = markType;
      default = "0x2024";
      example = "0x2024";
      description = ''
        Must match sing-box auto_redirect_output_mark from the JSON config.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
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
    } // lib.optionalAttrs (allFwMarkRules != [ ]) {
      postStart = lib.mkAfter ''
        set -eu
        ${pkgs.nftables}/bin/nft delete table inet internet_accelerator_bypass 2>/dev/null || true
        ${pkgs.nftables}/bin/nft -f ${fwmarkBypassRuleset}
      '';

      postStop = lib.mkAfter ''
        ${pkgs.nftables}/bin/nft delete table inet internet_accelerator_bypass 2>/dev/null || true
      '';
    };
  };
}
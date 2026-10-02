{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.internet-accelerator;
  settings = cfg.settings;

  markType = lib.types.strMatching "^(0x[0-9a-fA-F]+|[0-9]+)$";

  fwMarkMaskedRuleType = lib.types.submodule {
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

  exactFwMarkRules = map (mark: {
    inherit mark;
    mask = "0xffffffff";
  }) settings.fwMarksBypass.exact;

  maskedFwMarkRules = settings.fwMarksBypass.masked;

  allFwMarkRules = exactFwMarkRules ++ maskedFwMarkRules;

  mkRuleArgs = rule: "fwmark ${rule.mark}/${rule.mask} lookup main";

  mkPriority = i: toString (settings.fwMarksBypass.priority + i);

  mkDeleteIpRule =
    i: rule:
    let
      prio = mkPriority i;
      args = mkRuleArgs rule;
    in
    ''
      while ${pkgs.iproute2}/bin/ip -4 rule del priority ${prio} ${args} 2>/dev/null; do :; done
      while ${pkgs.iproute2}/bin/ip -6 rule del priority ${prio} ${args} 2>/dev/null; do :; done
    '';

  mkAddIpRule =
    i: rule:
    let
      prio = mkPriority i;
      args = mkRuleArgs rule;
    in
    ''
      ${pkgs.iproute2}/bin/ip -4 rule add priority ${prio} ${args}
      ${pkgs.iproute2}/bin/ip -6 rule add priority ${prio} ${args} 2>/dev/null || true
    '';

  deleteIpRules = lib.concatStringsSep "\n" (lib.imap0 mkDeleteIpRule allFwMarkRules);

  addIpRules = lib.concatStringsSep "\n" (lib.imap0 mkAddIpRule allFwMarkRules);

  hasFwMarkRules = allFwMarkRules != [ ];
in
{
  options.services.internet-accelerator = {
    enable = lib.mkEnableOption "Internet Accelerator via Mihomo";

    settings = lib.mkOption {
      type = lib.types.submodule {
        options = {
          mihomo = lib.mkOption {
            type = lib.types.submodule {
              options = {
                secretFile = lib.mkOption {
                  type = lib.types.path;
                  example = lib.literalExpression "./secrets/mihomo.yaml.age";
                  description = ''
                    Agenix secret containing the Mihomo YAML config.
                  '';
                };

                package = lib.mkOption {
                  type = lib.types.package;
                  default = pkgs.mihomo;
                  defaultText = lib.literalExpression "pkgs.mihomo";
                  description = ''
                    Mihomo package to use.
                  '';
                };

                tunDevice = lib.mkOption {
                  type = lib.types.str;
                  default = "mihomo0";
                  example = "mihomo0";
                  description = ''
                    Name of the TUN interface created by Mihomo.

                    This must match `tun.device` in the Mihomo YAML
                    configuration.
                  '';
                };
              };
            };

            default = { };

            description = ''
              Mihomo service integration settings.
            '';
          };

          fwMarksBypass = lib.mkOption {
            type = lib.types.submodule {
              options = {
                priority = lib.mkOption {
                  type = lib.types.int;
                  default = 1000;
                  example = 1000;
                  description = ''
                    Base priority for fwmark bypass policy-routing rules.

                    Lower number means higher priority. If Mihomo creates
                    routing rules with higher priority, lower this value.
                  '';
                };

                exact = lib.mkOption {
                  type = lib.types.listOf markType;
                  default = [ ];
                  example = [
                    "0x51820"
                    "0xca6c"
                  ];
                  description = ''
                    Exact fwmark values that must bypass Mihomo TUN routing.
                  '';
                };

                masked = lib.mkOption {
                  type = lib.types.listOf fwMarkMaskedRuleType;
                  default = [ ];
                  example = [
                    {
                      mark = "0x80000";
                      mask = "0xff0000";
                    }
                    {
                      mark = "0x400";
                      mask = "0xff00";
                    }
                  ];
                  description = ''
                    Masked fwmark match rules.

                    Each rule is translated to:

                      ip rule add fwmark MARK/MASK lookup main
                  '';
                };
              };
            };

            default = { };

            description = ''
              Policy-routing bypass for marked packets.
            '';
          };
        };
      };

      default = { };

      description = ''
        Internet Accelerator service settings.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.networking.nftables.enable && config.networking.networkmanager.enable;

        message = ''
          services.internet-accelerator.enable = true requires
          networking.nftables.enable = true and
          networking.networkmanager.enable = true.
        '';
      }
    ];

    age.secrets."internet-accelerator.yaml".file = settings.mihomo.secretFile;

    services.resolved.enable = lib.mkDefault true;

    security.polkit = {
      enable = true;

      extraConfig = ''
        polkit.addRule(function(action, subject) {
          var mihomoResolvedActions = [
            "org.freedesktop.resolve1.revert",
            "org.freedesktop.resolve1.set-domains",
            "org.freedesktop.resolve1.set-default-route",
            "org.freedesktop.resolve1.set-dns-servers"
          ];

          if (
            mihomoResolvedActions.indexOf(action.id) !== -1 &&
            subject.system_unit == "mihomo.service" &&
            subject.no_new_privileges
          ) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    services.mihomo = {
      enable = true;
      package = settings.mihomo.package;

      tunMode = true;
      processesInfo = true;
      webui = pkgs.metacubexd;

      configFile = config.age.secrets."internet-accelerator.yaml".path;
    };

    networking = {
      nftables.enable = lib.mkDefault true;

      networkmanager = {
        enable = lib.mkDefault true;

        dns = lib.mkDefault "systemd-resolved";

        unmanaged = lib.mkAfter [
          "interface-name:${settings.mihomo.tunDevice}"
        ];
      };
    };

    systemd.services.mihomo = {
      path = [
        pkgs.systemd
      ];

      /*
        services.mihomo with tunMode=true already allows:

          AF_INET AF_INET6 AF_NETLINK

        Add AF_UNIX without replacing the original definition.
        NixOS' systemd unitOption merge logic concatenates definitions
        when at least one of them is a list.
      */
      serviceConfig.RestrictAddressFamilies = lib.mkAfter [
        "AF_UNIX"
      ];

      wants = [
        "systemd-resolved.service"
        "polkit.service"
      ];

      after = [
        "systemd-resolved.service"
        "polkit.service"
      ];
    }
    // lib.optionalAttrs hasFwMarkRules {
      postStart = lib.mkAfter ''
        set -eu

        ${deleteIpRules}
        ${addIpRules}
      '';

      postStop = lib.mkAfter ''
        set -eu

        ${deleteIpRules}
      '';
    };
  };
}

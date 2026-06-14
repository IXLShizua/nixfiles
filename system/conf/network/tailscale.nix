{
  config,
  lib,
  ...
}:

{
  networking.nftables.enable = lib.mkDefault true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  assertions = [
    {
      assertion = config.networking.nftables.enable;
      message = ''
        This Tailscale module requires networking.nftables.enable = true,
        because tailscaled is configured with TS_DEBUG_FIREWALL_MODE=nftables.
      '';
    }
  ];
}
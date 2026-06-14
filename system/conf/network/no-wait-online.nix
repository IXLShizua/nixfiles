{ lib, config, ... }:

{
  systemd.network.wait-online.enable = lib.mkDefault false;
  boot.initrd.systemd.network.wait-online.enable = lib.mkDefault false;

  assertions = [
    {
      assertion =
        !config.systemd.network.wait-online.enable
        && !config.boot.initrd.systemd.network.wait-online.enable;

      message = ''
        This host expects both normal and initrd systemd-networkd wait-online
        to be disabled.
      '';
    }
  ];
}
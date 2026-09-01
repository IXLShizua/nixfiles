{
  networking = {
    hostName = "ixliynez-pc";

    networkmanager.enable = true;
    nftables.enable = true;
    firewall.enable = false;
  };

  services.resolved.enable = true;
}

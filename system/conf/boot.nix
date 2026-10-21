{ pkgs, lib, ... }:

{
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";

      configurationLimit = 3;
    };

    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };

    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';

    kernelPackages = pkgs.linuxPackages;
  };
}

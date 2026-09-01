{ pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';

    kernelPackages = pkgs.linuxPackages;
  };
}

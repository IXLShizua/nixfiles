{
  hardware = {
    enableAllFirmware = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    amdgpu = {
      overdrive.enable = true;
      overdrive.ppfeaturemask = "0xffffffff";
      initrd.enable = true;
    };
  };
}

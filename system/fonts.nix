{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts

      noto-fonts-color-emoji

      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };

      subpixel.rgba = "rgb";

      localConf = ''
        <match target="pattern">
          <edit name="dpi" mode="assign"><double>96</double></edit>
        </match>
      '';
    };
  };
}

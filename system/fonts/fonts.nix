{ pkgs, ... }:

let
  apple-emoji = pkgs.callPackage ./apple-emoji-font.nix { };
in
{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      inter

      noto-fonts
      noto-fonts-color-emoji

      nerd-fonts.jetbrains-mono

      apple-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Apple Color Emoji" "Noto Color Emoji" ];
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

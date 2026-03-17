{ pkgs, ... }:

let
  apple-emoji = pkgs.callPackage ./apple-emoji-font.nix { };
in
{
  fonts = {
    enableDefaultPackages = false;
    
    packages = with pkgs; [
      roboto

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      nerd-fonts.jetbrains-mono

      apple-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "Noto Serif"
          "Noto Serif CJK SC"
        ];
        sansSerif = [
          "Roboto"
          "Noto Sans"
          "Noto Sans CJK SC"
        ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK SC"
        ];
        emoji = [
          "Apple Color Emoji"
          "Noto Color Emoji"
        ];
      };

      antialias = true;
      allowType1 = false;
      allowBitmaps = false;
      useEmbeddedBitmaps = false;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel.lcdfilter = "default";
      subpixel.rgba = "rgb";

      localConf = ''
        <match target="pattern">
          <edit name="dpi" mode="assign"><double>96</double></edit>
        </match>
      '';
    };
  };
}

{ pkgs, ... }:

let
  apple-emoji = pkgs.callPackage ./apple-emoji-font.nix { };
in
{
  fonts = {
    enableDefaultPackages = false;

    packages = with pkgs; [
      roboto
      inter

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
          "Inter"
          "Noto Sans"
          "Noto Serif CJK SC"
          "Noto Serif CJK TC"
          "Noto Serif CJK JP"
          "Noto Serif CJK KR"
        ];

        sansSerif = [
          "Roboto"
          "Noto Sans"
          "Noto Sans CJK SC"
          "Noto Sans CJK TC"
          "Noto Sans CJK JP"
          "Noto Sans CJK KR"
        ];

        monospace = [
          "JetBrainsMonoNL Nerd Font"
          "Noto Sans Mono CJK SC"
          "Noto Sans Mono CJK TC"
          "Noto Sans Mono CJK JP"
          "Noto Sans Mono CJK KR"
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

      subpixel = {
        lcdfilter = "default";
        rgba = "rgb";
      };

      localConf = ''
        <match target="pattern">
          <edit name="dpi" mode="assign"><double>96</double></edit>
        </match>
      '';
    };
  };
}

{ pkgs, stdenvNoCC }:

stdenvNoCC.mkDerivation rec {
  pname = "apple-color-emoji";
  version = "macos-26-20260219-2aa12422";

  src = pkgs.fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/${version}/AppleColorEmoji-Linux.ttf";
    hash = "sha256-U1oEOvBHBtJEcQWeZHRb/IDWYXraLuo0NdxWINwPUxg=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/fonts/truetype/AppleColorEmoji.ttf
    runHook postInstall
  '';

  meta = {
    description = "Apple Color Emoji font for Linux";
    homepage = "https://github.com/samuelngs/apple-emoji-linux";
  };
}

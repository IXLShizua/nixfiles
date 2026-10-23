{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "deckcraft";
  version = "0.9.0";

  src = fetchurl {
    url = "https://github.com/storytold/deckcraft/releases/download/v${version}/deckcraft-${version}-linux-x86_64.AppImage";
    hash = "sha256-RQb41H9E53m3RjqHLg/DX+qZ7t+c7/J2AcjBNEuSigU=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 \
      ${appimageContents}/ai.storyteller.deckcraft.desktop \
      $out/share/applications/ai.storyteller.deckcraft.desktop

    mkdir -p $out/share/icons
    cp -r ${appimageContents}/usr/share/icons/hicolor \
      $out/share/icons/

    mkdir -p $out/share/mime/packages
    cp ${appimageContents}/usr/share/mime/packages/ai.storyteller.deckcraft.xml \
      $out/share/mime/packages/

    mkdir -p $out/share/metainfo
    cp ${appimageContents}/usr/share/metainfo/ai.storyteller.deckcraft.metainfo.xml \
      $out/share/metainfo/
  '';

  meta = {
    description = "Open-source presentation and slide-show editor built in pure Rust";
    homepage = "https://github.com/storytold/deckcraft";
    downloadPage = "https://github.com/storytold/deckcraft/releases";
    changelog = "https://github.com/storytold/deckcraft/releases/tag/v${version}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    mainProgram = "deckcraft";
    platforms = [ "x86_64-linux" ];
  };
}

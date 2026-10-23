{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "wordcraft";
  version = "0.9.0";

  src = fetchurl {
    url = "https://github.com/storytold/wordcraft/releases/download/v${version}/wordcraft-${version}-linux-x86_64.AppImage";
    hash = "sha256-UCKjLR/2LUZBAQwZ/cFrhlUWhoZTevnTBhWgPTTGr7A=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 \
      ${appimageContents}/usr/share/applications/ai.storyteller.wordcraft.desktop \
      $out/share/applications/ai.storyteller.wordcraft.desktop

    mkdir -p $out/share/icons
    cp -r ${appimageContents}/usr/share/icons/hicolor \
      $out/share/icons/

    mkdir -p $out/share/mime/packages
    cp ${appimageContents}/usr/share/mime/packages/ai.storyteller.wordcraft.xml \
      $out/share/mime/packages/

    mkdir -p $out/share/metainfo
    cp ${appimageContents}/usr/share/metainfo/ai.storyteller.wordcraft.metainfo.xml \
      $out/share/metainfo/
  '';

  meta = {
    description = "Open-source word processor built in pure Rust";
    homepage = "https://github.com/storytold/wordcraft";
    downloadPage = "https://github.com/storytold/wordcraft/releases";
    changelog = "https://github.com/storytold/wordcraft/releases/tag/v${version}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    mainProgram = "wordcraft";
    platforms = [ "x86_64-linux" ];
  };
}

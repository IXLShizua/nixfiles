{
  telegram-desktop,
  fetchurl,
}:

let
  unwrapped = telegram-desktop.unwrapped.overrideAttrs {
    version = "7.1.2";

    src = fetchurl {
      url = "https://github.com/telegramdesktop/tdesktop/releases/download/v7.1.2/tdesktop-7.1.2-full.tar.gz";
      hash = "sha256-QVwF74Fb+K5DH/vL0nyqcPaFwDV/zK3CesA1kTkz5eU=";
    };
  };
in
telegram-desktop.override {
  inherit unwrapped;
}

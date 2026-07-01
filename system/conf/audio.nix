{
  services.pipewire = {
    enable = true;
    audio.enable = true;

    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;

    extraConfig.pipewire."10-roc-sink" = {
      "context.modules" = [
        {
          name = "libpipewire-module-roc-sink";
          args = {
            "fec.code" = "rs8m";

            "remote.ip" = "192.168.1.100";
            "remote.source.port" = 10001;
            "remote.repair.port" = 10002;
            "remote.control.port" = 10003;

            "sink.name" = "Roc MacBook";
            "sink.props" = {
              "node.name" = "roc_macbook";
              "node.description" = "Roc MacBook";
              "media.class" = "Audio/Sink";
            };

            "audio.position" = [
              "FL"
              "FR"
            ];
            "log.level" = "DEFAULT";
          };
        }
      ];
    };
  };

  security.rtkit.enable = true;
}

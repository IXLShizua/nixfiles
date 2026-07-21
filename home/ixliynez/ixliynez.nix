{
  config,
  lib,
  pkgs,
  custom,
  ...
}:

{
  imports = [
    ./modules/services/mediamtx.nix
    ./conf/fish/fish.nix
    ./conf/wallpaper.nix
    ./conf/hyprlock.nix
  ];

  home = {
    username = "ixliynez";
    homeDirectory = "/home/ixliynez";
    packages = with pkgs; [
      fastfetch
      nautilus
      xwayland-satellite
      pwvucontrol
      custom.packages.telegram-desktop
      mumble
      loupe
      celluloid
      papers
      qbittorrent
      (prismlauncher.override {
        jdks = [
          zulu8
          zulu11
          zulu17
          zulu21
          zulu25
        ];
        additionalLibs = [
          libxkbcommon
        ];
      })
      termius
      jetbrains.idea
      jetbrains.rider
      android-studio
      antigravity-fhs
      claude-code
    ];

    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 20;
    };

    activation.vicinae-refresh-apps = lib.mkForce ''
      ${pkgs.vicinae}/bin/vicinae deeplink vicinae://launch/core/refresh-apps || true
    '';

    stateVersion = "25.11";
  };

  programs = {
    firefox = {
      enable = true;
      # Remove explicit configPath after update home.stateVersion to >= 26.05
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
      profiles = {
        default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;

          extensions =
            with pkgs.vscode-extensions;
            with custom.packages.community-vscode-extensions;
            [
              mkhl.direnv
              jnoortheen.nix-ide
              bmalehorn.vscode-fish
              coolbear.systemd-unit-file
              kdl-org.kdl
              mhutchie.git-graph
            ];

          userSettings = {
            "editor.fontSize" = 14;
            "editor.fontFamily" = "JetBrainsMono Nerd Font";
            "window.zoomLevel" = 1;

            "nix.enableLanguageServer" = true;
            "nix.serverPath" = "nixd";
            "nix.serverSettings" = {
              "nixd" = {
                "formatting" = {
                  "command" = [ "nixfmt" ];
                };
              };
            };
          };
        };
      };
    };
    git = {
      enable = true;
      settings = {
        safe.directory = [ "/etc/nixos" ];
      };
    };
    direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
    };
    devenv = {
      enable = true;
      enableFishIntegration = true;
    };
    ghostty = {
      enable = true;
      enableFishIntegration = true;
      systemd.enable = true;
      settings = {
        theme = "Adwaita Dark";
        font-family = "JetBrainsMono Nerd Font";
        initial-window = true;
        quit-after-last-window-closed = false;
      };
    };
    vicinae = {
      enable = true;
      systemd.enable = true;
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    };
  };

  services = {
    polkit-gnome.enable = true;
    easyeffects = {
      enable = true;
      package = custom.packages.easyeffects;
    };
    mediamtx = {
      enable = true;
      settings = {
        api = false;
        metrics = false;
        pprof = false;
        playback = false;
        rtsp = false;
        rtmp = false;
        hls = false;
        srt = false;

        paths = {
          all = {
            source = "publisher";
          };
        };

        webrtc = true;
        webrtcAdditionalHosts = [ "100.64.0.1" ];
      };
    };
  };

  xdg = {
    enable = true;

    terminal-exec = {
      enable = true;
      settings.default = [ "com.mitchellh.ghostty.desktop" ];
    };

    mimeApps = {
      enable = true;
      defaultApplications =
        let
          vscode = [ "code.desktop" ];
          browser = [ "firefox.desktop" ];
          fileManager = [ "org.gnome.Nautilus.desktop" ];
          imageViewer = [ "org.gnome.Loupe.desktop" ];
          pdfViewer = [ "org.gnome.Papers.desktop" ];
        in
        {
          "text/plain" = vscode;
          "application/json" = vscode;
          "text/x-shellscript" = vscode;
          "application/x-shellscript" = vscode;
          "application/x-sh" = vscode;

          "text/html" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;

          "inode/directory" = fileManager;

          "image/jpeg" = imageViewer;
          "image/png" = imageViewer;
          "image/gif" = imageViewer;
          "image/webp" = imageViewer;
          "image/svg+xml" = imageViewer;

          "application/pdf" = pdfViewer;
          "application/x-pdf" = pdfViewer;
          "image/vnd.djvu" = pdfViewer;
          "application/postscript" = pdfViewer;
          "application/oxps" = pdfViewer;
          "application/vnd.ms-xpsdocument" = pdfViewer;
        };
    };
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };

    font = {
      name = "Adwaita Sans";
      size = 11;
      package = pkgs.adwaita-fonts;
    };

    gtk3 = {
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    gtk4 = {
      theme = null;
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  xresources.properties = {
    "Xft.dpi" = 96;
  };
}

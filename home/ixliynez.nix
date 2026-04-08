{
  lib,
  pkgs,
  pkgs-easyeffects,
  ...
}:

{
  imports = [
    ./modules/services/mediamtx.nix
    ./fish/fish.nix
    ./hyprlock/hyprlock.nix
  ];

  home = {
    username = "ixliynez";
    homeDirectory = "/home/ixliynez";
    packages = with pkgs; [
      fastfetch
      nautilus
      xwayland-satellite
      pwvucontrol
      telegram-desktop
      mumble
      loupe
      qbittorrent
      (prismlauncher.override {
        jdks = [
          zulu8
          zulu17
          zulu21
          zulu25
        ];
      })
      termius
      jetbrains.idea
      jetbrains.rider
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
    firefox.enable = true;
    vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
      profiles = {
        default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;

          extensions = with pkgs.vscode-extensions; [
            mkhl.direnv
            jnoortheen.nix-ide
            bmalehorn.vscode-fish
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
    git.enable = true;
    direnv = {
      enable = true;
      enableFishIntegration = true;
      nix-direnv.enable = true;
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
    awww.enable = true;
    easyeffects = {
      enable = true;
      package = pkgs-easyeffects.easyeffects;
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
          "all" = {
            source = "publisher";
          };
        };

        webrtc = true;
        webrtcAdditionalHosts = [ "100.64.0.1" ];
      };
    };
  };

  xdg = {
    portal = {
      enable = true;
      config.common.default = "gnome";
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
      ];
    };

    terminal-exec = {
      enable = true;
      settings.default = [ "com.mitchellh.ghostty.desktop" ];
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "code.desktop" ];
        "application/json" = [ "code.desktop" ];
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
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
  };

  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };

  xresources.properties = {
    "Xft.dpi" = 96;
  };
}

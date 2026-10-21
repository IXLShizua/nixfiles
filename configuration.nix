{
  pkgs,
  custom,
  ...
}:

{
  imports = [
    ./system/conf/disk-config.nix
    ./system/conf/hardware-configuration.nix

    ./system/conf/boot.nix
    ./system/conf/hardware.nix

    ./system/conf/virtualisation.nix

    ./system/conf/audio.nix

    ./system/conf/fonts/fonts.nix

    ./system/conf/i18n.nix

    ./system/conf/network/networking.nix
    ./system/conf/network/internet-accelerator.nix
    ./system/conf/network/no-wait-online.nix
    ./system/conf/network/tailscale.nix
    ./system/conf/network/kantets-wg-home.nix

    ./system/modules/network/accelerator.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;
  };

  time.timeZone = "Asia/Yekaterinburg";

  users.users = {
    ixliynez = {
      isNormalUser = true;
      home = "/home/ixliynez";
      shell = pkgs.fish;

      extraGroups = [
        "wheel"
        "libvirtd"
        "docker"
        "gamemode"
      ];
    };
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    lact.enable = true;
    gvfs.enable = true;
  };

  programs = {
    nix-ld.enable = true;
    niri = {
      enable = true;
      useNautilus = true;
    };
    dconf.enable = true;
    tmux.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        set fish_prompt_pwd_dir_length 0
      '';
    };
    nix-index-database.comma.enable = true;
    virt-manager.enable = true;
    steam.enable = true;
    gamescope.enable = true;
  };

  environment = {
    variables = {
      VISUAL = "micro";
      EDITOR = "micro";
    };

    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";

      # Do not set the GDK_BACKEND environment variable globally as this will break the screencast portal.
      # Read: https://niri-wm.github.io/niri/Important-Software.html#portals
      # GDK_BACKEND = "wayland,x11";

      QT_QPA_PLATFORM = "wayland;xcb";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    systemPackages =
      with pkgs;
      [
        micro
        btop
        fastfetch
        jq

        nixd
        nixfmt

        distrobox

        mangohud
        heroic
        wineWow64Packages.staging
        winetricks

        sbctl
      ]
      ++ [ custom.packages.agenix ];

    etc."micro/settings.json".text = builtins.toJSON {
      mkparents = true;
    };
  };

  # The first version of NixOS installed on this particular computer.
  system.stateVersion = "25.11";
}

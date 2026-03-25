{
  pkgs,
  agenixDefault,
  customSecretsPath,
  ...
}:

{
  imports = [
    ./system/hardware-configuration.nix
    ./system/boot.nix
    ./system/hardware.nix
    ./system/fonts/fonts.nix
    ./system/internet/accelerator/accelerator.nix
    ./system/internet/kantets-wg-home.nix
    ./system/internet/ivan-pc-nixos.nix
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

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
    lact.enable = true;
    pipewire.enable = true;
    gvfs.enable = true;
    internet-accelerator = {
      enable = true;
      secretFile = customSecretsPath + /internet-accelerator.json.age;
    };
  };

  programs = {
    nix-ld.enable = true;
    niri.enable = true;
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
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;

  virtualisation.docker.enable = true;

  users.users = {
    ixliynez = {
      isNormalUser = true;
      home = "/home/ixliynez";
      extraGroups = [
        "wheel"
        "libvirtd"
        "docker"
      ];
      shell = pkgs.fish;
    };
  };

  environment = {
    variables = {
      VISUAL = "micro";
      EDITOR = "micro";

      COMMA_PICKER = "fzf";

      FZF_DEFAULT_OPTS = "--height 40% --layout=reverse --border";
      FZF_DEFAULT_COMMAND = "fd --type f --hidden --exclude .git";
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

    systemPackages = with pkgs; [
      micro
      btop
      fastfetch

      fd
      fzf
      bat

      nixd
      nixfmt

      agenixDefault

      fishPlugins.fzf-fish
    ];

    etc."micro/settings.json".text = builtins.toJSON {
      mkparents = true;
    };
  };

  networking = {
    hostName = "ixliynez-pc";
    networkmanager.enable = true;
    firewall.enable = false;
    nftables.enable = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  systemd.services.tailscaled.serviceConfig.Environment = [
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;

  # The first version of NixOS installed on this particular computer.
  system.stateVersion = "25.11";
}

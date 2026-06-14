{ lib, pkgs, ... }:

let
  wallpaper = ./assets/flowers.jpg;
  awww = lib.getExe pkgs.awww;
in
{
  services.awww.enable = true;

  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Set user wallpaper";

      After = [
        "awww.service"
        "graphical-session.target"
      ];
      Requires = [ "awww.service" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${awww} img ${wallpaper}";
      ExecStop = "${awww} clear";

      Type = "oneshot";
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

{ ... }:

{
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/3afe3866-e77b-4b6f-8636-f1a98d90ba54";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.automount"
      "x-systemd.idle-timeout=10min"
      "x-gvfs-show"
      "x-gvfs-name=Samsung-NVMe"
    ];
  };
}
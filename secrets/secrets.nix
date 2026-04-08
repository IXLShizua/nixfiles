let
  ixliynez = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIuehMYgE8O89V9zkqjqQO/VLKKOgz2mPbZpppAutTZ7";
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE9iM5pgj4+ZR8RYXxc0M6BiHCITjyVEaVOYixZBYmTD";

  secretDefaultConfig = {
    publicKeys = [
      ixliynez
      system
    ];
    armor = true;
  };
in
{
  "kantets-wg-home.conf.age" = secretDefaultConfig;
  "internet-accelerator.json.age" = secretDefaultConfig;
}

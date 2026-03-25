{ config, customSecretsPath, ... }:

{
  age.secrets."ivan-pc-nixos.conf".file = customSecretsPath + /ivan-pc-nixos.conf.age;

  networking.wg-quick.interfaces.ivan-pc-nixos = {
    autostart = false;
    configFile = config.age.secrets."ivan-pc-nixos.conf".path;
  };
}

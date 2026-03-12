{ config, customSecretsPath, ... }:

{
  age.secrets."kantets-wg-home.conf".file = customSecretsPath + /kantets-wg-home.conf.age;

  networking.wg-quick.interfaces.kantets-wg-home = {
    autostart = false;
    configFile = config.age.secrets."kantets-wg-home.conf".path;
  };
}

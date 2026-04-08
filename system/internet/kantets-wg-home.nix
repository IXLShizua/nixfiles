{ config, custom, ... }:

{
  age.secrets."kantets-wg-home.conf".file = custom.fromSecretsDir /kantets-wg-home.conf.age;

  networking.wg-quick.interfaces.kantets-wg-home = {
    autostart = false;
    configFile = config.age.secrets."kantets-wg-home.conf".path;
  };
}

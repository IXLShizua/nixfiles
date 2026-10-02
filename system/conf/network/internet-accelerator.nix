{ custom, ... }:

let
  mihomoZapretMark = "0x10000000";
  zapretOutputMark = "0x40000000";
  zapretQueue = 200;
in
{
  services = {
    internet-accelerator = {
      enable = true;

      settings = {
        mihomo = {
          secretFile = custom.lib.fromSecretsDir /internet-accelerator.yaml.age;
        };

        fwMarksBypass = {
          priority = 1000;
          exact = [ "0xca6c" ];
          masked = [
            {
              mark = "0x80000";
              mask = "0xff0000";
            }
            {
              mark = "0x400";
              mask = "0xff00";
            }
          ];
        };
      };
    };
    zapret2 = {
      enable = true;

      files = [
        "zapret-lib"
        "zapret-antidpi"
        "zapret-auto"
      ];

      firewall = {
        configureAutomatically = false;
        queue = zapretQueue;
        desyncFwmark = zapretOutputMark;
      };

      extraOptions = [
        "--bind-fix4"
      ];

      profiles.https.parameters = [
        "--filter-mark=${mihomoZapretMark}"
        "--filter-tcp=443"
        "--filter-l7=tls"

        "--out-range=-d10"
        "--payload=tls_client_hello"

        "--lua-desync=circular:fails=2:maxtime=30:retrans=2:maxseq=16384:reset"

        "--lua-desync=wssize:wsize=1:scale=6"
        "--lua-desync=multidisorder:pos=1,midsld:strategy=1"

        "--lua-desync=wssize:wsize=1:scale=6"
        "--lua-desync=multisplit:pos=10:seqovl=1:strategy=2"

        "--lua-desync=wssize:wsize=1:scale=6"
        "--lua-desync=multidisorder:pos=1,sniext+1,host+1,midsld-2,midsld,midsld+2,endhost-1:strategy=3"
      ];
    };
  };

  networking.nftables = {
    tables.zapret2 = {
      family = "inet";

      content = ''
        chain output {
          type filter hook output priority -401; policy accept;

          meta mark & ${zapretOutputMark} != 0 notrack
        }

        chain postrouting {
          type filter hook postrouting priority 101; policy accept;

          meta mark & ${mihomoZapretMark} != 0 \
            meta mark & ${zapretOutputMark} == 0 \
            ct mark set ct mark | ${mihomoZapretMark}

          ct mark & ${mihomoZapretMark} != 0 \
            ct original packets 1-20 \
            queue num ${toString zapretQueue} bypass
        }

        chain prerouting {
          type filter hook prerouting priority -101; policy accept;

          ct mark & ${mihomoZapretMark} != 0 \
            ct reply packets 1-20 \
            queue num ${toString zapretQueue} bypass
        }
      '';
    };
  };
}

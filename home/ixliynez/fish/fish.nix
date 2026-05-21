{
  programs.fish = {
    enable = true;
    functions = {
      fish_prompt.body = builtins.readFile ./prompt.fish;

      __rund_get_session_name.body = builtins.readFile ./rund/__rund_get_session_name.fish;
      rund.body = builtins.readFile ./rund/rund.fish;
      lsrund.body = builtins.readFile ./rund/lsrund.fish;
      stoprund.body = builtins.readFile ./rund/stoprund.fish;
    };
  };
}

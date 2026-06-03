{ pkgs, ... }:

{
  programs.fish = {
    enable = true;

    functions = {
      fish_prompt.body = builtins.readFile ./prompt.fish;
    };

    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
    ];

    interactiveShellInit = ''
      fzf_configure_bindings \
        --directory= \
        --git_log= \
        --git_status= \
        --history=ctrl-r \
        --processes= \
        --variables=ctrl-v
    '';
  };

  programs.fzf = {
    enable = true;

    enableFishIntegration = false;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };
}

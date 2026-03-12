if not type -q tmux
    echo (set_color -o brred)"[!]" (set_color normal)"tmux is not installed."
    return 1
end

if test (count $argv) -eq 0
    echo (set_color -o brred)"[!]" (set_color normal)"Command required. Example:" (set_color -o)"rund idea ./"(set_color normal)
    return 1
end

set -l session_name (__rund_get_session_name $argv)

if test "$session_name" = error
    echo (set_color -o brred)"[!]" (set_color normal)"Error: sha256sum or shasum is required on your system."
    return 1
end

if tmux has-session -t $session_name 2>/dev/null
    tmux kill-session -t $session_name
    echo (set_color -o bryellow)"[*]" (set_color normal)"Killed previous job session."
end

tmux new-session -d -s $session_name $argv
tmux set-option -t $session_name @rund_cmd "$argv" >/dev/null 2>&1

echo (set_color -o brgreen)"[+]" (set_color normal)"Background job started!"
echo (set_color -o brcyan)"[i]" (set_color normal)"Session name (tmux):" (set_color -o 4a90e2)$session_name(set_color normal)

if test (count $argv) -eq 0
    echo (set_color -o brred)"[!]" (set_color normal)"Command required. Specify the exact command or session name."
    echo (set_color -o brcyan)"[i]" (set_color normal)"Examples:" (set_color -o)"stoprund idea ./" (set_color normal)"or" (set_color -o)"stoprund rund_12345678"(set_color normal)
    echo ""
    lsrund
    return 1
end

set -l session_name

if string match -q "rund_*" "$argv[1]"
    set session_name $argv[1]
else
    set session_name (__rund_get_session_name $argv)

    if test "$session_name" = error
        echo (set_color -o brred)"[!]" (set_color normal)"Error: sha256sum or shasum is required."
        return 1
    end
end

if tmux has-session -t $session_name 2>/dev/null
    tmux kill-session -t $session_name
    echo (set_color -o brgreen)"[+]" (set_color normal)"Successfully stopped job:" (set_color -o 4a90e2)$session_name(set_color normal)
else
    echo (set_color -o brred)"[!]" (set_color normal)"Job not found or already stopped:" (set_color -o 4a90e2)$session_name(set_color normal)
    echo (set_color -o brcyan)"[i]" (set_color normal)"Run" (set_color -o)"lsrund"(set_color normal) "to see active jobs."
    return 1
end

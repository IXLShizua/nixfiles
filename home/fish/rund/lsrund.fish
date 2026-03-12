set -l sessions (tmux ls -F "#{session_name}:::#{session_path}:::#{@rund_cmd}" 2>/dev/null)
set -l found 0

for session in $sessions
    set -l parts (string split -m 2 ":::" "$session")

    if test "$parts[2]" = "$PWD"; and string match -q "rund_*" "$parts[1]"
        if test $found -eq 0
            echo (set_color -o brgreen)"[+]" (set_color normal)"Active jobs in" (set_color -o)(basename $PWD)(set_color normal)":"
            set found 1
        end

        echo "  • "(set_color -o 4a90e2)$parts[1](set_color normal)

        set -l cmd_str "(command unknown)"
        test -n "$parts[3]"; and set cmd_str "$parts[3]"

        echo "      "(set_color brblack)"↳ $cmd_str"(set_color normal)
    end
end

if test $found -eq 0
    echo (set_color -o bryellow)"[i]" (set_color normal)"No active background jobs in" (set_color -o)(basename $PWD)(set_color normal)"."
end

set -l bin_path (command -s $argv[1] 2>/dev/null; or echo $argv[1])
set -l hash_input "$PWD|$bin_path|"(string join " " $argv[2..-1])

set -l hash
if type -q sha256sum
    set hash (echo -n "$hash_input" | sha256sum | string sub -l 16)
else if type -q shasum
    set hash (echo -n "$hash_input" | shasum -a 256 | string sub -l 16)
else
    echo error
    return 1
end

echo "rund_$hash"

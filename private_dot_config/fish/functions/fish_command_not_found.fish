# From https://github.com/Homebrew/homebrew-command-not-found/blob/master/handler.fish
# The homebrew-command-not-found tap will automatically be installed on the first invocation.

function fish_command_not_found
    set -l cmd $argv[1]
    set -l txt (brew which-formula --explain $cmd 2> /dev/null)

    if test -z "$txt"
        __fish_default_command_not_found_handler $cmd
    else
        string collect $txt
    end
end

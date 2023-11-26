function abbr_install
    set -l cmd (commandline -po)
    if string match -rq 'brew|composer|npm' $cmd[1]
        echo install
    else
        return 1
    end
end

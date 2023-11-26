function abbr_zap
    set -l cmd (commandline -po)
    if test "$cmd[1]" = brew
        echo "uninstall --zap"
    else if test "$cmd[1]" = zap
        echo "brew uninstall --zap"
    else
        return 1
    end
end

function llog --description "print the location to laravel's log file"
    if test -n "$(find storage/logs -name 'laravel-*-*-*.log' -print -quit)"
        echo storage/logs/laravel-(date +%F).log
    else if test -f storage/logs/laravel.log
        echo storage/logs/laravel.log
    else
        echo "No Laravel log file found" > /dev/stderr
        return 1
    end
end

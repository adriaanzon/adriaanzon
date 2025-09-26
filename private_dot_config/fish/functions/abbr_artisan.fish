function abbr_artisan
    if type -q sail
        echo "sail artisan"
    else if test -f artisan
        echo "php artisan"
    else
        return 1
    end
end

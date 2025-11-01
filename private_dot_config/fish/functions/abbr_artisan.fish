function abbr_artisan
    if test -x develop
        # Execute artisan in a project with a develop script
        # https://serversforhackers.com/c/div-the-workflow
        echo "./develop artisan"
    else if test -f artisan
        # Execute artisan directly
        echo "php artisan"
    else
        return 1
    end
end

function abbr_develop --description 'Run a developer tool using docker wrapper script if available'
    if test -x develop
        # Execute the command in a project with a develop script
        # https://serversforhackers.com/c/div-the-workflow
        echo ./develop $argv
    else
        # Fallback to the command directly
        return 1
    end
end

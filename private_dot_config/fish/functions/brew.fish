function brew --description 'brew wrapper'
    command brew $argv

    # Update the fish greeting after updating or upgrading. This will also run
    # after the brew command failed, since brew will also exit with an error
    # code when that most packages ugpraded but only some failed. The command
    # will be run in the background to prevent slowing down the update command.
    if contains -- "$argv" update upgrade
        update-fish-greeting --no-brew-update &
    end
end

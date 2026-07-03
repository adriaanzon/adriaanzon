function claude --description 'claude wrapper'
    #set -lx DISABLE_AUTOUPDATER 1
    set -lx CLAUDE_AFK_TIMEOUT_MS 86400000

    command claude $argv
end

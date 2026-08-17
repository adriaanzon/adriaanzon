function claude --description 'claude wrapper'
    #set -lx DISABLE_AUTOUPDATER 1
    set -lx CLAUDE_AFK_TIMEOUT_MS 86400000
    set -lx CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY 1
    set -lx CLAUDE_CODE_DISABLE_AGENT_VIEW 1

    command claude $argv
end

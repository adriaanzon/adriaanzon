# This function enhances fish's default ctrl+g keybinding, by adding command
# line editing in vim when outside of the completion pager.
function binding_edit
    if commandline --paging-mode
        # Cancel pager (default behavior of ctrl+g in fish)
        commandline -f cancel
    else
        # Edit command line in vim
        edit_command_buffer
    end
end

# This function enhances fish's default ctrl+s keybinding, by adding file
# search when outside of the completion pager.
function binding_search
    if commandline --paging-mode
        # Search completion result (default behavior of ctrl+s in fish)
        commandline -f pager-toggle-search
    else
        # Search files relative to current directory
        fzf-file-widget
    end
end

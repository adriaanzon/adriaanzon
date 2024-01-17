function fish_user_key_bindings
    # Add fzf's ctrl+r keybinding. Its other keybindings, ctrl+t and option-c,
    # are erased, to restore the Fish's default behavior for these keys. Fzf's
    # file widget is still bound as an extension to fish's ctrl+s binding.
    fzf_key_bindings
    bind --erase \ct
    bind --erase \ec
    bind \cs binding_search
end

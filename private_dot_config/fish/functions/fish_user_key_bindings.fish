function fish_user_key_bindings
  fzf_key_bindings

  # Only use fzf's ctrl+r binding
  bind --erase \ct
  bind --erase \ec
end

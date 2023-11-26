function d --description 'Edit dotfiles'
    set -l file (chezmoi managed --include files | fzf --select-1 --query "$argv")
    and chezmoi edit --apply --verbose ~/"$file"
end

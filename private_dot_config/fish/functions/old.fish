function old --description "Search and view an old file from git history"
    # Pick a deleted file
    set -l file (git log --all --pretty=format: --name-only --diff-filter=D \
        | awk '!x[$0]++' \
        | fzf --query "$argv")
    test -z "$file"; and return 1

    # Find the last commit where it existed
    set -l commit (git rev-list -1 --all -- "$file")
    test -z "$commit"; and echo "File not found in git history" >&2; and return 1

    # Check if file exists in this commit, if not use the parent commit
    if not git cat-file -e "$commit:$file" 2>/dev/null
        set commit "$commit^"
    end

    # Copy GitHub URL to clipboard in background
    if command -q gh; and command -q pbcopy
        gh browse --no-browser --commit=$commit "$file" 2>/dev/null | pbcopy &
    end

    # Show the file contents in Neovim
    git show "$commit:$file" | nvim -R -c "file $file" -c "filetype detect" -c "nnoremap <buffer> q :quit<CR>"
end

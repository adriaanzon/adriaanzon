function abbr_git_switch_master
    if git show-ref --quiet refs/heads/master
        echo 'git switch master'
    else if git show-ref --quiet refs/heads/main
        echo 'git switch main'
    else
        echo 'Warning: no master or main branch found' >&2
        return 1
    end
end

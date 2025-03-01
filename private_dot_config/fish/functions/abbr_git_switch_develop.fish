function abbr_git_switch_develop
    if git show-ref --quiet refs/heads/develop
        echo 'git switch develop'
    else
        echo 'Warning: no develop branch found' >&2
        return 1
    end
end

function git
    # Store the first non-option argument in $subcommand variable
    for subcommand in $argv
        not string match -qr -- '^-' $subcommand
        and break
    end

    # When running any subcommand that usually creates a commit, confirm the committer.
    if contains -- "$subcommand" commit merge rebase cherry-pick revert am apply
        _git_confirm_committer
        or return
    end

    # When running subcommands that deliberately create a commit, check the license year.
    if contains -- "$subcommand" commit cherry-pick revert am apply
        _git_license_year
        or return
    end

    # For subcommands that can fail because a branch is already checked out in
    # another worktree, catch that error and offer to jump to or free it.
    if contains -- "$subcommand" worktree checkout switch
        _git_run_catching_worktree_collision $argv
        return
    end

    command git $argv
end

# Run git, and on a "branch already used by worktree" error (status 128), offer to
# cd to that worktree or detach its HEAD to free the branch.
function _git_run_catching_worktree_collision
    set -l stderr_file (mktemp)
    command git $argv 2>$stderr_file
    set -l git_status $status
    cat $stderr_file >&2

    set -l worktree (string match -rg "is already used by worktree at '(.+)'" <$stderr_file)
    rm -f $stderr_file

    test $git_status -ne 0 -a -n "$worktree"
    or return $git_status

    switch (read -n1 --prompt-str "[c]d to $(basename $worktree), [d]etach it, [e]xchange, or [n]o? (c/d/e/N) ")
        case c C y Y
            cd $worktree
            return
        case d D
            command git -C $worktree checkout --detach
            and command git $argv
            return
        case e E
            # Swap branches: move the other worktree onto our branch, then take the
            # requested branch here. Detach here first so our branch is free to move.
            set -l current_branch (command git branch --show-current)
            command git checkout --detach
            and command git -C $worktree checkout $current_branch
            and command git $argv
            return
    end
    return $git_status
end

# Confirm whether I want to commit with the currently configured email.
function _git_confirm_committer
    set name (command git config user.name)
    set email (command git config user.email)
    set previously_used_email (git log --all --author="$name" --oneline -n1 --pretty=format:'%ae')

    test "$email" = "$previously_used_email"
    and return 0

    if test -n "$previously_used_email"
        set confirmation "This email ($email) does not match the email of your previous commit ($previously_used_email)."\n"Do you wish to continue? (y/N) "
    else
        set confirmation "You haven't commited to this repository before."\n"Do you wish to continue with $email? (y/N) "
    end

    # When the user wants to continue using the unknown email, return zero to continue committing.
    contains -- "$(read -n1 --prompt-str "$confirmation")" y Y
    and return 0

    # Allow changing the email and continue committing.
    test -n "$previously_used_email"
    and contains -- "$(read -n1 --prompt-str "Do you want to change the email of this repository to $previously_used_email and continue? (y/N) ")" y Y
    and git config --local user.email "$previously_used_email"
    and return 0

    # Return non-zero to abort committing.
    return 1
end

# Warn when LICENSE year is outdated
function _git_license_year
    # Find a license with an outdated year. Return zero when it isn't found, to continue committing.
    set -l file (rg "(?!.*$(date +%Y))Copyright.*\d{4}.*Adriaan Zonnenberg" (git rev-parse --show-toplevel) --glob='LICENSE*' --max-depth=1 --pcre2 --files-with-matches | head -n1)
    test $pipestatus[1] -eq 0
    or return 0

    set basename (basename $file)

    contains -- "$(read -n1 --prompt-str "The $basename file doesn't contain the current year."\n"Do you wish to continue? (y/N) ")" y Y
    and return 0

    contains -- "$(read -n1 --prompt-str "Do you want to edit $basename and continue? (y/N) ")" y Y
    and $EDITOR $file
    and git add $file
    and return 0

    # Return non-zero to abort committing.
    return 1
end

function git
    # Store the first non-option argument in $subcommand variable
    for subcommand in $argv
        not string match -qr -- '^-' $subcommand
        and break
    end

    if test $subcommand = commit
        _git_confirm_committer
        or return

        _git_license_year
        or return
    end

    command git $argv
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
    string match -qr -- '^y' (read --prompt-str "$confirmation")
    and return 0

    # Allow changing the email and continue committing.
    test -n "$previously_used_email"
    and string match -qr -- '^y' (read --prompt-str "Do you want to change the email of this repository to $previously_used_email and continue? (y/N) ")
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

    string match -qr -- '^y' (read --prompt-str "The $basename file doesn't contain the current year."\n"Do you wish to continue? (y/N) ")
    and return 0

    string match -qr -- '^y' (read --prompt-str "Do you want to edit $basename and continue? (y/N) ")
    and $EDITOR $file
    and git add $file
    and return 0

    # Return non-zero to abort committing.
    return 1
end

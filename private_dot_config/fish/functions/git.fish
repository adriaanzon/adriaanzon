function git
    # Store the first non-option argument in $subcommand variable
    for subcommand in $argv
        not string match -qr -- '^-' $subcommand
        and break
    end

    if test $subcommand = commit
        _git_confirm_committer
        or return
    end

    command git $argv
end

# Confirm whether I want to commit with the currently configured email.
function _git_confirm_committer
    set name (command git config user.name)
    set email (command git config user.email)
    set previously_used_email (git log --all --author="$name" --oneline -n1 --pretty=format:'%ae')

    if test "$email" != "$previously_used_email"
        if test -n "$previously_used_email"
            set confirmation "This email ($email) does not match the email of your previous commit ($previously_used_email)."\n"Do you wish to continue? (y/N) "
        else
            set confirmation "You haven't commited to this repository before."\n"Do you wish to continue with $email? (y/N) "
        end

        # Trigger a confirmation
        read confirmed --prompt-str "$confirmation"

        if string match -qr -- '^y' $confirmed
            # When the user wants to continue using the unknown email, return zero.
            return 0
        else if test -n "$previously_used_email"
            read confirmed_email_change --prompt-str "Do you want to change the email of this repository to $previously_used_email and continue? (y/N) "

            if string match -qr -- '^y' $confirmed_email_change
                git config --local user.email "$previously_used_email"

                # Return zero after successfully changing the email, to continue committing.
                and return 0
            end
        end

        # Return non-zero to abort committing.
        return 1
    end
end

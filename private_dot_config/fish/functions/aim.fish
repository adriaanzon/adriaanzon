function aim --description 'Prepare a commit message'
    set -l root (git rev-parse --show-toplevel)
    or return $status

    set -l template (git config commit.template)

    if test -n "$template" && not test -f $root/.git/commit_msg_aim.txt
        nvim "+file $root/.git/commit_msg_aim.txt" "+setf gitcommit" < $root/$template
    else
        nvim "+setf gitcommit" $root/.git/commit_msg_aim.txt
    end
end

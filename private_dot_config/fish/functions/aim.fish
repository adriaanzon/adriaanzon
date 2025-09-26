function aim --description 'Prepare a commit message'
    set -l root (git rev-parse --show-toplevel)
    or return $status

    set -l git_dir (git rev-parse --git-dir)
    or return $status

    set -l template (git config commit.template)

    if test -n "$template" && not string match -q "/*" $template
        set template "$root/$template"
    end

    if test -n "$template" && not test -f $git_dir/commit_msg_aim.txt
        nvim "+file $git_dir/commit_msg_aim.txt" "+setf gitcommit" < $template
    else
        nvim "+setf gitcommit" $git_dir/commit_msg_aim.txt
    end
end

function fire --description 'Commit using the prepared commit message'
    set -l git_dir (git rev-parse --git-dir)
    or return $status

    if test -f $git_dir/commit_msg_aim.txt
        git commit --template $git_dir/commit_msg_aim.txt --allow-empty-message $argv
        and rm $git_dir/commit_msg_aim.txt
    else
        git commit $argv
    end
end

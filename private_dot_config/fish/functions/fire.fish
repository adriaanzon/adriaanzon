function fire --description 'Commit using the prepared commit message'
    set -l root (git rev-parse --show-toplevel)
    or return $status

    if test -f $root/.git/commit_msg_aim.txt
        git commit --template $root/.git/commit_msg_aim.txt --allow-empty-message $argv
        and rm $root/.git/commit_msg_aim.txt
    else
        git commit $argv
    end
end

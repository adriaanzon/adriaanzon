function abbr_develop --description 'Register an abbreviation that uses ./develop wrapper when available'
    set -l name $argv[1]
    set -l cmd $argv[2..]
    function abbr_$name --inherit-variable cmd
        if test -x develop
            echo ./develop $cmd
        else
            echo $cmd
        end
    end
    abbr -g $name --function abbr_$name
end

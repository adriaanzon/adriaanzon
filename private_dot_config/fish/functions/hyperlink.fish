function hyperlink
    set -l text $argv[1]
    set -l url $argv[2]

    echo -e "\033]8;;$url\a$text\033]8;;\a"
end

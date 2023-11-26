function multicd --description "Expand parent directories based on the number of dots. This function is used as an abbreviation function."
    echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end

# Activate a Python virtual environment. Accepts a location to the virtualenv
# as the first argument, defaulting to '.venv' in the current directory. Creates
# the virtualenv if it does not yet exist.
function activate
    set -l location $argv[1] .venv

    test -d $location[1] || uv venv $location[1]

    and source $location[1]/bin/activate.fish
end

# State check: rg on PATH must resolve to the guard wrapper in a real login
# shell. If PATH order regresses, the wrapper silently stops protecting
# anything, no matter how correct it is.

function test_login_shell_resolves_rg_to_the_wrapper
    set -l resolved (fish -l -c 'command -v rg' 2>/dev/null | tail -n1)
    assert_eq $HOME/.local/bin/rg "$resolved"
end

# Tests for dot_local/bin/executable_rg (the ripgrep -r guard wrapper).
# Runs the source file directly, so this validates the repo before apply.

set -g wrapper (path resolve (status dirname)/../../dot_local/bin/executable_rg)

if not test -x /opt/homebrew/bin/rg
    echo "  precondition failed: /opt/homebrew/bin/rg not found (the wrapper delegates to it)" >&2
    exit 1
end

set -g dir (mktemp -d)
echo "needle here" >$dir/sample.txt
echo "text with -rln inside" >$dir/dashes.txt
set -g err $dir/stderr

function teardown
    rm -rf $dir
end

# --- The -r refusal ---

function test_rln_cluster_with_stderr_suppressed_explains_on_stdout
    set -l out (fish $wrapper -rln needle $dir 2>/dev/null | string collect)
    set -l code $pipestatus[1]
    assert_eq 2 $code
    assert_match 'refusing to run.*--replace' "$out"
end

function test_rln_cluster_without_redirect_explains_on_stderr_only
    set -l out (fish $wrapper -rln needle $dir 2>$err | string collect)
    set -l code $pipestatus[1]
    assert_eq 2 $code
    assert_empty "$out"
    assert_match 'refusing to run.*--replace' (string collect <$err)
end

function test_bare_r_flag_is_refused
    set -l out (fish $wrapper -r foo needle $dir 2>/dev/null | string collect)
    set -l code $pipestatus[1]
    assert_eq 2 $code
    assert_match 'refusing to run' "$out"
end

# --- Normal operation must be untouched ---

function test_normal_search_finds_matches
    set -l out (fish $wrapper -l needle $dir 2>$err | string collect)
    set -l code $pipestatus[1]
    assert_eq 0 $code
    assert_match 'sample\.txt' "$out"
    assert_empty (string collect <$err)
end

function test_no_match_exits_1_with_no_output
    set -l out (fish $wrapper nonexistent_string_xyz $dir 2>$err | string collect)
    set -l code $pipestatus[1]
    assert_eq 1 $code
    assert_empty "$out"
end

function test_explicit_replace_passes_through
    set -l out (fish $wrapper --replace XXX needle $dir 2>$err | string collect)
    set -l code $pipestatus[1]
    assert_eq 0 $code
    assert_match XXX "$out"
end

function test_literal_rln_pattern_after_separator_searches_normally
    set -l out (fish $wrapper -l -- -rln $dir 2>$err | string collect)
    set -l code $pipestatus[1]
    assert_eq 0 $code
    assert_match 'dashes\.txt' "$out"
end

# --- The \| no-match hint ---

function test_backslash_pipe_hint_stays_on_stderr_normally
    set -l out (fish $wrapper 'foo\|bar' $dir 2>$err | string collect)
    set -l code $pipestatus[1]
    assert_eq 1 $code
    assert_empty "$out"
    assert_match alternation (string collect <$err)
end

function test_backslash_pipe_hint_moves_to_stdout_when_stderr_suppressed
    set -l out (fish $wrapper 'foo\|bar' $dir 2>/dev/null | string collect)
    set -l code $pipestatus[1]
    assert_eq 1 $code
    assert_match alternation "$out"
end

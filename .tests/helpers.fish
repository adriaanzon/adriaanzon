# Assertion helpers for .tests. Sourced by driver.fish before each test file.
#
# Assertions are silent on success; the driver prints one ✅/❌ line per test_*
# function. On failure they print the ❌ line (once) plus a detail line, so
# details always appear under the test they belong to.

function _test_fail
    if test $_current_test_failed -eq 0
        echo "  ❌ $_current_test"
    end
    set -g _current_test_failed 1
end

function assert_eq --argument-names expected actual
    test "$expected" = "$actual"; and return
    _test_fail
    echo "      expected '$expected', got '$actual'"
end

function assert_match --argument-names pattern actual
    string match -rq -- $pattern $actual; and return
    _test_fail
    echo "      expected match for '$pattern', got '$actual'"
end

function assert_empty --argument-names actual
    test -z "$actual"; and return
    _test_fail
    echo "      expected empty, got '$actual'"
end

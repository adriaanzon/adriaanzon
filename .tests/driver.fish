# Runs one *.test.fish file. Used by ./run — not meant to be called directly.
#
# A test file consists of top-level fixture setup (use set -g: functions don't
# see the sourcing block's locals), functions named test_<words_with_underscores>,
# and an optional teardown function called once after all tests. Tests run in
# definition order; the function name doubles as the test description.

set -l tests_dir (path resolve (status dirname))
set -l file (path resolve $argv[1])

source $tests_dir/helpers.fish
source $file

set -l failed 0
set -l tests (string match -rg '^function (test_\w+)' <$file)
if test (count $tests) -eq 0
    echo "  no test_* functions found" >&2
    exit 1
end

for t in $tests
    set -g _current_test (string replace test_ '' $t | string replace -a _ ' ')
    set -g _current_test_failed 0
    $t
    if test $_current_test_failed -eq 0
        echo "  ✅ $_current_test"
    else
        set failed (math $failed + 1)
    end
end

functions -q teardown; and teardown

exit $failed

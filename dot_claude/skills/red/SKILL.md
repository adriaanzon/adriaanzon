---
name: red
description: Prove a test actually exercises the change it covers
when_to_use: Use when you wrote a test for a change and want to confirm the test actually exercises it, or to apply TDD's watch-it-fail step retroactively to a test written after the code. Triggers on "does this test really test it", "would this turn red without the change", "TDD this retroactively".
---

# `/red` — Prove the test catches the change

A test that passes with AND without the change proves nothing.

1. Temporarily revert only the implementation change. Leave the test alone.
2. Run the test. It should fail — and fail on its behavioral assertion, not on a typo, missing import, or unrelated error.
3. Restore the change. Run the test again to confirm it's green.

## Report

For each test, say one of:
- ✅ **Meaningful** — red without the change (quote the failure), green with it.
- ⚠️ **Passes regardless** — green even without the change. The test doesn't exercise it. Explain why (often it bypasses the changed path with a mock or hardcoded input) and suggest what scenario *would* turn red.

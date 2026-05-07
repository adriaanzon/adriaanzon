#!/bin/sh
# Blocks rg -r (and combined forms like -rn, -nr) since -r means --replace in
# ripgrep, not recursive. Doesn't block --replace since that's intentional.

cmd=$(jq -r '.tool_input.command')

# Bail early if this isn't an rg command
echo "$cmd" | rg -q '^\s*rg\s' || exit 0

# Check for -r inside short flag groups (e.g. -r, -rn, -nr)
echo "$cmd" | rg -o '\s-[a-zA-Z]+' | rg -q r || exit 0

echo '{"decision":"block","reason":"rg -r means --replace, not recursive. ripgrep searches recursively by default. Drop the -r flag, or use --replace if you actually want substitution."}'

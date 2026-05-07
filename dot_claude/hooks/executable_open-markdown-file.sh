#!/bin/sh
# Opens the written or edited Markdown file in MarkEdit in the background.
# Emit tool_input.file_path only when it's a Markdown file under /specs/, /plans/, or /claude-preview/.
file_path=$(jq -r 'select((.tool_input.file_path // "") | test("/(specs|plans|claude-preview)/.*\\.md$")) | .tool_input.file_path')
[ -n "$file_path" ] && open -g "$file_path"
exit 0

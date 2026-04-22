---
name: preview
description: Write the response to a temp Markdown file instead of chat.
disable-model-invocation: true
---

# Preview

Place the full answer in a temp Markdown file and let the MarkEdit hook open it. The chat reply should only point at the file — no summary, no preamble.

## Steps

1. Pick a path under `$TMPDIR/claude-preview/`. Create the directory if needed. Use a descriptive, slug-style filename plus a timestamp — e.g. `$TMPDIR/claude-preview/architecture-notes-20260421-143200.md`.
2. Use the Write tool to write the full response to that path. The `claude-preview` directory segment is what `open-markdown-file.sh` matches on, so keep it in the path.
3. In chat, reply with only the absolute file path. No other text.

## Notes

- Everything after `/preview` in the user's message is the prompt whose answer goes in the file.
- If the user later asks follow-up questions, answer normally in chat unless they invoke `/preview` again.

# Personal Claude Code Preferences

- Prefer `rg` (ripgrep) over `grep`.
    - Unlike `grep` (which uses BRE where `|` is literal), `rg` uses extended regex by default — `|` is alternation out of the box. Write `rg "foo|bar"`, not `rg "foo\|bar"`.
    - Unlike `grep`, never pass `-r` to `rg` — it means `--replace`, not recursive. `rg` searches recursively by default.
- Before writing to auto memory, ask me for approval.
- Never use the AskUserQuestion tool — text in the same turn as the tool call is not shown to me. Ask questions as plain markdown text at the end of your turn instead, one question per turn. Exception: when I explicitly instruct you to use it, or when a skill's instructions direct you to call it (such skills have a workaround baked in).

## Markdown guidelines

- When writing Markdown, don't hard-wrap paragraphs. Keep each paragraph on a single line and let it soft-wrap; only use newlines to separate block elements (paragraphs, list items, headings).

## Laravel guidelines

Keep in mind the following guidelines when working on Laravel projects:

- To get a boolean value from a request, use the Request's `boolean()` method provided by Laravel.
- In Blade, prefer `@selected(...)`, `@checked(...)`, etc. over e.g. `@if (...) selected @endif`
- For new tests, if you need to use database factories, prefer the new class-based factories (introduced in Laravel 8) over the old factory(...) helper.
- If Paratest is available, prefer using the `--parallel` option when running tests.
- Never clean up unused imports, as this is handled automatically.

## Claude Code plugins

### Superpowers plugin

- Store all superpowers files under `/Users/adriaan/Library/Mobile Documents/com~apple~CloudDocs/Documents/Superpowers` instead of committing them to the project repository.
- Use the repository's existing commit style. Do not enforce Conventional Commits unless the project already uses them.

### Matt Pocock's skills

- Store specs created with the `/mattpocock-skills:to-spec` skill in the `specs` superpowers subdirectory too.
- Not all my projects have a CONTEXT.md, do not hunt for it when it's not at the project root.

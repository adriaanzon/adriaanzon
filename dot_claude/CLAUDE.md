# Personal Claude Code Preferences

- Prefer `rg` (ripgrep) over `grep`.
    - Unlike `grep` (which uses BRE where `|` is literal), `rg` uses extended regex by default — `|` is alternation out of the box. Write `rg "foo|bar"`, not `rg "foo\|bar"`.
    - Unlike `grep`, never pass `-r` to `rg` — it means `--replace`, not recursive. `rg` searches recursively by default.
- Before writing to auto memory, ask me for approval.

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

### Claude in Chrome

- If you need to verify something in the browser but the browser MCP is disconnected, tell me to restart the session with `claude --chrome --resume <session id>`.

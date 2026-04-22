# Personal Claude Code Preferences

- Prefer `rg` (ripgrep) over `grep`.
- Before writing to auto memory, ask me for approval.

## Laravel guidelines

Keep in mind the following guidelines when working on Laravel projects:

- To get a boolean value from a request, use the Request's `boolean()` method provided by Laravel.
- In Blade, prefer `@selected(...)`, `@checked(...)`, etc. over e.g. `@if (...) selected @endif`
- For new tests, if you need to use database factories, prefer the new class-based factories (introduced in Laravel 8) over the old factory(...) helper.
- If Paratest is available, prefer using the `--parallel` option when running tests.
- Never clean up unused imports, as this is handled automatically by the linter.

## Claude Code plugins

### Superpowers plugin

- Store all superpowers files under `~/.claude/projects/{current_project}/superpowers/` instead of committing them to the project repository.

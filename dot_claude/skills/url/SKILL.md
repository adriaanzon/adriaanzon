---
name: url
description: Build a browser URL for whatever we're currently working on
when_to_use: Use when the user wants a clickable URL to open the current work in the browser — a page, route, view, or feature being edited. Triggers on "give me the url", "/url", "what's the link to view this", "open this in the browser".
---

# `/url` — URL for the current work

Produce a single clickable URL the user can open to view whatever we're working on right now.

1. Identify the target from the session: the route/page/view/feature most recently edited or discussed. If it's genuinely ambiguous, ask which one — otherwise pick the obvious candidate and say which you chose.
2. Determine the base URL (local dev host/port) from the project config or how the app is run.
3. Build the path. If the route needs a parameter (route or query), fill it:
   - First reuse a concrete value already in the session context (an ID, slug, or record we've been discussing).
   - Otherwise query the database for a suitable existing record.
4. Output the final URL on its own line so it's clickable. State which record/param you used.

## Laravel

- Build the URL with the **`get-absolute-url`** Laravel Boost MCP tool (it knows the app's scheme, host, and port) rather than hand-assembling it.
- When you need a route/query parameter and don't have one from context, use the **`database-query`** Laravel Boost MCP tool to fetch a real value (e.g. `select id, slug from posts order by id desc limit 1`).

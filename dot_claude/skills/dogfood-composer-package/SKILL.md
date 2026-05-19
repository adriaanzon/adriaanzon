---
name: dogfood-composer-package
description: Use when the user wants to dogfood, link, or use a local development version of a Composer package.
argument-hint: <host-path-to-package>
---

Link a local checkout of a Composer package into the current project so edits to the package are reflected immediately, without publishing a release.

Host path to the local package: `$ARGUMENTS`

If the path above is empty, ask the user for it before proceeding. Expand `~` if present.

## Step 1 — gather inputs

- **Package name** — read `composer.json` at the host path; use its `name` field. Don't guess from the directory.
- **Project's PHP environment** — Docker or local PHP. Detect by checking for `docker-compose.yml` / `docker-compose.yaml`, a `develop` / `sail` wrapper script, or a `.devcontainer/` directory. If unclear, ask.

## Step 2 — make the package visible to PHP

### If the project uses Docker

The container can't see the host path unless it's mounted.

1. Find the PHP service in `docker-compose.yml` — name varies per project (commonly `devcontainer`, `laravel.test`, `app`, `php`).
2. Check whether `docker-compose.override.yml` already exists and is gitignored.
   - If yes, add a volume to the PHP service that maps the host path to `/packages/<dirname>`.
   - If no, create it and add the file to `.gitignore`.
3. Restart the container: `docker compose up -d --force-recreate <service>`.
4. **The container path** (not the host path) is what Composer references in Step 3.

### If the project uses local PHP

Skip the mount. Composer references the host path directly.

## Step 3 — wire up Composer

Edit `composer.json` directly (clearer diff than `composer config`).

Add a path repository with the container-or-host path determined in Step 2:

```json
"repositories": [
    {
        "type": "path",
        "url": "/packages/foo",
        "options": { "symlink": true }
    }
]
```

Switch the require constraint to `@dev`:

```json
"vendor/foo": "@dev"
```

Notes:

- **`@dev` is a per-package stability flag.** It allows dev versions for this package only — do **not** change the top-level `minimum-stability` from `stable`.
- **`symlink: true`** means edits in the local checkout reflect immediately without `composer update`. Composer falls back to copy on systems that don't support symlinks.
- If `composer.json` has no `repositories` key, add one. Place it near other top-level keys like `minimum-stability` for findability.

## Step 4 — install

Run the project's preferred Composer wrapper:

- Docker with a wrapper: `./develop composer update vendor/foo` or `./sail composer update vendor/foo`.
- Local PHP: `composer update vendor/foo`.

Use `composer update <package>` (not `require`) — the constraint is already in `composer.json`, and `require` would rewrite it and may strip `@dev`.

## Step 5 — remind about unlinking

After Step 4 succeeds, tell the user how to revert when done dogfooding:

1. Restore the original version constraint in `composer.json`.
2. Remove the entry from `repositories` (or delete the whole key if it was the only one).
3. Run `composer update vendor/foo`.

The Docker mount can stay — it's harmless when not referenced by a path repo.

## Common gotchas

- **`composer.json` and `composer.lock` will show as dirty** while linked. That's expected — don't commit them.
- **Package name mismatch:** if the `name` in the local checkout's `composer.json` doesn't match the require constraint, Composer silently ignores the path repo and falls back to Packagist. Always verify.
- **Autoload changes:** if the local package adds new classes or changes its `autoload` section, run `composer dump-autoload` in the project (not the package).
- **PSR-4 case sensitivity:** symlinks on macOS are case-insensitive by default, but Linux containers are case-sensitive. Class-not-found errors after linking usually mean a namespace/file casing mismatch.

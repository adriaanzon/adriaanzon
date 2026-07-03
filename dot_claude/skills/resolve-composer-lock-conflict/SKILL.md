---
name: resolve-composer-lock-conflict
description: Use when a `composer.lock` merge, rebase, or cherry-pick conflict needs resolving in a PHP/Composer repo — e.g. git reports `both modified: composer.lock`. Resolves it safely by regenerating the lock from a resolved composer.json instead of hand-merging, and avoids unintended dependency upgrades.
---

Resolve a `composer.lock` merge conflict safely. The lock is a generated file whose entries are cross-package resolved, so **never hand-merge or line-edit it** and never blindly accept one side. Regenerate it from a resolved `composer.json` with Composer, changing as little as possible.

## Core principle

`composer.lock` is not source code. A line-by-line merge can produce an invalid dependency set, because the text merge ignores cross-package conflicts that a real resolver would have to reconcile. The only safe resolution is: get a valid `composer.json`, take **one** side's lock wholesale as a starting point, then let Composer reconcile the lock to match.

## Step 1: Identify the conflict state (merge vs rebase)

This determines what `--ours` and `--theirs` mean, and they **invert** between the two. Run `git status` and check:

- **Merge** in progress (`.git/MERGE_HEAD` exists): `--ours` = your current branch, `--theirs` = the branch being merged in.
- **Rebase** in progress (`.git/rebase-merge/` or `.git/rebase-apply/` exists): the labels are reversed. `--ours` = the base you are replaying onto, `--theirs` = the commit from your branch being applied.
- **Cherry-pick or revert** (`.git/CHERRY_PICK_HEAD` / `.git/REVERT_HEAD` exists): labels work like a merge — `--ours` = the branch you are on, `--theirs` = the commit being applied.

Do not hardcode a flag. Reason about which physical side is the **mainline/base** (the integration branch you are merging into or rebasing onto). You will accept the base side's lock as the starting point, because it carries the canonical, bot-managed versions of every other package.

| Situation | Base/mainline lock is | Your branch's side is | Take base with |
| --- | --- | --- | --- |
| `git merge` (feature ← main) | `--theirs` (`MERGE_HEAD`) | `--ours` (`HEAD`) | `git checkout --theirs composer.lock` |
| `git rebase` (feature onto main) | `--ours` (`HEAD`) | `--theirs` (`REBASE_HEAD`) | `git checkout --ours composer.lock` |

If several commits in a rebase touch the lock, the conflict recurs at each one. Prefer squashing the branch's lock-touching commits first, or enable `git rerere`, rather than re-resolving repeatedly.

## Step 2: Establish each side's intent

Do not blindly union both sides of a conflict. A package that appears on only one side is ambiguous: it was either **added on that side** or **removed on the other** — and those require opposite resolutions. Same for versions: a higher constraint on one side is usually a deliberate upgrade, but confirm rather than assume.

Diff each side against the merge base to see what each side actually changed:

```bash
# During a merge:
BASE=$(git merge-base HEAD MERGE_HEAD)
git diff $BASE HEAD -- composer.json        # your branch's changes
git diff $BASE MERGE_HEAD -- composer.json  # mainline's changes

# During a rebase (HEAD is the base you're replaying onto):
BASE=$(git merge-base HEAD REBASE_HEAD)
git diff $BASE REBASE_HEAD -- composer.json # your commit's changes
git diff $BASE HEAD -- composer.json        # what mainline changed since you branched
```

When history is unclear, `git log --oneline -S '"vendor/package"' -- composer.json` shows who added or removed a package.

From this, build the list of your branch's deliberate changes: packages added, packages removed, constraints changed. Respect the other side's intent too — e.g. if mainline **removed** a package your branch never touched, keep it removed; do not re-add it just because your branch's side of the conflict still lists it.

**Lock-only upgrades:** also diff each side's `composer.lock` versions for the packages involved. If your branch deliberately upgraded a package only in the lock (constraint unchanged, e.g. via `composer update vendor/package`), taking the base lock in Step 5 would silently discard that upgrade. Preserve it by bumping the `composer.json` constraint to the upgraded version (e.g. `^5.0` → `^5.6`) so the intent is explicit and survives regeneration. Record your branch's locked version before overwriting:

```bash
# :2 = ours, :3 = theirs — pick your branch's side per the Step 1 table
git show :2:composer.lock | rg -A1 '"name": "vendor/package"'
```

## Step 3: Resolve composer.json first

The lock is regenerated **against** `composer.json`, so `composer.json` must be valid and conflict-free before you touch the lock.

- If `composer.json` is also conflicted, resolve it per the intent established in Step 2. It is plain JSON, so a manual merge is fine here — but merge by intent, not by union of lines.
- Stage it: `git add composer.json`.
- Confirm it parses: `composer validate --no-check-publish`.

### Worked example

Base branch removed `fruitcake/laravel-telescope-toolbar`; your branch upgraded `filament/upgrade` from `^5.0` to `^5.6`. During a rebase the conflict looks like:

```
<<<<<<< HEAD
    "filament/upgrade": "^5.0",
=======
    "filament/upgrade": "^5.6",
    "fruitcake/laravel-telescope-toolbar": "^1.3",
>>>>>>> fe3e65ec41 (Upgrade Filament)
```

A naive "keep both" would wrongly re-add the fruitcake package. Correct resolution: keep `"filament/upgrade": "^5.6"` (your branch's deliberate upgrade) and **omit** `fruitcake/laravel-telescope-toolbar` (it wasn't added by your branch — it was removed on the base, and your branch simply predates the removal).

## Step 4: Decide which path applies

Look at what actually conflicts in the lock:

- **Only the `content-hash` conflicts** (every package block merged cleanly, and `composer.json` is identical on both sides): this is the trivial case. Remove the conflict markers (keep either hash value, it gets recomputed), then run `composer update --lock`. This recomputes the hash **without changing any package versions**. Skip to Step 6.
- **Package blocks conflict, or `composer.json` changed**: use the regenerate path in Step 5. `composer update --lock` is NOT enough here — it only refreshes the hash and will not add, remove, or re-resolve packages.

> Do not assume every lock conflict is content-hash-only. Package-line conflicts are common whenever both branches changed dependencies.

## Step 5: Take the base lock, then reapply this branch's changes

1. Take the base/mainline lock wholesale (see the Step 1 table):
   ```bash
   git checkout --theirs composer.lock   # or --ours during a rebase
   ```
2. Reapply only the dependency changes your branch introduced (the Step 2 list). The merged `composer.json` already encodes them all, so every case — added, removed, or constraint changed — is the same command, a scoped update naming the affected packages:
   ```bash
   composer update vendor/a vendor/b --no-install
   ```
   A scoped update adds packages that are in `composer.json` but missing from the taken lock, removes packages gone from `composer.json`, and re-resolves changed constraints, while leaving every other locked package pinned (verified on Composer 2.9). Notes:
   - Run Composer in the project's usual PHP environment (e.g. inside its dev container) so platform requirements match.
   - `--no-install` writes only the lock and leaves `vendor/` untouched mid-conflict; sync it in Step 6.
   - **Preview first**: add `--dry-run` to see exactly what would change before touching the lock.
   - If the scoped update fails on transitive conflicts, add `-W` / `--with-all-dependencies` so the named packages' own dependencies may move too — still far narrower than a full update.
   - **Shortcut when unsure which packages changed**: `composer update php --no-install`. The `php` platform package is a no-op target, so this re-locks only what differs between the taken lock and the merged `composer.json`, leaving everything else pinned.

   Caveat: newly added packages resolve to the newest version matching the constraint, not necessarily the version the other branch had locked. That is expected and correct.

## Step 6: Verify before committing

```bash
composer validate --no-check-publish
git diff --stat composer.lock
```

The diff should touch **only** the packages your branch changed plus their transitive deps. If unrelated packages moved, you pulled in unintended upgrades — go back and use a more scoped update. Also confirm any deliberate upgrades from Step 2 survived (check the locked version, not just the constraint).

Then sync `vendor/` with the new lock and, when feasible, run the project's test suite:

```bash
composer install
```

Stage and continue:

```bash
git add composer.json composer.lock
git rebase --continue   # or: git commit  (for a merge)
```

## Anti-patterns (never do these)

- **Hand-editing or line-merging the lock.** Produces invalid, unresolvable dependency sets.
- **`git checkout --ours composer.lock` in a merge** (i.e. keeping your feature branch's lock and discarding mainline's). This silently throws away the other side's locked dependencies. (Note: `--ours` is correct during a *rebase*, where it means the base — see Step 1.)
- **Blindly unioning both sides of a `composer.json` conflict.** A package present on only one side may have been removed on the other side on purpose; unioning re-adds it. Resolve by intent (Step 2).
- **Bare `composer require vendor/package` (no constraint) for a package already in the resolved `composer.json`.** It rewrites the constraint to a caret of the *latest* release and upgrades the lock to match (e.g. `^1.0` silently becomes `^3.0`) — an unintended major upgrade. Use the scoped `composer update` from Step 5; the requirement is already in `composer.json`.
- **Deleting `composer.lock` and running a full `composer update`.** This re-resolves every package and almost always drags unexpected upgrades into the branch, fighting Dependabot/Renovate and bloating the diff. Only acceptable when a deliberate full upgrade is the actual goal.
- **Trusting `composer update --lock` to fix a real conflict.** It only refreshes the content-hash; it never adds, removes, or re-resolves packages.

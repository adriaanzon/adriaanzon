---
name: resolve-composer-lock-conflict
description: Use when a `composer.lock` merge, rebase, or cherry-pick conflict needs resolving in a PHP/Composer repo — e.g. git reports `both modified: composer.lock`. Resolves it safely by regenerating the lock from a resolved composer.json instead of hand-merging, and avoids unintended dependency upgrades.
---

Resolve a `composer.lock` merge conflict safely. The lock is a generated file whose entries are cross-package resolved, so **never hand-merge or line-edit it** and never blindly accept one side. Regenerate it from a resolved `composer.json` with Composer, changing as little as possible.

## Core principle

`composer.lock` is not source code. A line-by-line merge can produce an invalid dependency set, because the text merge ignores cross-package conflicts that a real resolver would have to reconcile (see [Composer's own article on this](https://getcomposer.org/doc/articles/resolving-merge-conflicts.md)). Every safe resolution has the same shape: get a valid `composer.json`, then let Composer reconcile the lock to match. Triage first (Step 2): the trivial case exits in one command, and only real dependency conflicts need the full pipeline.

## Step 1: Identify the conflict state (merge vs rebase)

This determines what `--ours` and `--theirs` mean, and they **invert** between the two. Run `git status` and check:

- **Merge** in progress (`.git/MERGE_HEAD` exists): `--ours` = your current branch, `--theirs` = the branch being merged in.
- **Rebase** in progress (`.git/rebase-merge/` or `.git/rebase-apply/` exists): the labels are reversed. `--ours` = the base you are replaying onto, `--theirs` = the commit from your branch being applied.
- **Cherry-pick or revert** (`.git/CHERRY_PICK_HEAD` / `.git/REVERT_HEAD` exists): labels work like a merge — `--ours` = the branch you are on, `--theirs` = the commit being applied.

Do not hardcode a flag. Reason about which physical side is the **mainline/base** (the integration branch you are merging into or rebasing onto).

| Situation | Base/mainline lock is | Your branch's side is | Take base with |
| --- | --- | --- | --- |
| `git merge` (feature ← main) | `--theirs` (`MERGE_HEAD`) | `--ours` (`HEAD`) | `git checkout --theirs composer.lock` |
| `git rebase` (feature onto main) | `--ours` (`HEAD`) | `--theirs` (`REBASE_HEAD`) | `git checkout --ours composer.lock` |

If several commits in a rebase touch the lock, the conflict recurs at each one. Prefer squashing the branch's lock-touching commits first, or enable `git rerere`, rather than re-resolving repeatedly.

## Step 2: Triage — what actually conflicts?

The cheapest diagnostic decides everything, so run it before any intent analysis:

```bash
# Print the conflicted hunks in the lock:
awk '/^<<<<<<</,/^>>>>>>>/' composer.lock

# Do the two sides' composer.json differ at all (conflicted or not)?
git diff HEAD MERGE_HEAD -- composer.json   # merge; use REBASE_HEAD (rebase) or CHERRY_PICK_HEAD (cherry-pick) instead of MERGE_HEAD
```

- **Only the `content-hash` line conflicts, and `composer.json` is identical on both sides** — trivial case, done in one command: remove the conflict markers (keep either hash value, it gets recomputed), run `composer update --lock`, which recomputes the hash **without changing any package versions**, and skip to Step 6.
- **Anything else** — continue with Step 3. Note which situation you are in, because it picks the variant of Step 5:
  - Only the `content-hash` conflicts but `composer.json` differs between the sides → the package blocks text-merged cleanly → Step 5B. A clean merge is not proof of a *correct* merge, but it can be verified and repaired surgically.
  - Package blocks conflict → Step 5A, the full regenerate path. Do not assume every lock conflict is content-hash-only; package-block conflicts are common whenever both branches changed dependencies.

## Step 3: Establish each side's intent

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

From this, build the list of each side's deliberate changes: packages added, packages removed, constraints changed. Respect the other side's intent too — e.g. if mainline **removed** a package your branch never touched, keep it removed; do not re-add it just because your branch's side of the conflict still lists it. On the Step 5B path this step is quick: the changed-package list is only needed to resolve `composer.json` and to know what to verify.

**Lock-only upgrades:** also diff each side's `composer.lock` versions for the packages involved. If your branch deliberately upgraded a package only in the lock (constraint unchanged, e.g. via `composer update vendor/package`), taking the base lock in Step 5A would silently discard that upgrade. Preserve it by bumping the `composer.json` constraint to the upgraded version (e.g. `^5.0` → `^5.6`) so the intent is explicit and survives regeneration. Record your branch's locked version before overwriting:

```bash
# :2 = ours, :3 = theirs — pick your branch's side per the Step 1 table
git show :2:composer.lock | rg -A1 '"name": "vendor/package"'
```

## Step 4: Resolve composer.json first

The lock is reconciled **against** `composer.json`, so `composer.json` must be valid and conflict-free before you touch the lock.

- If `composer.json` is also conflicted, resolve it per the intent established in Step 3. It is plain JSON, so a manual merge is fine here — but merge by intent, not by union of lines.
- Stage it: `git add composer.json`.
- Confirm it parses: `composer validate --no-check-publish` (on the 5B path it may report lock errors at this point — expected, Step 5B fixes them).

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

## Step 5: Reconcile the lock

Two variants, per the Step 2 triage. Both leave `vendor/` untouched mid-conflict (`--no-install`); it is synced in Step 6. Run Composer in the project's usual PHP environment (e.g. inside its dev container) so platform requirements match.

### Step 5A: Package blocks conflict — regenerate from the base lock

1. Take the base/mainline lock wholesale (see the Step 1 table) — it carries the canonical, bot-managed versions of every other package:
   ```bash
   git checkout --theirs composer.lock   # or --ours during a rebase
   ```
2. Reapply only the dependency changes your branch introduced (the Step 3 list). The merged `composer.json` already encodes them all, so every case — added, removed, or constraint changed — is the same command, a scoped update naming the affected packages:
   ```bash
   composer update vendor/a vendor/b --no-install
   ```
   A scoped update adds packages that are in `composer.json` but missing from the taken lock, removes packages gone from `composer.json`, and re-resolves changed constraints, while leaving every other locked package pinned (verified on Composer 2.9). Notes:
   - **Preview first**: add `--dry-run` to see exactly what would change before touching the lock.
   - If the scoped update fails on transitive conflicts, add `-W` / `--with-all-dependencies` so the named packages' own dependencies may move too — still far narrower than a full update.
   - Newly added packages resolve to the newest version matching the constraint, not necessarily the version the other branch had locked. That is expected and correct.

### Step 5B: Package blocks merged cleanly, but composer.json differs — verify and repair surgically

The text merge is *probably* right (git applied both sides' additions and removals), but do not bless it blindly: repair anything provably wrong, then prove both sides' intent survived. Do **not** reach for `composer update --lock` as the fix here — it only rehashes, and it reports "Nothing to modify" even when the lock still contains a package one side removed, or is missing a package the other side added (verified on Composer 2.10).

1. Remove the conflict markers around `content-hash` (keep either value, it gets recomputed by whichever command below writes the lock).
2. Detect and fix **missing** packages — required in `composer.json` but absent from the lock. `composer validate` reports these as lock file errors (verified on Composer 2.10); lock each one it names:
   ```bash
   composer validate --no-check-publish
   composer update vendor/missing-a vendor/missing-b --no-install
   ```
   Read the output carefully: the generic line "The lock file is not up to date with the latest changes in composer.json" **always** appears at this point, because the hash kept in step 1 cannot match the merged `composer.json` — on its own it just means the hash is stale, not that anything is missing. Missing packages show up as *additional* lines naming each package ("Required package vendor/x is not present in the lock file"). No package-naming lines → nothing to fix here.
3. Detect and remove **stale** packages — still in the lock but no longer required by anything. `composer validate` does NOT catch these; use the dedicated command (it prunes the lock and leaves `composer.json` untouched, verified on Composer 2.10):
   ```bash
   composer remove --unused --no-install
   ```
4. If neither command wrote the lock, recompute the hash: `composer update --lock --no-install`.
5. Prove both sides' intent survived with targeted presence/absence checks from the Step 3 list:
   ```bash
   rg '"name": "vendor/removed-package"' composer.lock   # expect no match
   rg '"name": "vendor/added-package"' composer.lock     # expect a match
   ```

If any of this errors on an unsolvable set or a constraint the locked version no longer satisfies, the text merge was not as clean as it looked — fall back to Step 5A.

## Step 6: Verify before committing

```bash
composer validate --no-check-publish
git diff --stat composer.lock

# Enumerate exactly which packages were added/removed relative to the base side:
git diff HEAD -- composer.lock | rg '^[+-]\s+"name":' | sort | uniq -c   # merge: diff against MERGE_HEAD instead
```

The diff should touch **only** the packages the branches changed plus their transitive deps — the `"name":` listing shows this at a glance (expect the Step 3 list plus their dependencies, nothing else; it also doubles as the presence/absence proof from Step 5B.5). If unrelated packages moved, you pulled in unintended upgrades — go back and use a more scoped update. Also confirm any deliberate upgrades from Step 3 survived (check the locked version, not just the constraint).

Know what each check can and cannot prove (verified on Composer 2.10): `composer validate` catches a required package *missing* from the lock, but passes with a *stale* package that should have been removed — the content-hash is derived from `composer.json` alone. `composer install` likewise hard-errors on a missing package but silently installs a stale one. The only proof of a removal is grepping the lock for the removed package's name (Step 5B.5).

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
- **Blindly unioning both sides of a `composer.json` conflict.** A package present on only one side may have been removed on the other side on purpose; unioning re-adds it. Resolve by intent (Step 3).
- **Bare `composer require vendor/package` (no constraint) for a package already in the resolved `composer.json`.** It rewrites the constraint to a caret of the *latest* release and upgrades the lock to match (e.g. `^1.0` silently becomes `^3.0`) — an unintended major upgrade. Use the scoped `composer update` from Step 5; the requirement is already in `composer.json`.
- **Deleting `composer.lock` and running a full `composer update`.** This re-resolves every package and almost always drags unexpected upgrades into the branch, fighting Dependabot/Renovate and bloating the diff. Only acceptable when a deliberate full upgrade is the actual goal.
- **Trusting `composer update --lock` to fix a real conflict.** It only refreshes the content-hash; it never adds, removes, or re-resolves packages, and it reports "Nothing to modify" even when the lock and `composer.json` disagree.
- **Treating a green `composer validate` as proof the package set is right.** It detects missing required packages, but a stale leftover package passes it. Use `composer remove --unused` and the targeted greps for that direction.

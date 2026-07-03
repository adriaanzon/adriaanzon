---
name: review-companion-html
description: Generate a single self-contained light-theme HTML "reading & review companion" for a sizeable body of work — a markdown doc (design spec / implementation plan), bulk agent output to smoke-test (a directory, diff, or list of artifacts), or a set of decisions / open points to work through. Use when asked to "visualize / make readable / turn into a page / build a review page".
---

# Review Companion HTML

Turn a tiring-to-read body of work into ONE self-contained HTML page that's pleasant to read through once and easy to track. The page is a list of **units of review** — whatever the reader works through one at a time: a **section to read** (markdown doc), an **artifact to verify** (file, diff hunk, claim from bulk agent output), an **item to resolve** (decision, open question), or a **change to understand** (a PR hunk, narrated — see story mode). The mark-toggle verb follows the unit (Read / Viewed / Checked / Resolved). Infer the unit; ask only if genuinely ambiguous.

## Division of labor — keep the page out of this context

**You do the editorial work here** (you have the conversation context): identify the units, triage, narrate, choose controls — and distill it all into a brief. **A subagent does the design + authoring** (it needs only the brief): it reads `AUTHORING.md` (next to this file), commits to an aesthetic, writes the page, and assembles it with `render.py`. The design guidance, the authoring contract, and the page's entire HTML/CSS live in the subagent's window, not yours. What you pay here: this file, the brief (thinking you'd do anyway), and a one-line summary back.

## 1. Editorial: units → brief

Work in `<scratchpad>/review-companion/<slug>/`, where `<scratchpad>` is the session scratchpad directory listed in your system prompt (for a design spec / implementation plan, use the superpowers docs location instead; if no scratchpad is listed, fall back to `/tmp/review-companion/<slug>/`).

- **Big verbatim sources go by reference, never through context.** Write them to files first (`git diff > <dir>/changes.diff`), locate line ranges with `rg -n` / `grep -n`, and reference `FILE:A-B` in the brief.
- **For a markdown doc you may delegate the split** — tell the agent "units = the `## ` sections of `doc.md`, split fence-aware" instead of reading the whole doc yourself. (Fence-aware matters: a README example inside a code fence WILL contain `## Setup` and invent phantom units.)

Write `<dir>/brief.md`. It is the agent's *only* source of content knowledge — be complete. Shape:

```markdown
# <page title>
- source: <branch / ticket / path>   (recorded in the handoff JSON)
- key: rc-<slug>-v1
- verb: Viewed
- aesthetic: <optional hint — omit to let the agent choose>

Two sentences of overview for the top of the page: what this is, why it exists.

## band: Start here
### u-core — Centralize refresh
What changed and why; a *Watch:* line if there's a risk.
include: changes.diff:120-180 diff
controls: radio verdict ok|needs-work; comment box

## band: Plumbing (start collapsed)
### u-lock — Lockfile churn
One line.
include: changes.diff:400-620 diff
```

`include:` and `controls:` lines are instructions the agent turns into markup; anything else is prose it places on the page.

## PR code review — story mode (the editorial judgment)

When the input is a PR (`git diff`, a branch, a `gh pr` ref), don't list hunks file-by-file. **Read the whole diff, then re-tell it as a story.** Triage every hunk into three bands by *reading the code*, not by file path:

- **Start here** — the one core change the PR exists to make (rarely two). Don't hedge by promoting everything.
- **Ripples** — changes that exist *because of* the core, ordered by dependency. One unit each.
- **Plumbing** — imports, renames, lockfiles, churn. One band, started collapsed; present but dismissable wholesale (don't omit it — the review must be complete).

Narrate at two levels: a short overview up top (*what* and *why*), and a terse line per unit (*what* changed plus a *Why* or *Watch*). Orient, don't restate the diff. Mark verb: **Viewed**.

## 2. Dispatch the authoring agent

Launch a `general-purpose` agent:

> Read `<skill-dir>/AUTHORING.md` and follow it exactly. Author the review companion page for the brief at `<dir>/brief.md` as `<dir>/page.html`, assemble it with render.py to `<dir>/out.html`. Return ONLY: the render.py summary, the out.html path, and any assumptions or liberties you took with the brief.

Don't restate the contract or design advice in the prompt — `AUTHORING.md` is the contract.

## 3. Check + iterate

- `open <dir>/out.html`; sanity-check the unit count in the returned summary against the brief.
- **Small tweaks** (wording, a CSS value): Edit `page.html` directly and re-run `python3 <skill-dir>/render.py page.html -o out.html` — don't re-dispatch.
- **Design-level changes**: SendMessage the *same* agent (it still holds the page and its design rationale) rather than spawning a fresh one.
- Offer to commit at the end; don't assume.

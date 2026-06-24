---
name: review-companion-html
description: Generate a single self-contained light-theme HTML "reading & review companion" for a sizeable body of work — a markdown doc (design spec / implementation plan), bulk agent output to smoke-test (a directory, diff, or list of artifacts), or a set of decisions / open points to work through. Use when asked to "visualize / make readable / turn into a page / build a review page".
---

# Review Companion HTML

Turn a tiring-to-read body of work into ONE self-contained HTML page that's pleasant to read through once and easy to track.

The page is a list of **units of review**. A unit is whatever the reader works through one at a time:

- a **section to read** — from a markdown doc (design spec, implementation plan);
- an **artifact to verify** — a file, diff hunk, generated page, or claim from bulk agent output;
- an **item to resolve** — a decision, question, or open point, often synthesized from several sources (a ticket, a comment, code you went and read);
- a **change to understand** — a hunk of a PR diff, narrated and placed in a story so the review reads as one arc rather than a file list (see PR code review — story mode).

The input may be something you point at (a doc, a directory, a `git diff`) or something you assemble yourself. Infer the unit from what I give you; ask only if genuinely ambiguous.

## Output contract (always)

- **One self-contained `.html`** that opens on double-click — no server, no build step, no local asset deps.
- **Build path follows the content.** Transcribing a *verbatim source* (markdown doc, `git diff`, commits, directory) → generate via a **Python stdlib-only** script in `/tmp/review-companion/scripts/build_<thing>_html.py` (no `pip install`); it parses + embeds the source and on run prints a one-line summary (what was parsed, unit count, byte size) plus a regenerate command. Content *synthesized by you* (a worksheet assembled from a ticket + code) → skip the script and **write the `.html` directly**; there's nothing to parse, so a script is pure ceremony.
- Markdown→HTML + syntax highlighting happen **client-side via CDN**: `marked.js` + `highlight.js` (github light theme). Do NOT depend on a Python markdown lib.
- Embed content as a JSON blob in `<script id="data" type="application/json">…</script>` and `JSON.parse(el.textContent)` in the page — this sidesteps all backtick/quote escaping. **Whatever emits it, ensure no literal `</` survives in the blob** (in Python: `payload.replace("</", "<\\/")`) so a `</script>` inside code can't break out.
- Light theme.
- Output to /tmp, or to the superpowers docs location when generating a page for a design spec or implementation plan
- **Visual layer:** invoke the `frontend-design` skill so each page gets its own type/color/spacing character — don't ship the bland default. Interaction mechanics below stay fixed; vary the aesthetics. But don't over-engineer it: this is a transient, read-once document — readability comes first, polish second.

## Hard-won gotchas (don't skip)

- **Fence-aware parsing.** When splitting markdown into sections by `## ` headings (or steps by `- [ ]`), track ```` ``` ```` fences and ignore any `##`/markers that appear *inside* code blocks. (A README example embedded in a fence WILL contain `## Setup` and silently invent phantom chapters / truncate a task otherwise.)
- **Don't leave diffs uncolored.** If you hand-tint diff lines red/green, don't also skip them in the hljs pass — they end up flat and bland. Color the line bodies (minus the `+`/`-` prefix) with the file's language under the tint.

## Core interactions (the good defaults)

GitHub-PR-file-review feel:
- **Sidebar nav** of all units with scroll-spy active state; collapses to a hamburger on narrow screens.
- **Sticky unit header** — each unit's title bar (kicker + title + the mark control) pins to the top while you read it, then the next header pushes it up.
- **Mark → collapse.** The mark control is a **checkbox with a label**, like GitHub's per-file "Viewed" toggle — not a plain button. Its verb follows the unit (Read / Viewed / Checked / Resolved). Checking it collapses the unit body (animated `grid-template-rows: 1fr→0fr`), tints it, and ticks/dims its sidebar entry; unchecking restores it. Clicking anywhere on the header bar toggles the same state. Persist in `localStorage` (versioned key) and show an "X/N" meter with the matching verb in the sidebar.
- Sticky requires the unit card to have `overflow: visible` (not hidden) and the sticky header to have a solid background.

## Reading-quality features

- **Language labels on code blocks** — small uppercase mono chip top-right per block (`python`, `bash`, `toml`, `json`…).
- **Collapse long fences** — any code block over ~24 lines is capped (~300px) with a bottom fade-out and an `Expand · N lines` label over the fade (absolutely positioned, centered on the bottom gradient). The **whole block is clickable** to toggle expand/collapse both ways (cursor:pointer on the `pre`) — no separate button. Guard the toggle so a click+drag that selects text doesn't fire it: bail in the click handler when `!window.getSelection().isCollapsed`.
- **A pipeline / architecture diagram up top, WHEN the content has an obvious flow** (e.g. a two-phase tool, a request lifecycle, a data pipeline). Build it as a small hand-authored CSS block (boxes + connectors + phase badges) from the spec's stated architecture — don't force one if there isn't a clear shape.

Skip: copy buttons, per-step checkboxes, reading-time stats, scroll-reveal animations, expand-all/collapse-all — unless I ask. They proved to be noise.

## PR code review — story mode

When the input is a PR (a `git diff`, a branch, a `gh pr` ref), don't list hunks file-by-file. **Read the whole diff, then re-tell it as a story** that orients the reviewer: lead with the one change the PR exists to make, then walk its consequences, and fold the noise away. Each unit is a *change to understand*; the mark verb is **Viewed**. This is *synthesized* content — you decide the structure — so write the `.html` directly (no parse script) and embed the verbatim diff hunks in the JSON blob.

- **Triage every hunk into three bands** by *reading the code*, not by file path (a one-line change can be the core; a 300-line generated file can be plumbing):
  - **Start here** — the core change the PR exists to make, the thing the rest depends on. Commit to **one** core unit (rarely two); don't hedge by promoting everything.
  - **Ripples** — changes that exist *because of* the core, **ordered by dependency**: what the core directly touches first, then second-order effects. One unit each.
  - **Plumbing** — imports, formatting, renames, lockfiles, mechanical churn. Collapse into **one** band, **present but dismissable wholesale** (don't omit it — the review must be complete). Reuse the mark→collapse mechanic; default this band collapsed.
- **Render the bands as labelled sections** (Start here / Ripples / Plumbing) in both the sidebar and the main column, so the triage is visible and scannable rather than inferred from position.
- **Narrate at two levels (overview + per-unit):**
  - A short **PR overview** card at the top: *what* the PR does and *why*. Don't tell the reader to "read the core first" — the layout already says that.
  - A terse **prose line above each unit's diff**: *What* changed, and a *Why* or *Watch* (the risk or the thing to check). One or two sentences — orient, don't restate the diff.
- Diffs stay verbatim and colored — see the diff-tinting gotcha above.

## Annotation & handoff (when the reader marks up the page for you)

For review/resolve workflows, let the reader annotate each unit and hand the result back as JSON. All of it persists in `localStorage` under the same versioned per-page key as the checked state, so they can leave and return.

- **Per-unit comment, hidden by default.** A comment-icon button in the sticky header reveals a textarea inside the unit body; clicking again hides it. Collapsed by default — a permanent textarea per unit wrecks the density. If a saved comment exists on load, show a "has-comment" state on the icon (filled / a dot) so hidden text stays discoverable.
- **Agent-chosen controls, inline.** Where a unit needs a decision, drop in whatever standard control fits — a radio group, a `<select>`, a multi-pick — directly in the unit body, visible inline (they're the decision, and they're compact). Don't pre-enumerate a control vocabulary; pick the right element per case. The control *markup* lives in the body content (the JSON blob); the reader's *answer* lives in `localStorage`, never the blob. Two authoring gotchas: marked only passes raw HTML through when it's separated by blank lines and not indented (else the `<fieldset>` shows as literal text); and `data-handoff` goes on the **wrapping** element for grouped controls, with the reader reading `input:checked` inside it.
- **One capture path — the `data-handoff` scraper.** Tag every captured element (the comment textarea included) with `data-handoff="<key>"`. A single generic reader walks `[data-handoff]` within each unit and maps element → value: text/textarea → string, radio group → selected value, single checkbox → boolean, multi-select / checkbox group → array. No per-control-type code, so any standard input "just works."
- **Persist & restore.** Save `{ [unitId]: { checked, fields: { [key]: value } } }` on every `input`/`change`; on load, restore the checkbox and write each saved value back into its `data-handoff` element (the type-aware logic in reverse). Restore-on-load is the fiddly part — write the generic get/set carefully.
- **Copy for handoff.** One global **Copy** button (by the sidebar meter) gathers every *touched* unit (non-empty comment, any field set, or checked), writes JSON to the clipboard, and confirms ("Copied N units"); untouched units are skipped. Wrap the units in a small **preamble** so the blob is actionable in a *fresh* session, not just the one that built the page: `{ source, units: [{ id, name, checked, comment, fields }], … }`. `source` is whatever lets a new agent recover full context — the page's file path, a ticket key, the source doc. Each unit carries id + name so it's legible without the page. Keep the per-unit data compact; the preamble, not bloated units, is what makes it portable. JSON, not markdown: simpler to emit, unambiguous to parse.

## Filling each unit

- Show what's needed to act on it: the rendered markdown to read; file contents (highlighted), a diff, the command + expected-vs-actual, or a link/screenshot to verify; the source material + open question to resolve.
- If useful, add a tiny status affordance per unit (ok / needs-attention) — but keep it to a single optional control, not a form.
- Gather the unit list however fits: walk a directory, parse `git diff --name-only` / `git diff`, read the relevant code, or take an explicit list I give you. State your assumptions in the run summary.

## Workflow

1. Identify the units and the input(s).
2. Build the page (see Build path): for a verbatim source, write/extend `scripts/build_<thing>_html.py` (stdlib only) that parses input → JSON model → emits the HTML; for synthesized content, write the `.html` directly. Either way the content lives in the embedded JSON blob.
3. If there's a script, run it and **verify the parse** (print the unit list and sanity-check counts — this is where fence bugs surface). Then `open` the file.
4. Iterate on layout/features with me before committing. Offer to commit the HTML (and the script, if any) at the end; don't assume.

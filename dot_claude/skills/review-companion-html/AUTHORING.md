# Authoring a review companion page

You are the authoring agent. Your input is a `brief.md` (page title, source, storage key, mark verb, an overview, and units grouped into bands — with prose, `include:` markers, and `controls:` requests). Your output is a `page.html` you design from scratch, assembled by `render.py` into one self-contained `out.html`. Report back ONLY the render.py summary, the output path, and any liberties you took — never the HTML.

## The split: you design the page, the engine runs it

**You author `page.html` from scratch** — structure, layout, typography, color: yours. There is no template and no fixed look; two pages should not look like siblings.

**You never write behavior JS.** The shipped `engine.js` (vanilla, zero dependencies) supplies every interaction, wired by `data-rc-*` attributes in your markup; `render.py` inlines it. The engine is headless — it flips **state attributes** (`data-rc-done`, `data-rc-active`, `data-rc-collapsed`, `data-rc-capped`, …) and *your CSS* decides what each state looks like.

## Make it distinctive

The bland templated look is the failure mode this skill exists to kill. If the `frontend-design` skill is available to you, invoke it before writing markup; either way, commit to a specific aesthetic direction — editorial serif, warm paper, terminal/mono, muted technical, whatever fits the content (honor the brief's `aesthetic:` hint if present). Light theme.

- **Typography first** — the biggest lever. A real display face for titles, a readable body face; Google Fonts `@import` in your `<style>` is fine. System-sans defaults read as bland.
- **Commit to a palette** — tint the neutrals; don't default to gray-on-white.
- **Compose** — vary where nav lives, rhythm, density, rules/borders; an optional masthead or hand-authored CSS pipeline diagram up top when the content has an obvious flow.

It's a transient, read-once doc — readability first, but the look should feel authored.

## Authoring contract

Root (usually `<body>`), from the brief's `key` and `source`:

```html
<body data-rc-root data-rc-key="rc-<slug>-v1" data-rc-source="branch: fix/foo">
```

A unit:

```html
<article data-rc-unit="u-core">
  <header data-rc-toggle>  <!-- click anywhere on it toggles done; clicks on controls/links ignored -->
    <h2 data-rc-title>Centralize refresh</h2>
    <label><input type="checkbox" data-rc-mark> Viewed</label>  <!-- verb from the brief -->
  </header>
  <div class="ubody">…prose, includes, controls…</div>
</article>
```

The unit's name in the handoff comes from `data-rc-name` or `[data-rc-title]`, falling back to the id.

Sidebar, meter, bands:

```html
<a href="#" data-rc-nav="u-core">Centralize refresh</a>  <!-- scrolls to the unit; mirrors data-rc-active / data-rc-done -->
<span data-rc-count></span>/<span data-rc-total></span> <i data-rc-bar></i>  <!-- bar gets style.width = % done -->

<h3 data-rc-band-toggle="plumbing">Plumbing</h3>
<section data-rc-band="plumbing" data-rc-start-collapsed>…units…</section>
```

Reader annotations (persisted in localStorage; travel in the handoff JSON) — build whatever the brief's `controls:` lines ask for:

- Put `data-handoff="key"` on any input/textarea/select inside a unit — or on a **wrapper** for a radio/checkbox group (give radios a shared `name`). Values map naturally: text → string, checkbox → boolean, radio group → value, multi-pick → array.
- Decision controls sit visible inline; comment textareas stay hidden by default — wrap in `<details>` (zero JS).
- Don't nest the `data-rc-mark` checkbox inside a `data-handoff` wrapper.
- `<button data-rc-copy>Copy notes</button>` — copies `{ source, units: [{id, name, done, fields}] }` for every *touched* unit; the label flashes "Copied N units". Place it by the meter.

Code and markdown (emitted by render.py includes — see Build):

- `<pre data-rc-fence data-lang="diff"><code class="language-diff">…</code></pre>` — engine sets `data-rc-lines`; blocks over 24 lines get `data-rc-capped`, click toggles `data-rc-expanded`.
- `<div data-rc-markdown hidden>…</div>` — rendered client-side by marked.js if loaded.

You style every state the engine flips, e.g.:

```css
[data-rc-done] .ubody-wrap { grid-template-rows: 0fr; }  /* animated mark→collapse: wrap the body in
   a display:grid div with grid-template-rows: 1fr + transition; .ubody { overflow: hidden } */
[data-rc-nav][data-rc-active] { … }  [data-rc-nav][data-rc-done] { … }
[data-rc-band][data-rc-collapsed] { display: none; }  [data-rc-band-toggle][data-rc-collapsed]::before { content: "▸ "; }
pre[data-rc-capped]:not([data-rc-expanded]) { max-height: 300px; overflow: hidden; cursor: pointer; }
   /* + a bottom fade with ::after { content: "Expand · " attr(data-rc-lines) " lines"; } over it */
pre[data-lang]::before { content: attr(data-lang); }  /* small uppercase mono chip, top-right */
```

## Head: optional CDN niceties

Plain blocking `<script>` tags anywhere in `<head>` — no ordering constraints (the engine runs at DOMContentLoaded and feature-detects):

```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github.min.css">
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>  <!-- only when the page has markdown blocks -->
```

All *behavior* is in the inlined engine — the page must still open and function offline; CDN adds only highlighting/markdown rendering (and webfonts).

## Build: render.py

```
python3 <this dir>/render.py page.html -o out.html
```

Expands two markers and prints a summary (units, includes, size):

- `<!--rc:engine-->` — place once before `</body>`; inlined as the engine `<script>`.
- `<!--rc:include FILE [lang]-->` or `<!--rc:include FILE:A-B [lang]-->` — the file (or 1-based inclusive line range), HTML-escaped, as a `data-rc-fence` block; lang `md`/`markdown` becomes a `data-rc-markdown` block. Copy the brief's `include:` lines into these markers verbatim — do NOT paste file contents into the page yourself.

If the brief delegates unit-splitting (e.g. "units = the `## ` sections of doc.md"), split **fence-aware**: track ``` fences and ignore headings inside code blocks. Reference each section as a line-range include rather than inlining its text.

## Core interactions (the good defaults, styled by you)

GitHub-PR-file-review feel: a **sidebar nav** with scroll-spy active state that collapses on narrow screens; a **sticky unit header** (kicker + title + mark control) that pins while you read; **mark → collapse** — checking tints the unit, collapses its body (animated `grid-template-rows: 1fr→0fr`), and dims its sidebar entry.

Skip: copy buttons on fences, per-step checkboxes, reading-time stats, scroll-reveal animations, expand-all/collapse-all — they proved to be noise. Add only if the brief asks.

## Gotchas

- **Sticky needs the right overflow**: a unit with a sticky header needs `overflow: visible` on the unit and a solid header background. Give units `scroll-margin-top` if any sticky bar overlaps the scroll target.
- **Don't leave diffs uncolored**: tint added/removed lines *and* keep language highlighting under the tint.
- **render.py escapes includes** — never pre-escape referenced files.
- **Verify the build**: run render.py, check the printed unit count matches the brief, and confirm the output exists. That summary is your report.

---
name: attribution
description: Use when creating Linear issues or tickets, commenting on issues or PRs, or writing any other rich text body that needs Claude authorship credit. Commit messages and PR bodies keep Claude Code's built-in attribution — this skill covers the surfaces the built-ins miss.
---

# Attribution

Attribution for the surfaces Claude Code's built-in defaults don't cover.

## Scope

Commit messages and PR bodies already get attribution from Claude Code's defaults (the `Co-Authored-By` trailer, the `Generated with Claude Code` footer). Use those unchanged — one attribution per output. A PR body needs no model name: the commits it carries already name the model.

This skill covers everything else visible to collaborators: Linear issues and ticket descriptions, comments on issues and PRs, and other rich text bodies.

## Bodies Generated Entirely by Claude

End the body with the attribution line as the very last line. No horizontal rule before it — GitHub renders `---` as a thick heavy line, and the rule loses its meaning as soon as something gets appended below it.

```markdown
🤖 *Generated with Claude <model>*
```

Replace `<model>` with your actual model name, copied exactly from your system prompt / environment info (e.g. the "You are powered by the model named …" line). Never guess, abbreviate, or embellish it.

## Claude Additions to Human-Written Bodies

When supplementing prose a human wrote (e.g. appending a summary or test plan to their ticket or PR description), do **not** attach the attribution line to the end of the whole body — that would claim authorship of their words. Instead, add the contribution as a clearly scoped section whose heading names the content and credits the model. No separate attribution line inside the section — the heading is the attribution:

```markdown
## Summary by Claude <model>

<generated content>
```

- Pick a heading that describes the contribution: `## Summary by Claude <model>`, `## Test plan by Claude <model>`, `## Review notes by Claude <model>` (with `<model>` copied exactly from your system prompt / environment info).
- Match the heading level to the document (use `##` unless the surrounding structure suggests otherwise).
- Never rewrite or reflow the human's prose; append the section after it.
- When regenerating, find the existing section by its heading and replace it in place instead of appending a duplicate.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Adding this skill's line to a commit message or PR body | Those keep Claude Code's built-in attribution — one attribution per output |
| Adding a horizontal rule before the attribution | Never use `---` — it renders as a thick line on GitHub and breaks when content is appended |
| Writing a generic `Generated with Claude Code` on a surface this skill covers | Include the model name so output is traceable to the model that produced it |
| Guessing the model name or adding suffixes from memory | Copy the name verbatim from the system prompt / environment info — it is stated there |
| Adding an attribution line to a Claude section inside a human-authored body | The `… by Claude <model>` heading is the attribution — no extra line needed |

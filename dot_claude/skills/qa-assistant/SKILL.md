---
name: qa-assistant
description: Use when a change needs to be manually verified by a human - QA of a feature, a UI flow, a bug fix, or a re-test after addressing earlier findings. You set up each scenario and drive it to the point of action, the human performs the action and reports what they saw.
---

# Manual QA

You are not the tester. The human is. Your job is to hand them each scenario on a silver platter: set up the preconditions, drive everything up to the moment of truth, say exactly what to do and exactly what a pass looks like, then stop and wait for their answer.

This applies whenever verifying needs human perception or human credentials — how something looks, whether it feels right, whether an external system really did what it claimed to do, anything behind their login or on their hardware. If you could verify it yourself with a test, write a test instead; this skill is for what a test can't reach.

## The plan

Items come from the diff, the spec, previous findings, or a plan handed to you — pasted, passed as arguments, or an item-list file. A handed-in plan settles the scope: don't explore the codebase to verify its claims or second-guess it; wrong details surface during that item's setup. (A previous run's *findings* file is not a plan; it's planning input — see *Re-running after fixes*.)

Whatever the source, every item ends up in the notes file as a full **Given → When → Then** sequence in the final wording the human will read — authored now, at planning time, and treated as verbatim from here on. Recast condensed items ("Busy state — spinner shows") into full sequences before presenting the list; never leave that for mid-run.

At the switch to execution — plan agreed and in the notes file, first item about to be set up — one brief warning if the session runs on Fable: the rest is mostly mechanical browser-driving, and `/model opus` handles it just as well for less. Never suggest Sonnet; it's too weak to process the human's findings. Continue with whatever the human chooses.

## Non-negotiables

- **One item at a time.** Set up, drive to the point of action, hand over, then **stop and wait** for the human's reply before touching the next item. Never batch items, never run ahead.
- **Never report a result you weren't given.** If the human didn't say it passed, it didn't pass — it's "not exercised". Do not infer a result from the fact that a command succeeded or a page rendered.
- **Don't fix code mid-run.** A QA pass measures one build. If the human reports a bug, capture it and move on; fixing invalidates every item already run. Offer to fix after the run.

## Before the first item

1. **Agree the item list.** Assemble the candidate items (see *The plan*) and present them as a high-level overview: numbered titles with at most a one-line gist each, plus where they came from (the diff, the spec, previous findings). Do not paste the full Given → When → Then sequences here — the human is checking scope ("is anything missing? is anything pointless?"), not proofreading wording, and a wall of sequences buries that question. The full sequences live in the notes file (give its path for anyone who wants them) and reach the human one at a time during the run. Get agreement before setting up the first one — better to hear now that something is missing than at item 7 — then write the agreed list, full sequences included, to the notes file.
2. **Start from what already exists**, don't build a test environment from scratch. A running dev environment, seeded data, accounts in the right states, a documented way in (magic link, impersonation, developer login buttons, a seeder, a `make` target) — assume the project has these. Often the project context tells you: read CLAUDE.md / AGENTS.md / the dev docs and use the path they describe instead of inventing one. Where it doesn't tell you, ask the human rather than guessing — they know their environment. Either way, setup you do yourself should only close the gap between what exists and what the checklist needs.
3. **Confirm you're testing the intended build.** How you check this is project-specific — the point is that a missing button is far more likely to be a stale build than a bug, so establish the build's identity before judging anything, and re-check it before reporting a surprise. Don't rebuild, migrate, or restart anything the human didn't ask for; if you think the build is stale, say so and let them decide.
4. **Hand off what only they can do.** External logins, third-party connections, hardware, anything behind their credentials. Ask, then wait for confirmation before continuing.
5. **Note every change you make** — records created, settings altered — so you can put it back and they can too. Prefer setting a value explicitly over deleting it; deleting can expose a default that silently changes behaviour.
6. **Tell them the state you've arranged** — which record is in which state, which URL, which account — and check they're ready before the first item.

## Each item

Do your setup calls first, then hand the item over with `AskUserQuestion`. That tool blocks until they answer, so it enforces one-item-at-a-time for you. One call carries exactly one item — the tool accepts multiple questions per call, but bundling items is batching. If their reply is a question or a tangent rather than a result, answer it and re-present the same item; it stays open until they give a result.

**The whole item must go inside the tool call.** Prose written in the same turn as the call is not displayed to the human, so anything left outside it is lost — including the thing you wanted them to watch for. Put the item's title in `header` and the scenario in `question`. The `question` carries the item's agreed Given → When → Then sequence from the notes file, verbatim apart from substituting the concrete state you just arranged (record IDs, URLs, account names); don't re-draft it in your own words — the wording was authored at planning time, and if an item reaches you without its sequence, that's a planning miss to go fix in the notes file first, not an invitation to improvise one. The sequence reads: **Given** which record, on which screen, already set up by you; **When** the one thing they do; **Then** what a pass looks like, concretely. No markdown in either field — it is rendered literally.

Give exactly two options, `PASS` and `FAIL`. Add no others: the tool always offers a free-text "Other", and that is where "partial", "blocked", "couldn't get there" and the verbatim error wording belong.

> `header`: Item 3 — Publish a draft with no cover image
>
> `question`:
> Given post #412 is open in the editor (draft, no cover image).
>
> When you click Publish.
>
> Then a dialog warns the cover image is missing, and cancelling leaves the post a draft.
>
> `options`:
> - `PASS` — "Behaved as described under Then"
> - `FAIL` — "Did not behave as described"

Bad pass criteria are vague ("check it works"). Good ones name the specific observable: the wording, the state afterwards, the absence of a thing.

## Cover the failure paths

Happy paths get tested by accident; failure paths don't. Deliberately include invalid input, missing permissions, an upstream service erroring, a partial batch where one item fails. For each, the pass criterion is usually: it doesn't hang, the message is understandable to the actual user, and the system lands in a sane state. Capture the exact wording of errors — that's often the finding.

## Driving a browser

Do the silver-plattering in the human's Chrome via the claude-in-chrome tools: navigate, fill forms, and leave the exact screen open on the moment of truth, so the human only clicks the one button and judges.

- Never trigger a native `alert`/`confirm` — it freezes automation. If one appears, ask the human to dismiss it.
- When clicking a `<select>` or checkbox is unreliable, set the value via JS — but fire the event the page actually listens on (`change`), or handlers won't run.
- Take a screenshot for any failure.

## Recording results

Track progress in the session task list, not in your head: `TaskCreate` one task per checklist item before you start, then `TaskUpdate` each to `in_progress` when you set it up and `completed` when the human has reported back, so they can see how far along the run is. Completed means the item was *run*, not that it passed — the result itself goes in the notes.

Keep notes and screenshots in the session scratchpad, and write each result as the human reports it rather than reconstructing everything at the end: **pass / fail / not exercised**, in their own words. For a failure also record exact repro steps, expected vs actual, the verbatim message, and a screenshot. If they reported a failure without saying what they actually saw, ask before moving on.

Keep a short **out of scope** list of known, already-ticketed issues and tell the human up front, so they don't spend the session re-reporting them.

## Closing the run

Finish with the summary **and the full absolute path to the notes file**, on its own line so it can be copied in one go. The human hands that path to a fresh session that fixes the findings, and that session has none of this conversation — so the file has to stand on its own:

- every finding with file and line, repro steps, expected vs actual, and the verbatim error text
- which items passed, which failed, and which were never exercised and why
- environment changes still un-restored, and which are the tester's call
- open design questions, kept separate from defects

## Re-running after fixes

When QA follows an earlier pass:

- Read the previous findings first — the file's path is the usual handoff. Items that failed before get **extra scrutiny**, not a quick re-check — say so in the item, and verify the specific mechanism that failed, not just that the symptom is gone.
- Re-run the paths that worked before too. A fix for one item routinely breaks the item next to it.
- If a previous finding was a design gap rather than a bug, confirm what behaviour was actually decided on before judging the new behaviour against your own assumption.

## Common mistakes

| Mistake | Fix |
| --- | --- |
| "Verifying" a handed-in plan against the code before presenting it — grepping for the button labels, opening the diff | The plan is the input, not a claim under review. Present it for agreement as-is; wrong details surface during that item's setup. |
| A Given → When → Then sequence all on one question line, making it hard to scan | Break up the question text into multiple lines, so each section of the Given → When → Then sequence sits on its own paragraph. |
| A **When** that reads as a list of navigation steps, a form to fill in, or a login to perform | You handed over too early. Drive it yourself — browser automation, CLI, direct data writes — and silver-platter a screen already in position, so their part is the single action under test. |
| Driving an item yourself and recording a pass, because the outcome looked objective — a redirect fired, a row saved, a form submitted without error | Hand it over anyway. "The result was unambiguous" is the rationalisation the non-negotiable exists to block, and an item you can settle alone belongs in an automated test rather than in this run. Driving the *setup* is your job; judging the *result* never is. |

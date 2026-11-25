---
name: second-opinion
description: Dispatch a stronger model to critique work already done in this session.
disable-model-invocation: true
---

Dispatch a single synchronous subagent on Fable (a more expensive, higher-judgment model) to critique work you have already done in this session. You do the grunt work; Fable reviews it once at the point where extra judgment pays off. Then you triage its findings and continue.

## When to escalate — and when not to

Escalate only at a genuine judgment point where being wrong is costly and a fresh, stronger critic plausibly catches something you missed:

- Second opinion on a root-cause analysis or diagnosis before acting on it.
- Adversarial review of a nontrivial draft: a design, a prompt change, a subtle diff.
- Sanity check of your reasoning when debugging is stuck after real effort.
- A thorny architecture or tradeoff decision with lasting consequences.
- Verifying a risky, irreversible action (data migration, deletion, external side effect) before performing it.

Do NOT escalate for anything you can resolve by reading code, docs, or tests yourself; for routine changes, mechanical refactors, or style questions; for questions the user should decide (ambiguous requirements, product choices); or to have Fable do work — investigation, editing, and writing stay with you. Budget rule of thumb: at most one or two escalations per session, each a single call. If you would not flag the decision to a senior colleague, do not flag it to Fable.

## How to dispatch

Call `Agent` with:

- `model: "fable"` — this override is the entire point; there is no dedicated review agent type.
- `run_in_background: false` — you need the verdict before continuing.
- Omit `subagent_type` (or use the general-purpose catch-all).
- `prompt`: the self-contained briefing below.

## The briefing

The subagent shares none of your conversation context. Everything it needs must be in the prompt:

1. **Role and ground rules.** State that it is reviewing as a critical second opinion. Do not edit any files; critique only. Do not rubber-stamp: if everything genuinely holds, say so explicitly, but actively look for what is wrong or missing first.
2. **The artifact under review, verbatim.** The full analysis, diff, draft, or plan — pasted in, not referenced by file path alone. Include exact file paths and line numbers where relevant so claims are checkable.
3. **Established facts.** What you already verified (test results, reproduction steps, confirmed behavior), clearly separated from what is still hypothesis. This stops Fable from re-litigating settled ground or trusting unsettled ground.
4. **Relevant background.** The goal, the constraints, and the surrounding code or context needed to judge the artifact — enough that no follow-up question is necessary.
5. **Pointed questions.** Two to five specific questions, not "any thoughts?". For example: "Does the evidence actually rule out cause X?", "What failure mode does this diff introduce that the old code did not have?", "Which of these two options is wrong, and why?"
6. **Answer format.** Ask for a verdict per question plus any findings ranked by severity, each with concrete reasoning.

Example skeleton:

```
You are giving a critical second opinion. Do not edit anything; critique only.
Do not rubber-stamp — hunt for flaws first, and only then confirm what holds.

## What is being reviewed
<the analysis / diff / plan, verbatim>

## Established facts (verified)
- <fact + how it was verified>

## Hypotheses (not yet verified)
- <hypothesis>

## Background
<goal, constraints, relevant code excerpts with paths>

## Questions
1. <pointed question>
2. <pointed question>

Answer each question with a verdict and reasoning, then list any additional
findings ranked by severity.
```

## Keep it to one call

One synchronous call is the shape of this skill, not a back-and-forth collaboration. If the answer exposes a gap in your briefing, prefer fixing the briefing and re-dispatching once over an extended dialogue; `SendMessage` to the same agent is acceptable for a single clarifying follow-up. If you find yourself planning a third exchange, the problem is the briefing or the escalation was premature — stop and do more groundwork yourself.

## Relay and triage the findings

The subagent's final message comes back as the tool result and is NOT shown to the user. After the call:

1. Relay the substance of Fable's findings to the user — verdicts, caught issues, and its reasoning where it matters.
2. Triage each finding yourself: apply it, or reject it with a stated reason. Fable can be wrong too; do not blindly implement its suggestions, and do not silently drop the ones you disagree with.
3. State what you are doing next and why, then continue the work yourself.

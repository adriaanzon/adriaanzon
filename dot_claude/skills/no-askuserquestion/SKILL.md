---
name: no-askuserquestion
description: Disable the AskUserQuestion tool for this session — ask all questions as plain markdown text instead.
disable-model-invocation: true
---

<!-- Workaround for https://github.com/anthropics/claude-code/issues/65662 -->

For the rest of this session, do NOT use the AskUserQuestion tool. Any text in the same message as (or immediately before) an AskUserQuestion call is not shown to the user, so context gets lost.

Instead, ask questions as plain markdown text at the end of your turn:

- Give the necessary context first, formatted normally (markdown is fine here).
- Present options as a numbered list, with your recommendation marked.
- End your turn and wait for the user to reply in chat.
- **Strictly ONE question per turn.** Never bake a second question into the same turn ("and a small follow-up...", "also, is X fine?"). Known failure mode: the user answers the numbered options with "1" and the extra question silently goes unanswered — then gets treated as agreement. If a follow-up exists, hold it for the next turn.
- **Never skip an unanswered question.** If a reply doesn't address something you asked, re-ask it before moving on; don't assume silence means the default is fine.

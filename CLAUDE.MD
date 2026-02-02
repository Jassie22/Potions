# CLAUDE.md

This repository is a **potion-based focus / productivity app** (Forest-style, but gamified with potions, streaks, and progression).

This file is the **long-term memory** of the project. Claude must read this before writing code. If something breaks twice, it belongs here.

---

## Role

You are a **senior product-minded engineer**.

Your job is to:

* Help design clean systems
* Avoid rework and fragile logic
* Turn decisions into written rules

Do not rush into implementation. Architecture and rules come first.

---

## Project Intent (High-Level)

This app helps users:

* Focus for timed sessions
* Earn potion-like rewards
* Build streaks and habits
* Feel progress visually and emotionally

Exact mechanics may evolve. The system should stay flexible.

---

## Core Principles

* **Simple systems beat clever systems**
* **State must be explainable** (why does the user have this potion?)
* **Progress must feel earned**
* **No silent punishment** (users should always understand losses/reset)

---

## Engineering Guardrails

### Time

* Store all timestamps in UTC
* Convert to local time only in the UI

### State & Progress

* User progress should be derivable or auditable
* Avoid hidden side effects
* Prefer explicit state transitions

### Consistency

* The same action should always produce the same result
* Retrying an action must not duplicate rewards

---

## Architecture Expectations

Before building a feature:

1. Clarify the user-facing behavior
2. Define the state changes
3. Decide what is persisted vs derived

If this is unclear, stop and design first.

---

## UX Rules

* Feedback must be immediate
* Visual progress > raw numbers
* Failure states should be gentle, not punishing

Gamification should motivate, not stress.

---

## When Adding New Mechanics

For any new mechanic (potions, streaks, boosts, penalties):

* What triggers it?
* What state does it change?
* Can it be abused?
* How is it explained to the user?

Write the answers before coding.

---

## Testing Expectations

* Core focus/session logic should be testable
* Time-based logic must be deterministic in tests
* Edge cases (pause, resume, abandon) must be handled intentionally

If behavior feels fuzzy, add a test or a note here.

---

## When You’re Stuck

Do not brute-force UI or logic.

Ask:

* Is the state model clear?
* Is this rule written down?
* Should this be simplified?

If a workaround feels hacky, it probably is.

---

## Tone for Claude Responses

* Clear
* Calm
* Product-aware
* Bias toward maintainability

Avoid overengineering. Avoid vibes-only logic.

---

## Workflow Rules

### Commits

* After every large change (new feature, phase completion, major refactor), **make a git commit** with a clear message describing what changed.
* Do not batch multiple unrelated features into one commit.

### MCP Servers

* Use **Supabase MCP** for any backend/database operations when applicable.
* Use **Context7 MCP** for documentation lookups and context retrieval when applicable.

---

## Golden Rule

If the same question or bug appears twice, **update this file**.

Fix the system, not just the symptom.

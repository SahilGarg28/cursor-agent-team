---
name: agent-team
description: >-
  Orchestrates a four-role agent team (Manager, Executor, Validator, QA) for any
  task — coding, research, writing, analysis, debugging, or ops. Use when the
  user runs /agent-team, says "use the agent team", "multi-agent workflow",
  "executor validator manager qa", wants delegated work with quality gates, or
  asks for managed task execution with review loops.
disable-model-invocation: true
---

# Agent Team

Four-role pipeline: **Manager (you)** → **Executor** → **Validator + QA (parallel)** → **Manager verdict**. Loop until APPROVED or BLOCKED.

Launch roles via dedicated Task `subagent_type` values (`team-executor`, `team-validator`, `team-qa`) so Cursor loads the matching agent contract. This skill owns orchestration only — do not paste full role prompts here.

## Triggers

Activate when the user:
- Runs `/agent-team` (with or without a task)
- Says "use the agent team", "agent squad", "multi-agent team"
- Wants managed execution with validation and QA gates
- Asks for executor / validator / manager / QA workflow

**Vague ask:** ask **one** clarifying question (goal, constraints, or success criteria), then proceed.

## Team Roster

| Role | Responsibility | Task `subagent_type` | `readonly` |
|------|----------------|----------------------|------------|
| **Manager** | Frame, criteria, revise/approve | Parent agent (you) — do **not** launch `team-manager` | false |
| **Executor** | Deliver the work | `team-executor` | false |
| **Validator** | Requirements fit | `team-validator` | true |
| **QA** | Holistic quality | `team-qa` | true |

**You are the Manager.** Never delegate management to a subagent.

For code-heavy tasks, QA may additionally launch one `bugbot` or `security-review` (`readonly: true`) and fold findings into the QA report.

## Models (optional)

Assign only when useful. If a slug is unavailable, omit `model` and use the Task default.

| Role | Suggested model | Why |
|------|-----------------|-----|
| Executor | `claude-4.6-sonnet-medium-thinking` | Balanced execution |
| Validator | `gpt-5.5-medium` or `composer-2.5-fast` | Structured checking |
| QA | `claude-4.6-opus-high-thinking` | Deep assessment |
| Alt (any) | `grok-4.5-xhigh` | Strong general alternative |
| Code QA (optional) | `bugbot` subagent | Diff-focused bugs |

## Workflow

```
1. Manager: Task Brief + acceptance criteria
2. Executor: deliver
3. If Executor BLOCKED (external dependency) → Manager BLOCKED immediately (skip Validator/QA)
4. Else: Validator + QA parallel review (one message, two Tasks)
5. Manager: APPROVED | REVISE | BLOCKED
6. If REVISE: Revision Brief → Executor → step 3–5 (max 3 revision rounds)
7. Present outcome + team report to user
```

### Step 1 — Task Brief

Write this before launching Executor. Criteria must be **testable**; if empty/vague, tighten them first.

```markdown
## Task Brief
- **Goal:** (one sentence)
- **Type:** code | research | writing | analysis | debugging | ops | mixed
- **Scope in:** ...
- **Scope out:** ...
- **Constraints:** (stack, style, "do not touch X")
- **Deliverables:** (specific files/artifacts/answers)
- **Acceptance criteria:** (numbered, testable)
- **Context:** (paths, prior decisions, known pain points)
```

### Step 2 — Launch Executor

`subagent_type: "team-executor"`, `readonly: false`. Optional: attach workspace files needed for the task (not role-agent markdown).

```
Full Repository Path: {absolute path or "N/A"}

## Task Brief
{brief}

## Revision Brief (if any)
{revision brief}
```

**Attach on handoff:** Task Brief (+ Revision Brief if any). Do not attach Validator/QA reports to Executor except as distilled Must-fix items in the Revision Brief. Role contract comes from `subagent_type` only — **never** attach `~/.cursor/agents/team-*.md` as the role prompt.

**Short-circuit:** If Executor returns **BLOCKED** due to external dependency (missing secrets, access, env, or user input), Manager issues **BLOCKED** immediately with user action — **do not** launch Validator or QA. Proceed to Step 5.

### Step 3 — Launch Validator + QA (parallel)

Skip this step when Step 2 short-circuited. Otherwise one message, two Task calls:
- Validator: `subagent_type: "team-validator"`, `readonly: true`
- QA: `subagent_type: "team-qa"`, `readonly: true`

Attach to **each**: Task Brief + full Executor output (status, summary, handoff notes). For revisions, also attach the Revision Brief.

```
Full Repository Path: {path}

## Task Brief
{brief}

## Revision Brief (if any)
{revision brief}

## Executor output
{full executor return}
```

Role contracts come from `subagent_type` only — **never** attach `~/.cursor/agents/team-*.md` as the role prompt.

### Step 4 — Manager verdict

Synthesize both reviews. Use this table — no ambiguity:

| Condition | Verdict |
|-----------|---------|
| Validator PASS **and** QA SHIP | **APPROVED** |
| Executor DONE/PARTIAL, gaps are **fixable by Executor** (Validator FAIL/PARTIAL and/or QA REVISE with CRITICAL/MAJOR) | **REVISE** |
| Executor BLOCKED on external dependency Executor cannot resolve | **BLOCKED** immediately — **skip** Validator/QA |
| Validator FAIL or QA REJECT because work is unusable **and** root cause is external (missing creds, no access, wrong repo, impossible criteria) | **BLOCKED** |
| Same issue repeated after a prior REVISE | Count toward rounds; after **3** revision rounds → **BLOCKED** |
| QA REJECT with only fixable quality gaps (no external blocker) | **REVISE** (not BLOCKED) |
| Validator FAIL on criteria, but Executor can fix in-repo | **REVISE** |

**APPROVED** requires both PASS and SHIP. Never approve on PARTIAL + SHIP or PASS + REVISE.

**Revision Brief** (required for REVISE) — ban vague directives ("improve quality", "fix issues"):

```markdown
## Revision Brief (round N/3)
### Keep
- (what already works — do not regress)

### Must fix (from Validator)
1. (criterion # + concrete gap + expected evidence)

### Must fix (from QA — CRITICAL/MAJOR only)
1. (finding + concrete fix)

### Do not change
- (out of scope / already correct)
```

Re-launch Executor with **original Task Brief + Revision Brief**. Then re-run Validator + QA in parallel. Increment round counter.

### Step 5 — Present to user

```markdown
# Agent Team: {goal}

## Outcome: **{APPROVED | BLOCKED}**
{1–2 sentences}

## Deliverables
- ...

## Team report
| Role | Verdict | Headline |
|------|---------|----------|
| Executor | DONE/PARTIAL/BLOCKED | ... |
| Validator | PASS/FAIL/PARTIAL or — (not launched) | ... |
| QA | SHIP/REVISE/REJECT (X/10) or — (not launched) | ... |
| Manager | APPROVED/BLOCKED | ... |

### Revision rounds: {N}
### Remaining risks / follow-ups
1. ...
```

On BLOCKED, add **User action required** with concrete next steps.

## Failure modes (act explicitly)

| Signal | Manager action |
|--------|----------------|
| **Executor BLOCKED** | If external (secrets, access, env, user input) → **BLOCKED** immediately + user options; **do not** launch Validator/QA. If misunderstanding of brief → **REVISE** once with clarified Must fix (then reviews as usual). |
| **Executor PARTIAL** | Treat as incomplete delivery. If remaining work is in-scope and doable → **REVISE**; if acceptance criteria themselves are impossible → **BLOCKED** and renegotiate criteria with user. |
| **Validator FAIL** | **REVISE** with criterion-linked Must fix — unless failure is purely external → **BLOCKED**. |
| **Validator PARTIAL** | **REVISE** for unmet criteria; do not APPROVE. |
| **QA REVISE** | **REVISE** using CRITICAL/MAJOR only in Must fix; drop MINOR/NIT unless user asked for polish. |
| **QA REJECT** | If unusable + external root cause → **BLOCKED**. If fixable in-repo → **REVISE**. |
| **Max 3 revision rounds** | Stop; **BLOCKED**; summarize unresolved gaps and user options. |
| **Same-issue repeat** | If round N+1 shows the same Must-fix still open → escalate early: one sharper Revision Brief, then if still open at round 3 → **BLOCKED** (do not invent new work). |
| **Vague user ask** | One clarifying question, then brief — do not launch Executor on an empty goal. |
| **Empty/vague acceptance criteria** | Manager writes testable criteria before step 2. |
| **Model unavailable** | Omit `model`; continue with default. |

## Task-type adaptations

| Type | Executor | Validator | QA |
|------|----------|-----------|-----|
| **Code** | Implement + tests | Criteria + tests | Bugs, security, edges; optional `bugbot` |
| **Research** | Gather + synthesize | Questions + sources | Accuracy, gaps, bias |
| **Writing** | Draft | Brief match, length | Clarity, tone, factual risk |
| **Debugging** | Reproduce + fix | Bug resolved | Regression, root cause |
| **Analysis** | Data/query | Metrics match ask | Methodology, assumptions |

## Rules

1. Manager stays in parent — subagents do not manage each other.
2. Executor first; never review before delivery.
3. Validator and QA parallel after each Executor pass **except** external Executor BLOCKED (short-circuit — skip reviews).
4. Max 3 revision rounds, then BLOCKED with user options.
5. Minimize scope — reject creep in Revision Briefs.
6. Evidence over opinion — require concrete citations from Validator/QA.
7. Approved work ends with real artifacts (unless the deliverable *is* a report).
8. Role contracts via `subagent_type` only — never attach `team-*.md` paths as prompts; this skill owns orchestration, verdicts, and failure modes.

## Optional: ad-hoc roles

Invoke `team-executor`, `team-validator`, or `team-qa` as a one-off Task. Do not launch `team-manager` for the main loop — you remain Manager. The full `/agent-team` loop still requires you as parent.

## Additional resources

- Worked patterns: [examples.md](examples.md)
- Role agents: `~/.cursor/agents/team-manager.md`, `~/.cursor/agents/team-executor.md`, `~/.cursor/agents/team-validator.md`, `~/.cursor/agents/team-qa.md`

Repo copy also lives at `agents/` in this repository.

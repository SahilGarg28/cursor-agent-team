# Agent Team — Examples

Patterns only. Orchestration lives in [SKILL.md](SKILL.md); role contracts in `~/.cursor/agents/team-*.md` (`team-manager`, `team-executor`, `team-validator`, `team-qa`).

Repo copy also lives at `agents/` in this repository.

---

## 1. APPROVED path (code)

**Ask:** `/agent-team fix the null pointer in RefundService`

**Brief (abbrev):** Scope = `RefundService` + tests. Criteria: (1) no NPE on null amount (2) 400 + clear message (3) existing tests pass; new null-case test.

**Loop:** Executor DONE → Validator PASS + QA REVISE (MAJOR: generic error message) → Manager **REVISE** once → Executor fixes message → Validator PASS + QA SHIP → **APPROVED**.

```markdown
# Agent Team: Fix NPE in RefundService

## Outcome: **APPROVED**
Null amount returns 400; null-case test added; one revision for error wording.

## Deliverables
- `src/services/RefundService.ts` — guard + ValidationError
- `tests/RefundService.test.ts` — `handles null amount`

## Team report
| Role | Verdict | Headline |
|------|---------|----------|
| Executor | DONE | Guard + test; `npm test` green |
| Validator | PASS | All 3 criteria met |
| QA | SHIP (8/10) | Message tightened in rev 1 |
| Manager | APPROVED | |

### Revision rounds: 1
### Remaining risks
- Same null pattern may exist elsewhere — out of scope
```

---

## 2. REVISE handoff (research)

**Ask:** `/agent-team research why batch a5f561ce4 had 40% failures`

After v1: Validator PARTIAL (criterion 3 — no recommendation); QA REVISE (MAJOR — "timeout" mixes HTTP 504 and DB timeout).

**Manager → Executor (do this shape; never vague):**

```markdown
## Revision Brief (round 1/3)
### Keep
- Overall failure rate from CSV (correct)

### Must fix (from Validator)
1. Criterion 3: add one actionable recommendation tied to the top failure mode

### Must fix (from QA — CRITICAL/MAJOR only)
1. Split "timeout" into HTTP 504 vs DB timeout with separate counts

### Do not change
- Source CSV path, date window, or top-level failure rate formula
```

Then re-run Validator + QA. That is the revision contract — Keep / Must fix / Do not change; no "improve quality".

---

## 3. BLOCKED path (external dependency — escalate immediately)

**Ask:** `/agent-team migrate auth to OAuth2`

Executor BLOCKED (no `OAUTH_CLIENT_SECRET`). Manager **BLOCKED** immediately — **do not** launch Validator or QA; do not burn revision rounds on an external secret.

```markdown
# Agent Team: Migrate auth to OAuth2

## Outcome: **BLOCKED**
Missing client credentials — Executor cannot complete integration.

## Team report
| Role | Verdict | Headline |
|------|---------|----------|
| Executor | BLOCKED | No `OAUTH_CLIENT_SECRET` in env |
| Validator | — (not launched) | Skipped on external BLOCKED |
| QA | — (not launched) | Skipped on external BLOCKED |
| Manager | BLOCKED | External dependency |

### Revision rounds: 0
### User action required
1. Add `OAUTH_CLIENT_SECRET` to `.env`
2. Re-run `/agent-team migrate auth to OAuth2`
```

Burn revision rounds only for stuck **fixable** in-repo issues (same Must-fix still open after REVISE), not for missing secrets/access.

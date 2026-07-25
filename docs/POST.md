# Draft social post (LinkedIn / X)

---

**One agent, one shot, hope it’s right.**

That’s how most of us use Cursor today — a single model writes code, reviews itself, and ships. It works until it doesn’t: missed acceptance criteria, vague “fixes,” revision loops that burn tokens without getting closer to done.

**Agent Team** is a Cursor skill + four role agents that turn that into a real pipeline:

**Manager** (you) frames the task and sets testable criteria → **Executor** delivers → **Validator** checks requirements fit → **QA** assesses quality → Manager issues **APPROVED**, **REVISE**, or **BLOCKED**.

Key ideas:
- Parallel Validator + QA after each delivery pass
- Structured Revision Briefs (Keep / Must fix / Do not change) — no more “improve quality”
- Short-circuit on external blockers (missing secrets, access) instead of wasting review rounds
- Max 3 revision rounds, then escalate with clear user action

Works for code, research, writing, debugging, ops — anything you can brief with acceptance criteria.

Install: clone [github.com/SahilGarg28/cursor-agent-team](https://github.com/SahilGarg28/cursor-agent-team), run `./install.sh`, then try `/agent-team fix the login timeout bug`.

Open source (MIT). Feedback and PRs welcome — [@SahilGarg28](https://github.com/SahilGarg28).

---

**Hashtags (optional):** #Cursor #AIAgents #DeveloperTools #LLM #OpenSource

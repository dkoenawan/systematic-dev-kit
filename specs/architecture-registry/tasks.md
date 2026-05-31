---
issue: 11
branch: feat/architecture-registry
status: in-progress
test_command: null
last_skill_commit: a035742239d03da2df2933e8fb93e4168e522a94
retry_counts: {}
schedule: "0 */6 * * *"
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

- [x] Write registry file format templates — docs/registry/index.md (L0, 80-line limit), docs/registry/constructs/<Name>.md (L1 with all frontmatter fields), docs/registry/patterns.md, docs/registry/decisions/index.md, docs/registry/decisions/<NNN>-<title>.md
- [ ] Write /adr skill SKILL.md — 6-phase conversation, MADR output with options table, pattern detection, NFR capture, affected construct cross-linking, decisions/index.md append (depends on: 1)
- [ ] Extend init skill — greenfield registry bootstrap: create docs/registry/ skeleton on init, write ADR-001 from stack choices, inject agent nav protocol into target project CLAUDE.md (depends on: 1)
- [ ] Extend init skill — brownfield-migrate mode: seed registry from specs/*/overview.md + src/ tree + schema file + IaC grep, max 5 source reads, generate migration report showing N planned / N built / N gaps (depends on: 3)
- [ ] Extend doc-maintainer skill — registry consistency passes: bidirectional link enforcement (spec ↔ construct), back-link reconciliation, stub verification 3/run, Known Gaps reduction 1/run, L0 80-line size guard, existing C4 passes unchanged (depends on: 1)
- [ ] Extend doc-maintainer skill — HTML regeneration: generate docs/index.html (arc42 structure, searchable construct registry, feature cross-reference, worked examples, ADR viewer) from registry markdown on each maintain run (depends on: 5)
- [ ] Extend plan skill — registry read before designing: read L0 "Does" column + Feature Cross-Reference before any proposal, invoke explore only for Known Gap areas, present found constructs to user before Q1 (depends on: 1)
- [ ] Extend plan skill — registry write after spec approval: write construct stubs (status: planned) with FR list and planned interface, append rows to L0 index, create domain directory if new (depends on: 7)
- [ ] Extend explore skill — registry as Tier 1: read L0 + relevant construct files before source code, sufficiency gate fires if registry covers focus area with no gaps, write newly discovered constructs to registry after investigation (depends on: 1)
- [ ] Extend task-executor skill — mandatory pre-task registry check: read L0 + relevant construct files before every task, search for constructs about to be created or modified, Known Gap domain fallback ls check (depends on: 1)
- [ ] Extend task-executor skill — mandatory post-task registry write: write or update construct file (planned→built with real interface and dependencies), update L0 row, note cross-domain dependencies for doc-maintainer to reconcile (depends on: 10)
- [ ] Write post-hook validator skill — reads FRs from construct file after each task-executor commit, generates human FR checklist, developer marks pass/fail, transitions status to verified or diverged, auto-triggers /adr on divergence and blocks next task until ADR written (depends on: 2, 11)

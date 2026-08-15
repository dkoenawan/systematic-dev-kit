---
id: 001
date: 2026-08-15
status: Proposed
affects: [doc-maintainer, plan, task-executor, adr]
---

# ADR-001: Diataxis-based docs/ restructure with docs/sessions/ fold-back

## Context

The plugin currently runs two documentation systems that don't connect to each
other:

- **`specs/{feature}/overview.md` + `tasks.md`** — session-scoped planning and
  execution state, written by `plan` and `task-executor`. Read once for task
  decomposition, then effectively archived. Nothing ever reconciles this content
  back into durable docs once a feature branch merges.
- **`docs/`** — a durable C4-layered tree (`solution-design.md` L1,
  `containers.md` L2, `<domain>/overview.md` L3) maintained incrementally by
  `doc-maintainer`, plus a parallel `docs/registry/` (constructs, ADRs, patterns)
  that indexes the same codebase at construct granularity.

This is workable session-by-session but breaks down at scale:

1. **No reader-oriented organization.** Both `docs/` and `docs/registry/` are
   organized by architecture layer or construct, not by how a reader approaches
   documentation (I want to learn / I want to do a task / I want to look up a
   fact / I want to understand why). There's no single, well-known place to land
   depending on intent.
2. **`specs/` content is disposable.** A completed build or debugging session
   produces real institutional knowledge — decisions made, dead ends hit,
   gotchas discovered — that is never folded back into the durable docs tree.
   It just sits in a merged branch's `specs/` history until someone goes
   spelunking through git log.
3. **No Feature → Pages → API specs → Technical architecture hierarchy.** These
   pieces exist today in three unconnected places: the registry's Feature
   Cross-Reference table (FR/NFR per construct), `plan`'s Frontend/Backend spec
   sections (pages, API shapes), and the C4 docs (technical architecture). A
   reader who wants to trace one feature end-to-end has to manually stitch these
   together.

The README already flags an unbuilt "L4 feature-tracing" idea
(`docs/features/<feature-name>.md`, frontend → backend → domain → adapter →
database) as future direction. This ADR supersedes that note with a fuller,
scoped plan.

## Decision

Adopt the [Diataxis](https://diataxis.fr/) framework as the top-level structure
of `docs/`, and replace `specs/` with `docs/sessions/` as the single
session-scoped location, with a fold-back mechanism that reconciles completed
sessions into the Diataxis tree.

### 1. `docs/sessions/` replaces `specs/`

`plan` and `task-executor` write session artifacts to
`docs/sessions/<date>-<feature-slug>/` (`overview.md` spec + `tasks.md` execution
state) instead of `specs/<feature>/`. This colocates session output next to the
durable docs it feeds and collapses two session-scoped locations into one.

### 2. `docs/` top level becomes the four Diataxis categories

```
docs/
├── tutorials/       # new — onboarding paths, learning-oriented
├── how-to/          # new — task-oriented guides, seeded by session fold-back
├── reference/        # registry constructs + API specs move here
│   ├── constructs/<Name>.md   # moved from docs/registry/constructs/
│   └── api/                    # new — API specs
├── explanation/      # existing C4 tree + DDD narrative moves here
│   ├── solution-design.md      # moved from docs/solution-design.md (L1)
│   ├── containers.md           # moved from docs/containers.md (L2)
│   ├── <domain>/overview.md    # moved from docs/<domain>/overview.md (L3)
│   ├── features/<feature>.md   # new — Feature -> Pages -> API -> Architecture index
│   └── ddd.md                  # new — domain-driven design framing
├── registry/
│   ├── index.md                 # stays (L0 capability index, now points into reference/)
│   ├── decisions/                # stays (ADRs, unchanged)
│   └── patterns.md               # stays (cross-cutting conventions, unchanged)
└── sessions/<date>-<feature-slug>/
    ├── overview.md
    └── tasks.md
```

`docs/registry/decisions/` and `docs/registry/patterns.md` stay where they are —
they're already well-integrated with the `adr` skill and `doc-maintainer`'s R1–R6
consistency passes. Only `docs/registry/constructs/` moves into
`docs/reference/constructs/`.

### 3. New Feature → Pages → API → Architecture index

`docs/explanation/features/<feature>.md` is a new per-feature index that links:

- **FR/NFR** — sourced from the registry Feature Cross-Reference table and
  relevant ADRs
- **Pages** — sourced from `plan`'s Frontend Layer spec section, pointing into
  `docs/reference/`
- **API specs** — sourced from `plan`'s Backend Layer spec section, pointing
  into `docs/reference/api/`
- **Technical architecture** — pointing into `docs/explanation/` C4 files

This is the concrete realization of the README's flagged L4 feature-tracing idea.

### 4. Fold-back mechanism

On session completion, a new `doc-maintainer` responsibility reads
`docs/sessions/<session>/` and synthesizes relevant content into the four
Diataxis categories — analogous to the existing R1–R6 registry consistency
passes. Candidate design: a new priority-queue item (`S1` fold-back pass) that
runs after L2/L3 generation and before clarity review, bounded to one session
folded back per `maintain` run, matching the "one unit of work per run"
discipline already in place.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| **Diataxis top-level + docs/sessions/ (chosen)** | Reader-oriented navigation; single session-scoped location; explicit fold-back closes the knowledge-loss gap | Requires moving existing `docs/solution-design.md`, `docs/containers.md`, `docs/<domain>/overview.md`, `docs/registry/constructs/*` and rewriting internal links; touches 3 skills |
| **Diataxis as a thin layer alongside registry/C4 (no move)** | Non-disruptive; no file moves or link rewrites | Leaves two overlapping taxonomies (Diataxis folders that just link out, plus the original C4/registry structure) — doesn't actually solve the "hard to follow at scale" complaint, it adds a third index |
| **Keep specs/, add docs/sessions/ as a separate journal** | Lower risk, no rework of `plan`/`task-executor` spec-writing path | Two session-scoped locations to reason about; doesn't address root cause of specs/ being disposable |
| **Do nothing, rely on manual doc hygiene** | Zero engineering cost | Already proven to fail at scale per user report; status quo |

## NFR Captured

- **Discoverability**: a reader or agent must be able to find task-oriented
  guidance, reference facts, and conceptual explanation without knowing the
  internal architecture layering in advance.
- **Token-cost discipline**: fold-back must preserve `doc-maintainer`'s existing
  "one unit of work per run" bound — no bulk resynthesis of all sessions in one
  pass.
- **No knowledge loss on merge**: any session that produces a decision, gotcha,
  or discovered constraint must have a path into durable docs before its branch
  is deleted.

## Consequences

- `plan` and `task-executor` must be updated to write to `docs/sessions/` instead
  of `specs/`. Existing `specs/architecture-registry/` and
  `specs/task-executor-skill/` content is left in place as historical record (not
  retroactively migrated) unless a follow-up task chooses to fold it back
  manually.
- `doc-maintainer` gains a new fold-back responsibility and its internal file
  paths (`docs/solution-design.md` etc.) all move one level deeper under
  `docs/explanation/` — every skill and script referencing these paths
  (`doc-maintainer` templates, README's C4 table, `docs/index.html` generation)
  must be updated in the same change to avoid dangling links.
- `docs/registry/index.md`'s construct `File` column must be updated to point at
  `docs/reference/constructs/` post-move.
- This ADR does not itself change any skill code — implementation is tracked as
  a follow-up GitHub issue, executed via `task-executor` (matching how ADR-driving
  issue #11 became `feat/architecture-registry`).

## Revisit Conditions

- If fold-back consistently produces low-quality or redundant `how-to/` content
  (session noise rather than durable guidance), reconsider making fold-back
  opt-in/reviewed rather than automatic.
- If the four-category split proves confusing in practice (e.g. contributors
  keep filing content in the wrong category), reconsider collapsing
  `tutorials/` and `how-to/` or dropping Diataxis in favor of a lighter
  task/reference split.

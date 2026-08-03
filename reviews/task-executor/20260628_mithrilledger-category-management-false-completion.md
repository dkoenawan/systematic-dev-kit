# Skill Review: task-executor — MithrilLedger category-management false completion

**Date**: 2026-06-28
**Skill**: `task-executor`
**File**: `reviews/task-executor/20260628_mithrilledger-category-management-false-completion.md`

---

## Invocation

**Skill invoked**: `/systematic-dev-kit:task-executor` (cron-scheduled, issue #79)

**Branch**: `feat/category-management`
**Spec**: `specs/category-management/overview.md` + `specs/category-management/tasks.md`

**tasks.md at completion** (all 9 tasks marked `[x]`):
```
- [x] Write Prisma schema for slv.category + categoryRefId FK; run migrations; regenerate client
- [x] Implement CategoryService.ts with CRUD, Title Case, guards
- [x] Wire POST/PATCH/DELETE /api/v1/categories routes
- [x] Add GET /api/v1/categories; switch GET /api/v1/weekly/categories from TSV to DB
- [x] Add GET /api/v1/transactions (paginated) + PATCH /api/v1/transactions/:id/category
- [x] Implement Python MigrationService.py + migrate-xlsx Click command
- [x] Build useCategories hook + CategoryModal + SubcategoryModal
- [x] Build CategoryList + SubcategoryList + CategoriesPage + /categories route + nav links
- [x] Build TransactionsPage stub + useTransactions hook + /transactions route + nav link
```

---

## What Happened

**Steps that completed correctly**:
- [x] Prisma schema + migrations for `slv.category` and `categoryRefId` FK
- [x] CategoryService.ts — CRUD, Title Case, guard logic, 6 endpoints
- [x] GET /api/v1/categories — queries DB
- [x] GET /api/v1/weekly/categories — switched from TSV to DB
- [x] GET /api/v1/transactions + PATCH /api/v1/transactions/:id/category — endpoints exist
- [x] MigrationService.py + migrate-xlsx CLI command — script written
- [x] Frontend: useCategories, CategoryModal, SubcategoryModal, CategoryList, SubcategoryList, CategoriesPage, /categories route
- [x] Frontend: TransactionsPage stub, useTransactions hook, /transactions route

**Where it diverged from spec**:

> Discovered 2026-06-28 via manual cross-reference against spec and actual DB state.

### Divergence 1 — migrate-xlsx never executed
**Spec said** (overview.md, Implementation Order §2): implement MigrationService.py and "test run against `data/uploads/*.xlsx` (4 files on disk)".
**What happened**: Script was written and task marked complete, but never run. `slv.transaction` and `brz.transaction` remain empty. The spec's intent was to bootstrap historical transaction history into the DB — this did not happen.
**Impact**: `/transactions` page shows nothing. Category management has no historical context. The entire purpose of the migration step was not achieved.

### Divergence 2 — weekly upload flow never wired to DB
**Spec said** (overview.md, PATCH /api/v1/transactions/:id/category): "re-assign category/subcategory on a SlvTransaction; upserts mapping". Implies transactions exist in `slv.transaction` at review time.
**What happened**: The weekly upload flow (file → Python subprocess → JSON → frontend) still does not write to `brz.transaction` or `slv.transaction`. Transactions come back as ephemeral JSON, are displayed in the UI, and are never persisted. The DB endpoints exist but have nothing to operate on.
**Impact**: The transaction review page (`/transactions`) is permanently empty unless `migrate-xlsx` is run and new uploads are wired to write to the DB — neither of which was done.

### Divergence 3 — TSV/DB split never resolved
**Spec said** (overview.md §Backend): "`POST /api/v1/weekly/categorize` writes mapping to TSV" — acknowledged as legacy — and `PATCH /api/v1/transactions/:id/category` should upsert into `slv.category_mapping`. These two paths were intended to converge.
**What happened**: Both paths exist but are completely disconnected. The Python pipeline still reads from `data/master/category_mappings.tsv` (31 rows, mostly Uncategorized). The DB `slv.category_mapping` has 518 rows (seeded manually today, outside the task-executor run). No sync exists between them. New categorisations via the weekly upload UI write to TSV only, never to DB.
**Impact**: The DB mapping table and TSV file are parallel but divergent sources of truth. Auto-categorisation via the weekly upload uses TSV; the DB is inert for categorisation purposes.

### Divergence 4 — TransactionsPage is a stub, not a feature
**Spec said** (overview.md §Frontend): "Transaction review page (stub initially)" — explicitly marked as stub. This was correctly implemented as a stub. However tasks.md marked it `[x] complete` without flagging that the stub was intentional and that the full implementation is a remaining open item.
**Impact**: Minor — the stub was by design — but the task marking created an illusion that the feature was delivered, not deferred.

---

## Root Cause Analysis

### Primary failure: task completion without verification

The task-executor marked tasks complete based on code being written, not on the system behaving as the spec described. There is no evidence that any task was verified by running the actual flow end-to-end.

Specifically:
- Task 6 (MigrationService.py + migrate-xlsx) was marked complete when the script was written, not when it was run against real data and the DB was confirmed populated.
- Tasks 4 and 5 (transaction endpoints) were marked complete when the routes existed, not when transactions were flowing through them.

### Secondary failure: spec's open questions were never resolved

`overview.md` listed three open questions at the bottom:
1. Category seed list — predefined or built from scratch?
2. Should `POST /api/v1/weekly/categorize` validate against `slv.category`?
3. When `/transactions` goes beyond stub, should inline editing reuse CategorySelect or use a modal?

None of these were answered or flagged. The task-executor proceeded as if they didn't exist, leaving architectural decisions unresolved that affected how the pieces connect.

### Tertiary failure: no post-execution verification gate

The task-executor had no mechanism to verify that the feature actually worked after all tasks were checked off. `test_command: null` in tasks.md meant there was no smoke test. A simple end-to-end check (upload file → confirm rows in `brz.transaction` → confirm `/transactions` shows data) would have caught all three divergences immediately.

**Failure pattern**:
- [ ] Natural Stopping Points
- [x] Declarative vs Evaluative Instructions — tasks described what to build, not what success looks like
- [ ] Weak Transition Language
- [x] Other: **No verification gate** — task completion = code written, not feature working

---

## Recommended Fixes

### Fix 1 — task-executor SKILL.md: require a verification step before marking complete

**File**: `skills/task-executor/SKILL.md`

Each task that touches a data flow (ingestion, persistence, API endpoint) must include a verification step before it can be marked `[x]`. The verification step must be an observable system behaviour, not a code existence check.

**Proposed addition** (after the "mark task complete" instruction):
```
Before marking a task [x], answer: "Can I observe the expected behaviour in the running system?"
- For a DB migration: run a SELECT and confirm the table/column exists
- For an ingestion script: run it against sample data and confirm rows appear in the DB
- For an API endpoint: curl it and confirm the response reflects DB state, not empty
- For a frontend component: confirm it renders with real data from the backend, not a stub state

If the answer is "no" or "I cannot verify without running the full stack", do NOT mark the task complete.
Instead mark it [~] (partial) and add a note: "Code written. Verification blocked by: <reason>."
```

### Fix 2 — plan SKILL.md: open questions must be resolved before task generation

**File**: `skills/plan/SKILL.md`

The spec's "Open Questions" section should be a blocking gate, not an appendix. If open questions exist at spec completion, the plan skill should ask the user to resolve them before writing tasks.md — or explicitly mark which tasks are blocked by each unresolved question.

**Proposed addition** (before writing tasks.md):
```
Read the Open Questions section of the spec. If any questions remain unresolved:
- Ask the user to resolve them now, OR
- Mark tasks that depend on the unresolved question as BLOCKED with the question cited

Do not generate tasks.md with unresolved questions that affect task ordering or implementation approach.
```

### Fix 3 — task-executor: populate test_command for integration verification

**File**: `skills/task-executor/SKILL.md` or template

`test_command: null` in tasks.md should be treated as a warning, not a valid state for features that touch the DB or API. The task-executor should require a `test_command` before scheduling cron runs for features that have data flows.

---

## What Had to Be Done Manually (2026-06-28)

The following work was required to recover the state the spec intended:

1. **Fixed Prisma v7 runtime crash** — `PrismaClient` requires a driver adapter in v7; services were constructing it bare. Created `backend/src/db.ts` shared instance. Added `npx prisma generate` to Dockerfile.
2. **Fixed Docker build** — `task build` was broken; resolved by the above.
3. **Seeded `slv.category_mapping`** — wrote `backend/prisma/seed.ts` to migrate 518 rows from `data/migration/category_mappings.tsv` into Postgres, normalising diverged category/subcategory strings.
4. **Seeded `slv.category` hierarchy** — canonical 9 categories / 26 subcategories defined and inserted.
5. **Added delete protection + audit log** — migration `20260628000001` with Postgres RULE (no hard deletes) and UPDATE trigger to `slv.audit_log`.
6. **migrate-xlsx was NOT run** — historical transactions are still not in the DB. This remains outstanding.

All of the above should have been either done by the task-executor or explicitly flagged as out-of-scope.

---

## Follow-up Checklist

- [ ] Fix 1 applied to `skills/task-executor/SKILL.md`
- [ ] Fix 2 applied to `skills/plan/SKILL.md`
- [ ] Fix 3 applied to task-executor template
- [ ] `migrate-xlsx` run against historical `.xlsx` files in MithrilLedger
- [ ] Weekly upload flow wired to persist to `brz.transaction` / `slv.transaction`
- [ ] TransactionsPage built out beyond stub
- [ ] Re-test: category-management feature works end-to-end (upload → DB → /transactions page shows data)

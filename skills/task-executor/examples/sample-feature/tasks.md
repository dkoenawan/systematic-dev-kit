---
issue: 42
branch: feat/user-roles
status: in-progress
test_command: bun test
last_skill_commit: a3f8c1d2e9b047f6a1234567890abcdef12345678
retry_counts:
  5: 1
schedule: "0 */6 * * *"
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

- [x] Add `User.role` field to Prisma schema
- [x] Generate and apply migration (depends on: 1)
- [x] Implement `AssignRoleCommand` with validation (depends on: 2)
- [!] Wire up `/admin/users` route (failed 2026-05-01: tsc errors in adjacent file — `src/routes/admin.ts` has unrelated type errors blocking compilation)
- [ ] Add role badge to user list (depends on: 4)
- [ ] Write integration test for role assignment (depends on: 3)

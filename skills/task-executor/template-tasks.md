---
issue: <github-issue-number>
branch: feat/<feature-name>
status: in-progress
test_command: <test-command or null>
last_skill_commit: null
retry_counts:
schedule: "0 */6 * * *"
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

- [ ] <first task — no dependencies>
- [ ] <second task> (depends on: 1)
- [ ] <third task> (depends on: 1)
- [ ] <fourth task — requires both 2 and 3> (depends on: 2, 3)
- [x] <already completed task>
- [!] <failed and skipped task> (failed 2026-01-15: tsc errors in adjacent file — manual fix needed)

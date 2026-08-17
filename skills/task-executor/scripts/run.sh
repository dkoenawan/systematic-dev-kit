#!/bin/bash
# Wrapper for the task-executor cron job.
# Logs start/end timestamps and exit code so missed or broken runs are visible.

LOG_DIR="/home/su-sentinel/private/compass-labs/logs/task-executor"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ===== task-executor started =====" >> "$LOG_FILE"

/home/su-sentinel/.local/bin/claude \
  -p "You are implementing the task-executor skill. Read specs/task-executor-skill/overview.md and check the Implementation Order section. Find the first phase not yet marked complete (look for a checkmark or DONE marker next to each phase heading). Implement that phase fully: write all the files, scripts, or SKILL.md changes it requires. Commit your work with conventional commit messages as you go. When the phase is done, mark it complete in overview.md by appending \" ✓\" to that phase heading and commit that too. If all phases are complete, open a PR against main using gh pr create with a summary of what was built." \
  --dangerously-skip-permissions \
  >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

echo "[$(date '+%Y-%m-%d %H:%M:%S')] task-executor exited with code $EXIT_CODE" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] ===== task-executor finished =====" >> "$LOG_FILE"

exit $EXIT_CODE

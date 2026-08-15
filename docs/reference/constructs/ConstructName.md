---
name: ConstructName
type: Service          # Service | Component | Repository | Model | Resource | Utility | Middleware | Hook
layer: Backend         # Backend | Frontend | Database | Infra | Shared
file: src/services/construct-name.ts
status: planned        # planned | built | verified | diverged
planned_in: docs/sessions/<date>-<feature>/overview.md
last_verified: null    # YYYY-MM-DD when status last confirmed
---

## Does

One or two sentences describing what this construct does. Lead with the verb.
Call out explicitly what it does NOT do, referencing the constructs that handle those concerns.

## Functional Requirements

- [ ] FR1 description (user-facing, testable, specific)
- [ ] FR2 description
- [ ] FR3 description

## Proof

- method: null          # human | automated
- verified_by: null     # name date
- checklist_result: null
- test_file: null       # path to test file once written

## Interface

```typescript
// Replace with actual interface for this construct's language/type
class ConstructName {
  methodName(param: Type): ReturnType
}
```

## Dependencies

- Calls: (none)
- Called by: (none)
- Reads: (none)
- Writes: (none)

## Patterns Applied

- (none — link patterns.md entries here once established)

## Key Decisions

- (none — link ADRs here once written)

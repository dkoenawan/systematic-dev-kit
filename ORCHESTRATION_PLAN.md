# Feature Orchestration System Plan

## Problem Statement

We need a robust orchestration system to decompose feature requests into coordinated backend + frontend + database changes. When a user requests "Add user profile feature," the system should systematically:

1. Parse requirements
2. Design database schema
3. Generate backend entities
4. Generate use cases (CQRS)
5. Update OpenAPI specification
6. Generate frontend components
7. Wire frontend to API
8. Validate integration
9. Run tests
10. Iterate based on evaluation feedback

## Requirements

- **Systematic workflow execution** with clear steps
- **Evaluator-optimizer loops** for quality assurance
- **Stateful execution** (ability to pause/resume)
- **User oversight** at critical decision points
- **Minimal external dependencies** (leverage existing Claude Code infrastructure)

## Architectural Options Considered

### Option 1: Claude Code Skills Only
**Architecture:** Single Claude session processes entire request using tools (Read, Edit, Write, Bash)

**Pros:**
- Simple, no external dependencies
- User maintains conversational control
- Already integrated with plugin system

**Cons:**
- No structured workflow state management
- Hard to pause/resume complex workflows
- No built-in evaluation loops
- Context window limitations for large features

### Option 2: LangGraph Orchestration
**Architecture:** External LangGraph service manages stateful workflow, Claude Code invokes via API

**Pros:**
- Stateful workflow with persistence
- Built-in checkpointing (pause/resume)
- Structured evaluation loops
- Can run autonomously

**Cons:**
- Adds Python dependency
- Requires deploying/running LangGraph service
- User loses direct conversational control during workflow
- More infrastructure complexity

### Option 3: Nested Claude Code Agents (Recommended)
**Architecture:** Main Claude session coordinates specialized agents spawned via Task tool

**Pros:**
- No external dependencies
- Uses existing Claude Code infrastructure
- User can interrupt/guide at any step
- Natural evaluation loop (main session reviews each agent output)
- Specialized agents have focused context + tools

**Cons:**
- Each agent is stateless (no persistence between invocations)
- Cost scales with agent count
- Limited parallelization

### Option 4: Hybrid with Templating Engine
**Architecture:** Claude + code generation templates (Plop.js, Hygen)

**Pros:**
- Fast, deterministic code generation
- Low cost (minimal LLM usage)
- Easy to version control templates

**Cons:**
- Less flexible than LLM-based approach
- Templates become maintenance burden
- Hard to handle edge cases

## Recommended Solution: Workflow-Driven Agent Orchestration

**Approach:** Option 3 (Nested Claude Code Agents) + Structured Workflow Definitions

### Core Components

#### 1. Workflow Definition Format

Create declarative workflow specifications in YAML:

```yaml
# skills/add-feature/workflow.yaml
name: add-feature
description: Systematically implement a new feature across database, backend, and frontend

steps:
  - id: parse-requirements
    description: Extract feature requirements from user input
    agent: general-purpose
    tools: [AskUserQuestion, Read, Grep]
    outputs:
      - feature-spec.json
    success_criteria:
      - User stories defined
      - Acceptance criteria clear
      - Data model sketched

  - id: design-schema
    description: Design database schema for the feature
    agent: database-designer
    inputs:
      - feature-spec.json
    outputs:
      - migration.sql
      - schema-diagram.md
    validation:
      - Schema is normalized (3NF minimum)
      - Proper indexes defined
      - Foreign key constraints present
      - Follows naming conventions

  - id: generate-backend-entities
    description: Generate domain entities and value objects
    agent: backend-generator
    inputs:
      - feature-spec.json
      - migration.sql
    outputs:
      - src/domain/entities/*.ts
      - src/domain/value-objects/*.ts
      - src/domain/repositories/*Repository.ts
    validation:
      - Entities follow clean architecture
      - Proper TypeScript types
      - No business logic in entities (anemic domain)
      - Repository interfaces defined

  - id: generate-usecases
    description: Generate CQRS command and query handlers
    agent: backend-generator
    inputs:
      - feature-spec.json
      - domain entities
    outputs:
      - src/usecases/commands/*.ts
      - src/usecases/queries/*.ts
    validation:
      - Commands have validation logic
      - Queries are read-only
      - Error handling present
      - Follow single responsibility principle

  - id: generate-controllers
    description: Generate HTTP controllers and routes
    agent: backend-generator
    inputs:
      - feature-spec.json
      - usecases
    outputs:
      - src/interface/http/controllers/*.ts
      - src/interface/http/routes/*.ts
    validation:
      - Proper HTTP status codes
      - Input validation using Zod
      - Error middleware integration
      - Route naming follows REST conventions

  - id: update-openapi
    description: Update OpenAPI specification with new endpoints
    agent: api-spec-designer
    inputs:
      - feature-spec.json
      - controllers
      - entities (for schema definitions)
    outputs:
      - openapi.yaml (updated)
    validation:
      - All endpoints documented
      - Request/response schemas defined
      - Examples provided
      - Follows existing API conventions

  - id: generate-frontend-types
    description: Generate TypeScript types from OpenAPI spec
    agent: frontend-generator
    inputs:
      - openapi.yaml
    outputs:
      - frontend/src/types/api/*.ts
    validation:
      - Types match OpenAPI schemas
      - Proper imports structure
      - No 'any' types

  - id: generate-frontend-components
    description: Generate React components following atomic design
    agent: frontend-generator
    inputs:
      - feature-spec.json
      - frontend types
    outputs:
      - frontend/src/components/organisms/*
      - frontend/src/components/molecules/*
      - frontend/src/components/atoms/*
      - frontend/src/components/pages/*
    validation:
      - Uses MUI components
      - Proper TypeScript types
      - Accessibility attributes present
      - Responsive design

  - id: generate-api-integration
    description: Generate API client hooks for frontend
    agent: frontend-generator
    inputs:
      - openapi.yaml
      - frontend types
    outputs:
      - frontend/src/api/*.ts
      - frontend/src/hooks/use*.ts
    validation:
      - Uses proper HTTP client
      - Error handling present
      - Loading states managed
      - Type-safe API calls

  - id: integrate-and-validate
    description: Validate integration between frontend and backend
    agent: integration-validator
    inputs:
      - All previous outputs
    validation:
      - Frontend calls correct endpoints
      - Request/response types match
      - Error handling works end-to-end
      - No console errors
      - API documentation accessible
    actions:
      - Start backend server
      - Start frontend dev server
      - Run integration tests
      - Check API docs at /api-docs

  - id: evaluate-and-optimize
    description: Run evaluator-optimizer loop for quality assurance
    agent: general-purpose
    inputs:
      - All generated code
      - Test results
      - Integration validation results
    evaluation_criteria:
      - Code quality score > 80%
      - All tests passing
      - No TypeScript errors
      - No linting errors
      - Performance benchmarks met
    optimization_actions:
      - Refactor code based on evaluation
      - Fix failing tests
      - Improve error handling
      - Add missing validations
    max_iterations: 3
```

#### 2. Orchestrator Skill

Create `/systematic-dev-kit:orchestrate-feature` skill:

**Location:** `skills/orchestrate-feature/SKILL.md`

**Responsibilities:**
- Load and parse workflow YAML
- Execute steps sequentially
- Spawn specialized agents via Task tool
- Maintain state in scratchpad directory
- Implement evaluator-optimizer loops
- Provide progress updates to user
- Allow user approval at critical checkpoints

**State Management:**
```
/tmp/claude/<session>/scratchpad/workflow-state/
├── current-step.json          # Current step index and status
├── feature-spec.json          # Parsed requirements
├── outputs/                   # Outputs from each step
│   ├── step-1-parse-requirements/
│   ├── step-2-design-schema/
│   └── ...
├── evaluation-results/        # Evaluation scores and feedback
└── workflow-log.jsonl         # Audit log of all actions
```

**Execution Flow:**
```
1. User invokes: /systematic-dev-kit:orchestrate-feature
2. Ask user for feature description
3. Load workflow definition (workflow.yaml)
4. Initialize state in scratchpad
5. For each step in workflow:
   a. Check if step already completed (resume capability)
   b. Prepare inputs from previous step outputs
   c. Spawn specialized agent with:
      - Step description
      - Input artifacts
      - Success criteria
      - Validation rules
   d. Wait for agent completion
   e. Evaluate agent output against validation rules
   f. If validation fails:
      - Log issues
      - Retry with feedback (up to max_iterations)
   g. Save outputs to scratchpad
   h. Update workflow state
   i. Show progress to user
6. Run final integration validation
7. Execute evaluator-optimizer loop
8. Present summary to user
```

#### 3. Specialized Agents

Create new agent types via Claude Code's Task tool:

**database-designer**
- Tools: Read, Write, Bash (for running migrations), Grep
- Context: Database schema conventions, normalization rules
- Outputs: SQL migrations, schema diagrams

**backend-generator**
- Tools: Read, Write, Edit, Grep, Glob
- Context: Clean architecture patterns, CQRS, TypeScript best practices
- Outputs: Entities, use cases, controllers, repositories

**api-spec-designer**
- Tools: Read, Write, Edit
- Context: OpenAPI 3.0 specification, REST conventions
- Outputs: Updated openapi.yaml

**frontend-generator**
- Tools: Read, Write, Edit, Glob
- Context: Atomic design, MUI component library, React best practices
- Outputs: Components, hooks, API clients

**integration-validator**
- Tools: Read, Bash (to start servers, run tests), Grep
- Context: Testing strategies, debugging techniques
- Outputs: Validation report, test results

#### 4. Evaluator-Optimizer Loop

Implement at two levels:

**Step-Level Evaluation:**
```yaml
validation:
  - criterion: "Schema is normalized"
    check_method: "grep for duplicate columns"
    threshold: 0 duplicates
  - criterion: "Proper indexes defined"
    check_method: "parse SQL for CREATE INDEX"
    threshold: >= 1 index per foreign key
```

**Feature-Level Evaluation:**
```yaml
evaluation_criteria:
  - name: "Code Quality"
    metrics:
      - TypeScript errors: 0
      - ESLint errors: 0
      - Cyclomatic complexity: < 10
    weight: 0.3

  - name: "Test Coverage"
    metrics:
      - Unit tests passing: 100%
      - Integration tests passing: 100%
      - Coverage: > 80%
    weight: 0.3

  - name: "Architecture Compliance"
    metrics:
      - Clean architecture violations: 0
      - CQRS pattern violations: 0
      - Circular dependencies: 0
    weight: 0.2

  - name: "API Quality"
    metrics:
      - OpenAPI validation: pass
      - Endpoint documentation: 100%
      - Type safety: 100%
    weight: 0.2

optimization_strategy:
  - if: "score < 0.6"
    action: "Major refactoring needed, restart from step 3"
  - if: "score >= 0.6 and score < 0.8"
    action: "Targeted improvements, iterate on failing criteria"
  - if: "score >= 0.8"
    action: "Minor polish, ready for user review"

max_iterations: 3
```

## Implementation Plan

### Phase 1: Core Infrastructure (Week 1)
1. Create workflow definition schema (YAML)
2. Implement workflow parser and validator
3. Create orchestrator skill skeleton
4. Implement state management in scratchpad
5. Add workflow resume capability

### Phase 2: Agent Specialization (Week 2)
1. Define agent prompts and contexts
2. Create database-designer agent
3. Create backend-generator agent
4. Create api-spec-designer agent
5. Create frontend-generator agent
6. Create integration-validator agent

### Phase 3: Evaluation System (Week 3)
1. Implement step-level validation checks
2. Implement feature-level evaluation metrics
3. Create evaluation score calculator
4. Implement optimizer decision logic
5. Add retry mechanism with feedback

### Phase 4: User Experience (Week 4)
1. Add progress indicators
2. Implement user approval checkpoints
3. Create workflow visualization
4. Add error recovery mechanisms
5. Write comprehensive documentation

### Phase 5: Testing & Refinement (Week 5)
1. Test with simple feature (e.g., "Add contact form")
2. Test with medium feature (e.g., "Add user authentication")
3. Test with complex feature (e.g., "Add multi-tenant support")
4. Gather feedback and iterate
5. Create example workflows for common patterns

## Success Criteria

### Must Have
- [ ] User can invoke orchestration with natural language feature request
- [ ] System generates database schema, backend code, and frontend code
- [ ] All generated code follows systematic-dev-kit conventions
- [ ] OpenAPI spec is automatically updated
- [ ] Integration validation runs successfully
- [ ] User can pause and resume workflows
- [ ] Evaluation loop identifies and fixes common issues

### Should Have
- [ ] Workflow execution time < 10 minutes for simple features
- [ ] User approval required at critical steps (schema design, API design)
- [ ] Generated code has >80% test coverage
- [ ] Clear error messages when validation fails
- [ ] Workflow state is human-readable (JSON/YAML)

### Nice to Have
- [ ] Parallel execution of independent steps
- [ ] Workflow templates for common feature patterns
- [ ] AI-powered workflow optimization suggestions
- [ ] Integration with existing git workflow
- [ ] Automatic PR creation with changes

## Future Enhancements

### Advanced Orchestration
- Workflow branching (different paths based on conditions)
- Sub-workflows (reusable workflow fragments)
- Workflow versioning and migration
- Workflow marketplace (community-contributed workflows)

### Enhanced Evaluation
- ML-based code quality prediction
- Performance benchmarking integration
- Security vulnerability scanning
- Accessibility compliance checking

### Developer Experience
- VS Code extension for workflow visualization
- Interactive workflow debugger
- Workflow dry-run mode (preview without execution)
- Cost estimation before execution

### Enterprise Features
- Multi-project workflows
- Team collaboration (workflow sharing)
- Audit logging and compliance
- Custom evaluation criteria per organization

## Open Questions

1. **Persistence Strategy:** Should workflow state survive Claude Code session restarts? If yes, how?
   - Option A: File-based state in project directory
   - Option B: SQLite database in scratchpad
   - Option C: External state service (Redis/PostgreSQL)

2. **Error Recovery:** How should system handle agent failures?
   - Option A: Auto-retry with same inputs
   - Option B: Ask user for guidance
   - Option C: Rollback to previous checkpoint

3. **Customization:** Should users be able to override workflow steps?
   - Option A: Allow per-invocation overrides (CLI flags)
   - Option B: Support custom workflow files in project
   - Option C: Both

4. **Cost Management:** How to control Claude API costs for large workflows?
   - Option A: Set max token budget per workflow
   - Option B: Use cheaper models for validation steps
   - Option C: Cache intermediate results

5. **Integration Testing:** Should orchestrator start local servers for validation?
   - Option A: Yes, fully automated
   - Option B: No, assume user has dev environment running
   - Option C: Make it configurable

## Next Steps

1. **Review this plan** and provide feedback
2. **Answer open questions** based on your preferences
3. **Prioritize features** (which should we build first?)
4. **Choose a pilot feature** to test the orchestration system
5. **Begin implementation** starting with Phase 1

---

**Document Version:** 1.0
**Last Updated:** 2026-01-22
**Author:** Claude Code
**Status:** Awaiting Review

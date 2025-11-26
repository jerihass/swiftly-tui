<!--
Sync Impact Report
Version: 1.0.0 → 1.0.0 (no governance change)
Modified Principles: None
Added Sections: None
Removed Sections: None
Templates: ✅ .specify/templates/plan-template.md | ✅ .specify/templates/tasks-template.md
Follow-up TODOs: None
-->
# swiftly Constitution

## Core Principles

### TDD-First Delivery (Non-Negotiable)
All new work starts with executable tests that fail before implementation; follow red-green-refactor with fast unit coverage and CLI-level integration tests for command behaviors; platform-parity test suites (macOS + Linux) must pass before merge; regressions require a reproducing test before fixes are accepted. Rationale: Tests define the contract, keep CLI behavior stable, and protect multi-platform support.

### Composable CLI Modules
Features are built as reusable Swift modules with narrow, well-documented CLI surfaces; commands orchestrate domain services without embedding domain logic; dependencies remain minimal and injected to allow swapping implementations for tests or platforms. Rationale: Composability keeps the tool maintainable, testable, and ready for future UIs.

### Clean Architecture Boundaries
Domain rules stay pure and deterministic; IO (filesystem, network, process execution) is wrapped behind protocols and injected adapters; no direct coupling between argument parsing and infrastructure concerns; side effects are explicit and contained. Rationale: Clear boundaries make the code safer to change and easier to reason about.

### Platform Parity & Safety
Every feature must behave consistently on macOS and Linux; filesystem and process operations are idempotent when feasible, guarded with confirmations for destructive actions, and validate signatures/checksums before installing toolchains; failures must leave the system in a recoverable state with actionable messages. Rationale: Users trust swiftly to manage toolchains without harming their machines.

### Release Integrity & Compatibility
CLI contracts (flags, subcommands, outputs) are treated as public APIs; breaking changes require explicit migration notes and semantic versioning; downloads, updates, and uninstalls must log clear steps to stdout/stderr with structured error details; default paths and configs preserve user data unless migration is explicit. Rationale: Stable contracts and transparent operations keep upgrades safe.

## Technology & Quality Constraints

- Language/tooling: Swift 6 toolchain with swift-argument-parser and documented package dependencies; prefer standard library or project-approved libraries before adding new ones.
- Outputs: All commands write user-facing messages to stdout and errors to stderr; logs must be human-readable with enough context to debug failures offline.
- Security & integrity: Network and filesystem actions validate signatures or checksums where provided; never execute fetched artifacts without verification; respect user home directory boundaries.
- Documentation: Update inline help and user docs alongside behavior changes; include examples that match actual CLI outputs.

## Workflow & Quality Gates

- TDD workflow: Add or update failing tests (unit + CLI/integration) before code changes; no merges without green CI on supported platforms.
- Design upfront: New features require a spec and plan that map user stories to tests and modules, honoring the architecture boundaries and composability goals.
- Reviews: Code review checks alignment with all principles, especially boundary purity, platform parity, and CLI contract stability; reject hidden coupling to OS specifics.
- Release readiness: Any change affecting CLI surface or toolchain management ships with migration notes and, when breaking, a coordinated version bump and rollback plan.

## Governance

This constitution supersedes prior process notes. Amendments require a documented proposal in a PR describing the rationale, version bump, migration/communication needs, and updates to affected templates. Constitution versions follow semantic versioning: PATCH for clarifications, MINOR for new guidance or sections, MAJOR for breaking/removing principles. Compliance is reviewed during plan/spec creation (Constitution Check) and in PR reviews; non-compliance blocks merges until resolved or explicitly waived with recorded justification.

**Version**: 1.0.0 | **Ratified**: 2025-11-25 | **Last Amended**: 2025-11-25

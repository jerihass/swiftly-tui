---

description: "Task list for TUI Interface for Core Functions"
---

# Tasks: TUI Interface for Core Functions

**Input**: Design documents from `/specs/001-tui-core-interaction/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are REQUIRED. Add failing tests before implementation for every user story (unit + CLI/integration as appropriate).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Sources in `Sources/Swiftly` (CLI/TUI), `Sources/SwiftlyCore` (domain/services), platform adapters in `Sources/MacOSPlatform` and `Sources/LinuxPlatform`.
- Tests in `Tests/SwiftlyTests`.
- Feature docs in `specs/001-tui-core-interaction/`.

---

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Add SwifTeaUI dependency (branch `main`) to Package.swift and resolve package graph.
- [x] T002 Create TUI module directories and placeholder entry files in Sources/Swiftly/TUI/ (RootMenuView.swift, Components/, Controllers/, Adapters/).
- [x] T003 Add TUI test harness scaffolding file in Tests/SwiftlyTests/TUITests/TUITestHarness.swift for rendering and keystroke simulation.

---

## Phase 2: Foundational (Blocking Prerequisites)

- [x] T004 Stub `tui` command entry and wiring in Sources/Swiftly/Commands/TUICommand.swift to launch TUI host.
- [x] T005 Implement service adapter bridging SwiftlyCore operations for list/switch/install/uninstall/update in Sources/Swiftly/TUI/Adapters/CoreActionsAdapter.swift.
- [x] T006 Add shared progress/event model for TUI in Sources/Swiftly/TUI/Models/OperationState.swift and mirror in Tests fixtures.

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel.

---

## Phase 3: User Story 1 - Guided Core Actions via TUI (Priority: P1) 🎯 MVP

**Goal**: Guided keyboard-only flow to run core actions (list, switch, install, uninstall, update) with progress and summaries.

**Independent Test**: Launch TUI, perform a switch or install using only TUI navigation, and verify completion plus success message.

### Tests for User Story 1 (MANDATORY - add before implementation) ⚠️

- [ ] T007 [P] [US1] Add integration test for core action flows (switch/install/uninstall/update) in Tests/SwiftlyTests/TUITests/CoreActionsFlowTests.swift.
- [ ] T008 [P] [US1] Add unit tests for menu navigation and shortcuts in Tests/SwiftlyTests/TUITests/MenuNavigationTests.swift.

### Implementation for User Story 1

- [ ] T009 [US1] Implement root menu view and keyboard navigation in Sources/Swiftly/TUI/RootMenuView.swift using SwifTeaUI.
- [ ] T010 [US1] Implement core actions controller wiring selections to CoreActionsAdapter with confirmations in Sources/Swiftly/TUI/Controllers/CoreActionsController.swift.
- [ ] T011 [US1] Implement progress and completion summaries for long operations in Sources/Swiftly/TUI/Components/ProgressView.swift.
- [ ] T012 [US1] Finalize `tui` command to start the TUI loop and exit handling in Sources/Swiftly/Commands/TUICommand.swift.

**Checkpoint**: User Story 1 independently testable (switch/install/uninstall/update via TUI).

---

## Phase 4: User Story 2 - Inspect Toolchain States (Priority: P2)

**Goal**: Display installed, active, and available toolchains with details before actions.

**Independent Test**: Launch TUI with multiple toolchains; list shows status and details without performing actions.

### Tests for User Story 2 (MANDATORY - add before implementation) ⚠️

- [ ] T013 [P] [US2] Add listing view tests covering active/installed/available states in Tests/SwiftlyTests/TUITests/ListingViewTests.swift.
- [ ] T014 [P] [US2] Add detail view tests showing location, size, and last operation in Tests/SwiftlyTests/TUITests/DetailViewTests.swift.

### Implementation for User Story 2

- [ ] T015 [US2] Implement toolchain list view with status badges and channels in Sources/Swiftly/TUI/Views/ToolchainListView.swift.
- [ ] T016 [US2] Implement detail view showing metadata (location, size, last result) in Sources/Swiftly/TUI/Views/ToolchainDetailView.swift.
- [ ] T017 [US2] Add layout adapter for sorting/filtering and small terminal handling in Sources/Swiftly/TUI/Views/ListLayoutAdapter.swift.

**Checkpoint**: User Story 2 independently testable (inspect states without actions).

---

## Phase 5: User Story 3 - Recover Gracefully from Errors (Priority: P3)

**Goal**: Handle failures (network, invalid identifiers, permissions) with clear messages and retry/cancel options.

**Independent Test**: Simulate offline install; TUI shows reason and offers retry/cancel without exiting.

### Tests for User Story 3 (MANDATORY - add before implementation) ⚠️

- [ ] T018 [P] [US3] Add error-handling tests (offline, invalid toolchain id, permission errors) in Tests/SwiftlyTests/TUITests/ErrorRecoveryTests.swift.
- [ ] T019 [P] [US3] Add cancellation/resume tests for in-progress operations in Tests/SwiftlyTests/TUITests/RecoveryFlowTests.swift.

### Implementation for User Story 3

- [ ] T020 [US3] Implement error view with retry/cancel flows and messaging in Sources/Swiftly/TUI/Views/ErrorView.swift.
- [ ] T021 [US3] Implement validation adapter suggesting valid toolchains on bad input in Sources/Swiftly/TUI/Adapters/ValidationAdapter.swift.
- [ ] T022 [US3] Implement recovery controller to handle cancel/resume of operations in Sources/Swiftly/TUI/Controllers/OperationRecoveryController.swift.

**Checkpoint**: User Story 3 independently testable (recoverable failures).

---

## Phase N: Polish & Cross-Cutting Concerns

- [ ] T023 Update TUI command help and README snippet to include usage and keyboard controls in Sources/Swiftly/Commands/TUICommand.swift and README.md.
- [ ] T024 Update quickstart with TUI flows and troubleshooting in specs/001-tui-core-interaction/quickstart.md.
- [ ] T025 [P] Add small-terminal layout regression test in Tests/SwiftlyTests/TUITests/LayoutConstraintsTests.swift.
- [ ] T026 [P] Refine accessibility cues (focus indicators, error messaging clarity) in Sources/Swiftly/TUI/Components/AccessibilityStyles.swift.
- [ ] T027 [P] Capture any missing SwifTeaUI component needs in specs/001-tui-core-interaction/research.md (SwifTeaUI gaps section) during implementation.
- [ ] T028 Add timing assertions for action summaries (<2s) and keystroke counts in Tests/SwiftlyTests/TUITests/PerformanceTests.swift.
- [ ] T029 Add cross-platform test execution steps for macOS and Linux in README.md and CI workflow (.github/workflows/ci.yml) to enforce parity for TUI tests.
- [ ] T030 [P] Add error-handling tests for disk space exhaustion and corrupted metadata in Tests/SwiftlyTests/TUITests/ErrorRecoveryTests.swift.
- [ ] T031 [P] Add output channel validation ensuring stdout/stderr separation and structured error messages in Tests/SwiftlyTests/TUITests/OutputChannelTests.swift and adjust messaging in Sources/Swiftly/TUI/Adapters/OutputAdapter.swift.

---

## Dependencies & Execution Order

- Setup (Phase 1) → Foundational (Phase 2) → US1 (Phase 3) → US2 (Phase 4) → US3 (Phase 5) → Polish.
- User stories are independent once foundational tasks are done; US1 delivers MVP.

## Parallel Example: User Story 1

```bash
# Run tests in parallel
Task: "Add integration test for core action flows" (Tests/SwiftlyTests/TUITests/CoreActionsFlowTests.swift)
Task: "Add unit tests for menu navigation and shortcuts" (Tests/SwiftlyTests/TUITests/MenuNavigationTests.swift)
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Setup + Foundational
2. Implement and test US1 end-to-end
3. Validate TUI core actions and release as MVP

### Incremental Delivery

1. Add US2 (inspect states) → test independently
2. Add US3 (error recovery) → test independently
3. Apply Polish tasks

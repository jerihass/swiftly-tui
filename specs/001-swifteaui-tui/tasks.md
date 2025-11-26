# Tasks: SwifTeaUI-Driven TUI Flows

**Input**: Design documents from `/specs/001-swifteaui-tui/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are REQUIRED. Add failing tests before implementation for every user story (unit + CLI/integration as appropriate).

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and base tooling for SwifTeaUI-driven TUI work

- [X] T001 Ensure SwifTeaUI dependency is pinned to branch `main` in Package.swift
- [X] T002 Configure TUI test target for headless scene tests in Tests/TUITests (XCTest manifest, any needed test helpers)
- [X] T003 [P] Add basic SwifTeaUI preview/headless harness utilities in Tests/TUITests/Support/
- [X] T004 [P] Verify TUI command entry wiring remains thin and calls TUIApplication in Sources/Swiftly/CLI/Commands/TUICommand.swift

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core adapters/state shared across all user stories

- [X] T005 Create shared TUI state models (ToolchainViewModel, OperationSessionViewModel) in Sources/Swiftly/TUI/Models/
- [X] T006 [P] Implement CoreActionsAdapter against SwiftlyCore list/switch/install/update/remove in Sources/Swiftly/TUI/Adapters/CoreActionsAdapter.swift with error surfaces/log paths
- [X] T007 [P] Add SwifTeaUI navigation/store scaffolding (root scene + reducer wiring) in Sources/Swiftly/TUI/TUIApplication.swift
- [X] T008 Establish deterministic fixtures/mocks for toolchains and failures in Tests/TUITests/Fixtures/
- [X] T009 Add logging/output adapter to channel stdout/stderr per constitution in Sources/Swiftly/TUI/Adapters/OutputAdapter.swift

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Navigate and Switch Toolchains (Priority: P1) 🎯 MVP

**Goal**: Keyboard-driven list/detail navigation and switching with confirmation and success feedback

**Independent Test**: Launch TUI, navigate to a toolchain, view details, switch, and see success summary without touching other stories.

### Tests for User Story 1 (MANDATORY - add before implementation) ⚠️

- [X] T010 [P] [US1] Scene unit tests for list rendering and selection in Tests/TUITests/ListingViewTests.swift
- [X] T011 [P] [US1] Integration test for list → detail → switch flow in Tests/TUITests/CoreActionsFlowTests.swift
- [X] T012 [P] [US1] Keyboard navigation tests (numbers/arrows/enter/q) in Tests/TUITests/MenuNavigationTests.swift
- [X] T013 [P] [US1] Empty-state rendering and guidance test in Tests/TUITests/ListingViewTests.swift
- [X] T014 [P] [US1] Headless navigation timing test (<60s path to switch) in Tests/TUITests/PerformanceTests.swift

### Implementation for User Story 1

- [X] T015 [P] [US1] Build SwifTeaUI list scene (menu + toolchain list) in Sources/Swiftly/TUI/Views/ToolchainListView.swift
- [X] T016 [P] [US1] Build detail scene with active indicator and actions in Sources/Swiftly/TUI/Views/ToolchainDetailView.swift
- [X] T017 [US1] Implement switch action with confirmation and success summary in Sources/Swiftly/TUI/Controllers/CoreActionsController.swift
- [X] T018 [US1] Wire keyboard navigation (numbers/arrows/enter/q) in Sources/Swiftly/TUI/TUIApplication.swift
- [X] T019 [US1] Update quickstart with US1 verification steps in specs/001-swifteaui-tui/quickstart.md
- [X] T020 [US1] Add empty-state handling/guidance in Sources/Swiftly/TUI/Views/ToolchainListView.swift

**Checkpoint**: User Story 1 independently testable (list, detail, switch).

---

## Phase 4: User Story 2 - Guided Install/Update/Remove (Priority: P2)

**Goal**: Guided flows with prompts, progress updates, and completion summaries for install/update/remove.

**Independent Test**: Trigger install/update/remove, provide input/confirmation, see progress ticks and final status without relying on US3.

### Tests for User Story 2 (MANDATORY - add before implementation) ⚠️

- [X] T021 [P] [US2] Install flow progress and completion tests in Tests/TUITests/InstallFlowTests.swift
- [X] T022 [P] [US2] Update flow confirmation and summary tests in Tests/TUITests/UpdateFlowTests.swift
- [X] T023 [P] [US2] Remove flow guard (active toolchain) and confirmation tests in Tests/TUITests/RemoveFlowTests.swift
- [X] T024 [P] [US2] Invalid identifier (empty input) validation and messaging tests in Tests/TUITests/InstallFlowTests.swift

### Implementation for User Story 2

- [X] T025 [P] [US2] Implement install scene (default latest-stable + identifier input) with progress updates in Sources/Swiftly/TUI/Views/InstallView.swift
- [X] T026 [US2] Implement update scene with pre-change summary and progress in Sources/Swiftly/TUI/Views/UpdateView.swift
- [X] T027 [US2] Implement remove scene with active-check guard and confirmation in Sources/Swiftly/TUI/Views/RemoveView.swift
- [X] T028 [US2] Hook install/update/remove actions to CoreActionsAdapter with progress tick updates in Sources/Swiftly/TUI/Controllers/CoreActionsController.swift
- [X] T029 [P] [US2] Add contract assertions against tui-actions.yaml for install/update/remove in Tests/TUITests/Contract/TUIActionsContractTests.swift
- [X] T030 [US2] Add identifier validation and user feedback for invalid inputs in Sources/Swiftly/TUI/Views/InstallView.swift

**Checkpoint**: User Story 2 independently testable (install/update/remove with progress and summaries).

---

## Phase 5: User Story 3 - Error Visibility and Recovery (Priority: P3)

**Goal**: Actionable error views with retry/cancel and stable state recovery for failures/interrupts.

**Independent Test**: Simulate failures, surface error view with cause/log path, choose retry or cancel, and return to stable menu without crash.

### Tests for User Story 3 (MANDATORY - add before implementation) ⚠️

- [X] T031 [P] [US3] Error view rendering and choices tests in Tests/TUITests/ErrorViewTests.swift
- [X] T032 [P] [US3] Recovery flow tests for interrupted install/update/remove in Tests/TUITests/RecoveryFlowTests.swift
- [X] T033 [P] [US3] Log path surfacing and retry/cancel branching tests in Tests/TUITests/OutputChannelTests.swift

### Implementation for User Story 3

- [X] T034 [P] [US3] Build SwifTeaUI error view with retry/cancel and log path display in Sources/Swiftly/TUI/Views/ErrorView.swift
- [ ] T035 [US3] Add recovery controller to resume/abort operations and restore menu state in Sources/Swiftly/TUI/Controllers/OperationRecoveryController.swift
- [X] T036 [US3] Wire error routing from all actions to error view + recovery in Sources/Swiftly/TUI/TUIApplication.swift
- [ ] T037 [US3] Ensure interrupted operations detect and handle pending state on next launch in Sources/Swiftly/TUI/Adapters/CoreActionsAdapter.swift

**Checkpoint**: User Story 3 independently testable (errors surfaced, retry/cancel stable, no crashes).

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Hardening, docs, and cross-story validation

- [ ] T038 [P] Add accessibility and keyboard focus cues to components in Sources/Swiftly/TUI/Views/AccessibilityStyles.swift
- [ ] T039 [P] Add layout/list density adjustments and empty-state styling in Sources/Swiftly/TUI/Views/ListLayoutAdapter.swift
- [ ] T040 Validate progress update cadence (≤5s) across flows with timer-based tests in Tests/TUITests/PerformanceTests.swift
- [ ] T041 Update README TUI section with component-driven flows and usage in README.md
- [ ] T042 Final cross-platform CI validation (macOS + Linux) via `swift test` and `swift run swiftly tui --assume-yes` smoke script in .github/workflows/pull_request.yml
- [ ] T043 [P] Document SwifTeaUI gaps (if any) and fallbacks per FR-009 in docs or specs/001-swifteaui-tui/research.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): No dependencies
- Foundational (Phase 2): Depends on Setup completion; BLOCKS all user stories
- User Stories (Phases 3–5): Depend on Foundational completion; proceed in priority order (P1 → P2 → P3) though can run in parallel if foundation + story independence maintained
- Polish (Final Phase): Depends on completion of targeted user stories

### User Story Dependencies

- User Story 1 (P1): Starts after Foundational; no dependency on other stories
- User Story 2 (P2): Starts after Foundational; may reuse US1 components but remains independently testable
- User Story 3 (P3): Starts after Foundational; depends on action hooks from US1/US2 but tests isolate error/recovery flows with fixtures

### Parallel Opportunities

- Setup: T003, T004 can run in parallel
- Foundational: T006, T007, T008, T009 can run in parallel once models (T005) exist
- US1 tests (T010–T014) can run in parallel; US1 views (T015–T016) in parallel
- US2 tests (T021–T024) can run in parallel; US2 views (T025–T027) in parallel
- US3 tests (T031–T033) can run in parallel; US3 error handling tasks (T034–T037) mostly sequential after error view exists
- Polish: T038, T039, T043 can run in parallel

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Validate US1 independently (tests in T010–T014)

### Incremental Delivery

1. Finish Setup + Foundational
2. Deliver US1 (MVP) → tests green → demo
3. Deliver US2 → tests green → demo
4. Deliver US3 → tests green → demo
5. Polish and cross-cutting hardening

### Notes

- [P] tasks = different files, no dependencies
- Each user story should be independently testable in headless mode
- Write tests first per constitution; keep CLI contract stable
- Avoid cross-story coupling; keep adapters/controllers thin and reusable

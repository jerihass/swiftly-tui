# Tasks: TUI Design and UX Improvements

**Input**: Design documents from `/specs/001-tui-ux/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Tests are REQUIRED. Add failing tests before implementation for every user story (unit + CLI/integration as appropriate) and run across macOS and Linux.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare UX-focused scaffolding and docs

- [X] T001 Verify SwifTeaUI dependency (branch `main`) and test target ready for UX snapshots in Package.swift
- [X] T002 Add/confirm UX guideline doc location placeholder in specs/001-tui-ux/quickstart.md and AGENTS.md references
- [X] T003 [P] Ensure TUITests harness supports 80-col rendering and headless scenes in Tests/TUITests/Support/

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared UX primitives used by all stories

- [X] T004 [P] Add shared keyboard hint sets and focus style helpers in Sources/Swiftly/TUI/Components/AccessibilityStyles.swift
- [X] T005 [P] Add density rules (row spacing/columns) and empty-state helpers in Sources/Swiftly/TUI/Views/ListLayoutAdapter.swift
- [X] T006 Add UX guide markdown skeleton in specs/001-tui-ux/research.md or specs/001-tui-ux/ux-guide.md with placeholders for patterns

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Consistent Navigation & Layout (Priority: P1) 🎯 MVP

**Goal**: Shared header/body/status layout with visible hints and persistent focus cues across all screens

**Independent Test**: Keyboard-only traversal of menu → list → detail → install/update/remove → error; layout and hints consistent without docs.

### Tests for User Story 1 (MANDATORY - add before implementation) ⚠️

- [ ] T007 [P] [US1] Snapshot/layout tests for menu/list/detail/header-body-status structure in Tests/TUITests/LayoutConsistencyTests.swift
- [ ] T008 [P] [US1] Keyboard hint visibility tests per screen in Tests/TUITests/HintVisibilityTests.swift
- [ ] T009 [P] [US1] Focus persistence tests across back/forward navigation in Tests/TUITests/FocusPersistenceTests.swift
- [ ] T009a [P] [US1] Main menu action coverage test (list/switch/install/uninstall/update labels & shortcuts) in Tests/TUITests/MenuActionsTests.swift

### Implementation for User Story 1

- [ ] T010 [P] [US1] Refactor TUIApplication views to use shared header/body/status wrapper with injected hints in Sources/Swiftly/TUI/TUIApplication.swift
- [ ] T011 [P] [US1] Apply focus markers to all selectable rows/inputs in Sources/Swiftly/TUI/Views (list/detail/input/error)
- [ ] T012 [US1] Add inline validation messaging retention for inputs/errors in Sources/Swiftly/TUI/Views/Input/Error views
- [ ] T013 [US1] Update StatusBar hints to match keyboard bindings across screens in Sources/Swiftly/TUI/TUIApplication.swift
- [ ] T013a [US1] Implement bordered/themed frame (or fallback) for menu/list/detail/input/error screens using SwifTeaUI; document gaps if components missing in Sources/Swiftly/TUI/Views

**Checkpoint**: User Story 1 independently testable (consistent layout/hints/focus)

---

## Phase 4: User Story 2 - Responsive & Readable Lists (Priority: P2)

**Goal**: Lists/tables remain readable at 80 cols, dense for long lists, with active/selected clarity and empty-state guidance.

**Independent Test**: Render list/detail at 80 cols with ≥20 toolchains; focused rows visible, identifiers/channel/status aligned; empty state guides install.

### Tests for User Story 2 (MANDATORY - add before implementation) ⚠️

- [ ] T014 [P] [US2] 80-col rendering tests with ≥20 toolchains in Tests/TUITests/ListDensityTests.swift
- [ ] T015 [P] [US2] Empty-state guidance test in Tests/TUITests/EmptyStateTests.swift
- [ ] T016 [P] [US2] Column alignment and truncation tests for long identifiers in Tests/TUITests/ColumnAlignmentTests.swift

### Implementation for User Story 2

- [ ] T017 [P] [US2] Implement density-driven row spacing/columns for list/detail in Sources/Swiftly/TUI/Views/ToolchainListView.swift
- [ ] T018 [US2] Ensure active/selected highlighting remains visible under compact spacing in Sources/Swiftly/TUI/Views/ToolchainListView.swift
- [ ] T019 [US2] Enhance empty-state messaging and layout in Sources/Swiftly/TUI/Views/ToolchainListView.swift

**Checkpoint**: User Story 2 independently testable (responsive/dense lists with clear focus and guidance)

---

## Phase 5: User Story 3 - Documented UX Patterns (Priority: P3)

**Goal**: UX guide for layouts, hints, focus, density, and error/progress patterns to keep future screens consistent.

**Independent Test**: UX guide published and referenced by tests/review; deviations are detectable via guide.

### Tests for User Story 3 (MANDATORY - add before implementation) ⚠️

- [ ] T020 [P] [US3] UX guide presence and content test in Tests/TUITests/UXGuideTests.swift (checks required sections)
- [ ] T021 [P] [US3] Hint-to-binding contract test ensures documented keys match actual mapKeyToAction in Sources/Swiftly/TUI/TUIApplication.swift
- [ ] T022 [P] [US3] Progress/error hint consistency test in Tests/TUITests/HintVisibilityTests.swift

### Implementation for User Story 3

- [ ] T023 [US3] Author UX guide (patterns, layouts, hints, focus, density, empty/error) in specs/001-tui-ux/ux-guide.md (or research.md if single doc)
- [ ] T024 [US3] Link UX guide in README and quickstart in README.md and specs/001-tui-ux/quickstart.md
- [ ] T025 [US3] Add reviewer checklist snippet referencing UX guide in AGENTS.md or CONTRIBUTING

**Checkpoint**: User Story 3 independently testable (guide exists, enforced by tests)

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency and CI coverage

- [ ] T026 [P] Add TUI snapshot/regression runner for macOS/Linux in .github/workflows/pull_request.yml
- [ ] T027 [P] Cross-platform smoke: run `swift run swiftly tui --assume-yes` headless check in CI script (guarded for non-interactive)
- [ ] T028 [P] Update changelog/README with UX changes in README.md
- [ ] T029 [P] Document any SwifTeaUI component gaps encountered in specs/001-tui-ux/research.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): No dependencies
- Foundational (Phase 2): Depends on Setup completion; BLOCKS all user stories
- User Stories (Phases 3–5): Depend on Foundational completion; proceed in priority order (P1 → P2 → P3) though can run in parallel if foundations done
- Polish (Final Phase): Depends on completion of targeted user stories

### User Story Dependencies

- User Story 1 (P1): Starts after Foundational; no dependency on other stories
- User Story 2 (P2): Starts after Foundational; leverages list layout from US1
- User Story 3 (P3): Starts after US1/US2 patterns are in place; tests reference bindings/layouts from earlier stories

### Within Each User Story

- Write tests first, ensure they fail, then implement layout/UX changes.
- Keep focus/hint mappings consistent with UX guide.
- Preserve platform parity (macOS/Linux headless).

### Parallel Opportunities

- Setup tasks T001–T003 can run in parallel.
- Foundational tasks T004–T006 can run in parallel.
- US1 tests T007–T009 can run in parallel; implementations T010–T013 mostly parallel except shared files—sequence to avoid conflicts.
- US2 tests T014–T016 parallel; implementations T017–T019 sequential in list view file.
- US3 tests T020–T022 parallel; implementations T023–T025 sequential for doc linkage.
- Polish tasks T026–T029 can run in parallel.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. Stop and validate: layout/hints/focus consistent across screens

### Incremental Delivery

1. Setup + Foundational → baseline UX helpers
2. US1 → consistent layout/hints/focus
3. US2 → responsive lists/density
4. US3 → UX guide/tests
5. Polish → CI + docs

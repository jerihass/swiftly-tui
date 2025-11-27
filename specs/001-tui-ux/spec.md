# Feature Specification: TUI Design and UX Improvements

**Feature Branch**: `001-tui-ux`  
**Created**: 2025-11-25  
**Status**: Draft  
**Input**: User description: "TUI design and UX improvements"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Consistent Navigation & Layout (Priority: P1)

TUI users want every screen (menu, list, detail, install/update/remove, errors) to share a predictable layout with clear focus cues and keyboard hints so navigation is effortless.

**Why this priority**: Inconsistent layouts and hints slow down users and increase errors; a unified pattern boosts discoverability and confidence.

**Independent Test**: Launch the TUI, traverse all screens via keyboard-only, and verify each shows the same header/body/status structure, focus highlight, and context-specific hints without consulting external docs.

**Acceptance Scenarios**:

1. **Given** the user navigates from menu → list → detail, **When** they move focus with arrows/j/k and back with `b`, **Then** focus highlights stay visible and the status bar shows updated hints on each screen.
2. **Given** the user opens install/update/remove inputs, **When** they submit valid or invalid identifiers, **Then** the screen preserves the shared layout and displays inline validation messages without losing focus.

---

### User Story 2 - Responsive & Readable Lists (Priority: P2)

Users on varied terminal sizes need toolchain lists and detail tables to stay readable, dense when necessary, and still highlight active/selected items without truncating critical info.

**Why this priority**: Long identifiers and narrow terminals otherwise hide context, leading to wrong selections and failed switches/installs.

**Independent Test**: Render the list/detail in 80-column and wider terminals, verify focused rows and columns remain readable and aligned, and that empty states guide users to install.

**Acceptance Scenarios**:

1. **Given** a terminal at 80 columns with 20 toolchains, **When** the list renders, **Then** rows use compact spacing, maintain focus markers, and show identifier + channel + status without overlap.
2. **Given** no toolchains are installed, **When** the user opens the list, **Then** the empty-state message clearly instructs how to install and the layout remains aligned.

---

### User Story 3 - Documented UX Patterns (Priority: P3)

Contributors need a concise TUI UX guideline (patterns, shortcuts, layout rules) so future changes stay consistent without rediscovering decisions.

**Why this priority**: Shared patterns prevent regressions and reduce review time when adding new flows or screens.

**Independent Test**: Open the documented UX guide/section and verify it lists required layout structure, keyboard conventions, accessibility cues, and progress/error expectations referenced by tasks/tests.

**Acceptance Scenarios**:

1. **Given** a new contributor reads the UX guide, **When** they add a screen, **Then** they can follow documented layout blocks (header/body/status), hint formatting, and focus rules without asking for clarification.
2. **Given** a reviewer checks a PR touching TUI UI, **When** they compare against the UX guide, **Then** deviations are obvious and can be corrected before merge.

---

### Edge Cases

- Terminal width <80 columns: layouts must degrade to compact spacing without truncating active status or identifier.
- Very long toolchain identifiers: wrap/clip without losing which row is focused.
- Empty lists: show actionable guidance (install prompt) with intact keyboard hints.
- Error/retry screens: still show hints and log path without crowding status bar.
- Mixed navigation (numbers + arrows + vim keys): focus state remains correct after switching input methods.
- SwifTeaUI border/theme component missing: document the gap, apply minimal fallback frame without breaking readability.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every TUI screen (menu, list, detail, install, update, remove, error/result) MUST use a consistent header/body/status layout with context-specific keyboard hints visible at all times.
- **FR-002**: Focus cues MUST be visible for all selectable rows and inputs, persisting through navigation/back transitions and supporting arrows, j/k, number jumps, and Enter/Space activation.
- **FR-003**: Lists/tables MUST adapt density for ≥20 rows and render correctly at 80-column terminals while showing identifier, channel, and active status without overlap; empty states MUST include install guidance.
- **FR-004**: Input/error screens MUST show inline validation or failure messages without losing focus, including invalid identifiers and retries, while preserving the shared layout.
- **FR-005**: A TUI UX guideline MUST be published alongside the feature, documenting layout blocks, keyboard conventions, focus/empty/error patterns, and progress/hint expectations for future contributors.
- **FR-006**: The main menu MUST surface all core actions (list, switch, install, uninstall/remove, update) with clear labels and shortcuts, keeping parity with CLI capabilities.
- **FR-007**: Screens SHOULD use a bordered or themed frame when available in SwifTeaUI to improve readability; if components are missing, document the gap for the SwifTeaUI team and fall back gracefully without breaking layouts.

### Key Entities *(include if feature involves data)*

- **TUI Screen Pattern**: Defines header/body/status structure, required hint line, and focus behavior for a given screen type.
- **Keyboard Hint Set**: The set of visible shortcuts per screen (navigation, action, exit) that must stay in sync with actual behavior.
- **Layout Density Rule**: Parameters (row spacing, column choices) tied to terminal width and row count to keep lists readable.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All screens render header/body/status with visible keyboard hints in tests; automated snapshots confirm 100% coverage across menu, list, detail, install, update, remove, and error screens.
- **SC-002**: In 80-column headless tests with ≥20 toolchains, focused rows remain visible and identifiers/channels/status are not overlapped in 100% of runs; empty state surfaces install guidance.
- **SC-003**: Keyboard-only journeys from menu → action → back complete in under 60 seconds in automated flows, with focus correctly restored on return in 100% of test runs.
- **SC-004**: UX guideline is published and referenced by tasks/tests; reviewers can verify layout/hint conformity using the guide for all new screens added in this feature.

# Feature Specification: SwifTeaUI-Driven TUI Flows

**Feature Branch**: `001-swifteaui-tui`  
**Created**: 2025-11-24  
**Status**: Draft  
**Input**: User description: "SwifTeaUI component-driven TUI flows"

## User Scenarios & Testing *(mandatory)*

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - Navigate and Switch Toolchains (Priority: P1)

CLI users need a guided, component-based TUI menu to browse installed Swift toolchains, view details, and switch the active toolchain without guessing commands.

**Why this priority**: Switching toolchains is the most common path to unblock local work; it must be obvious, fast, and reliable.

**Independent Test**: Launch `swiftly tui`, navigate with keyboard to a toolchain entry, view its details, and switch active toolchain with confirmation and success feedback.

**Acceptance Scenarios**:

1. **Given** at least two installed toolchains, **When** the user opens the TUI and selects a toolchain via number or arrow keys, **Then** the detail view shows version, channel, and active status.
2. **Given** an inactive toolchain is selected, **When** the user confirms "Switch", **Then** the active toolchain changes and a success message states the new active version.

---

### User Story 2 - Guided Install/Update/Remove (Priority: P2)

CLI users want guided flows to install, update, or remove toolchains with clear prompts, progress, and safeguards so they can manage environments without memorizing flags.

**Why this priority**: Managing toolchains safely prevents downtime and aligns with the project's TDD and composability standards.

**Independent Test**: From the TUI, start an install/update/remove flow, respond to confirmations, observe progress updates, and see final success/failure summary without shelling out to raw commands.

**Acceptance Scenarios**:

1. **Given** the user chooses Install, **When** they accept the default "latest stable" or input a specific identifier, **Then** the TUI shows progress and ends with a clear success summary including the installed identifier.
2. **Given** the user chooses Remove on an inactive toolchain, **When** they confirm deletion, **Then** the toolchain is removed and no longer appears in the list with a completion notice.

---

### User Story 3 - Error Visibility and Recovery (Priority: P3)

CLI users need actionable error views with retry or cancel options so failures (e.g., network, disk space) do not leave the toolchain state ambiguous.

**Why this priority**: Clear recovery reduces support load and keeps the CLI trustworthy during long-running operations.

**Independent Test**: Simulate a failing install (e.g., unreachable server), observe the error view with cause, and choose retry/abort to see the state restored without crashes.

**Acceptance Scenarios**:

1. **Given** a network failure occurs mid-install, **When** the TUI surfaces the error, **Then** it shows the cause, offers retry or abort, and returns to a stable menu after the choice.
2. **Given** a user aborts an update, **When** the operation stops, **Then** the previously active toolchain remains usable and the TUI confirms no partial update remains.

---

### Edge Cases

- No toolchains installed: TUI should present an empty state with guidance to install.
- Invalid identifier input: show validation error and allow correction without exiting.
- Long-running install/update (>5 minutes): progress should keep updating and allow cancel.
- Removal request on active toolchain: prompt to switch first or explicitly confirm force removal.
- Interrupted operation (process kill/ctrl+C): on next launch, TUI should detect incomplete work and guide recovery.
- Network or storage failure mid-operation: surface the error, avoid crash, and log the path for review.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The TUI MUST use SwifTeaUI scenes/components to render a menu, list, detail, and action confirmations navigable by keyboard (numbers, arrows, enter, q to exit).
- **FR-002**: The TUI MUST list installed toolchains with version, channel, and an active indicator, and allow selecting one to view its details.
- **FR-003**: Users MUST be able to switch the active toolchain from the TUI with an explicit confirmation and a success/failure summary that states the resulting active toolchain.
- **FR-004**: Users MUST be able to install a toolchain by accepting a default (latest stable) or entering an identifier; the flow MUST show a progress indicator that updates at least every 5 seconds until completion.
- **FR-005**: Users MUST be able to update an existing toolchain via the TUI, see what will change, and receive a completion summary with status per target toolchain.
- **FR-006**: Users MUST be able to remove a toolchain via the TUI; removal MUST require confirmation and MUST block or prompt the user to switch if the target is currently active.
- **FR-007**: On any operation error, the TUI MUST present an error view that includes the cause, offers retry and cancel options, and records the log/output location for follow-up.
- **FR-008**: Core actions (list, detail, switch, install, update, remove) MUST be testable in a headless/non-interactive mode with deterministic outputs suitable for CI on macOS and Linux.
- **FR-009**: If needed SwifTeaUI components are missing, the TUI MUST note the gap (message in UI and logs) while providing a minimal fallback layout so flows remain usable.

### Key Entities *(include if feature involves data)*

- **Toolchain**: A Swift toolchain with identifier, version, channel (stable, snapshot), install location, and active flag.
- **Operation Session**: An install, update, remove, or switch action with inputs (target identifier), progress state, outcome (success/failure), and log reference.

## Assumptions

- SwifTeaUI main branch remains available and compatible; any missing components are documented per FR-009.
- Core toolchain operations (list, switch, install, update, remove) are exposed by Swiftly and callable from the TUI.
- Network access exists for install/update when required; offline mode still supports listing and switching.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can navigate from the main menu to switching a toolchain and receive confirmation in under 60 seconds without referring to external docs.
- **SC-002**: Install/update/remove flows display progress updates at least every 5 seconds during long-running operations and finish with a clear success or failure summary 100% of the time in tests.
- **SC-003**: 95% of keyboard-only navigation attempts (menu, list selection, action confirmation, exit) succeed on first try in macOS and Linux test runs.
- **SC-004**: Error scenarios (network failure, invalid identifier, interrupted operation) present actionable retry/abort choices and return the TUI to a stable state with no crashes in 100% of scripted test cases.

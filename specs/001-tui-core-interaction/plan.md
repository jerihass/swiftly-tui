# Implementation Plan: TUI Interface for Core Functions

**Branch**: `001-tui-core-interaction` | **Date**: 2025-11-25 | **Spec**: specs/001-tui-core-interaction/spec.md
**Input**: Feature specification from `/specs/001-tui-core-interaction/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command.

## Summary

Provide a keyboard-only TUI that guides users through core swiftly actions (list, switch, install, uninstall, update) with clear status, progress, and error handling on macOS and Linux. The interface will use SwifTeaUI (branch main) for rendering and navigation, keeping business logic in existing core services and surfacing progress/responses in a composable way.

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Swift 6  
**Primary Dependencies**: swift-argument-parser, AsyncHTTPClient stack (existing), SwifTeaUI (branch main) for TUI rendering  
**Storage**: File-based toolchain metadata/config (existing); no new storage  
**Testing**: XCTest unit tests; CLI/TUI integration tests on macOS and Linux covering core actions and error flows  
**Target Platform**: macOS 13+ and Linux (existing support matrix)  
**Project Type**: Single CLI project (Swift package)  
**Performance Goals**: TUI interactions respond to keypress within ~200ms; progress updates stream without blocking; actions report results within existing core operation times  
**Constraints**: Must remain keyboard-only and readable at 80x24; destructive actions require confirmation; platform parity for behaviors and messages; leverage existing core services (no business logic in TUI)  
**Scale/Scope**: Handles dozens of installed/available toolchains; single-user CLI sessions; minimal concurrent sessions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Tests-first: Each planned task includes failing tests before implementation (unit + CLI/integration) with macOS and Linux coverage.
- Composable modules: CLI commands stay thin; domain services and IO adapters are separated and injected.
- Platform parity & safety: Plans account for safe filesystem/process actions, checksum/signature validation, and recovery paths.
- CLI contract stability: Any flag/command changes note compatibility expectations and migration guidance.
- Release readiness: Expected version bump level and rollback/migration steps are identified when behavior changes.

Gate evaluation: No violations identified; plan follows TDD-first workflow, keeps domain logic in `SwiftlyCore`, and maintains platform parity and CLI contract stability with confirmations for destructive actions.

## Project Structure

### Documentation (this feature)

```text
specs/001-tui-core-interaction/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
Sources/
├── Swiftly/              # CLI entrypoints and command wiring (add TUI composition)
├── SwiftlyCore/          # Core domain/services for toolchain management
├── SwiftlyDownloadAPI/   # Networking for toolchain discovery
├── SwiftlyWebsiteAPI/    # Additional API client code
├── MacOSPlatform
└── LinuxPlatform

Tests/
└── SwiftlyTests/         # Unit and integration tests (extend for TUI/CLI flows)
```

**Structure Decision**: Use existing Swift package layout; add TUI composition in `Sources/Swiftly` (UI layer) reusing services in `Sources/SwiftlyCore`; extend `Tests/SwiftlyTests` with TUI-focused unit and CLI integration coverage.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

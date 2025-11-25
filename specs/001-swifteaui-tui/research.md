# Research: SwifTeaUI-Driven TUI Flows

## Findings

### Decision: Use SwifTeaUI list/detail/progress/error components for all TUI surfaces
- **Rationale**: Aligns with plan to build a component-driven UI, improves navigation consistency, and reduces manual rendering bugs. SwifTeaUI scenes support keyboard navigation and structured state → action flows that match FR-001..FR-009.
- **Alternatives considered**: Keep manual prints (rejected: brittle, no navigation support); build custom renderer (rejected: slower, violates composability goal).

### Decision: Keep default install target as latest stable, allow typed identifier override
- **Rationale**: Matches common user expectation and keeps flow fast; FR-004 requires both default and explicit identifier. Minimal prompt text keeps TUI concise.
- **Alternatives considered**: Force explicit identifier (rejected: slower, more error-prone); auto-select nightly (rejected: violates safety for most users).

### Decision: Provide retry/cancel error view with log pointer
- **Rationale**: Satisfies FR-007 and error recovery success criteria; reduces crashes like prior runtime assertion; keeps platform-parity behavior consistent.
- **Alternatives considered**: Auto-retry only (rejected: hides user intent); fail-fast without retry (rejected: poor UX, more support tickets).

### Decision: Progress updates at least every 5 seconds during long-running ops
- **Rationale**: Matches success criteria (SC-002) and keeps users informed during installs/updates; simple to implement with timers/ticks from adapters.
- **Alternatives considered**: Only step-based progress (rejected: may appear frozen on large downloads); continuous stream (rejected: noisy, harder to test).

### Decision: Headless test harness for scenes/flows
- **Rationale**: Needed for CI across macOS/Linux to exercise actions without interactive input; aligns with constitution TDD and platform parity.
- **Alternatives considered**: Manual-only TUI tests (rejected: not CI-friendly); snapshot-based only (rejected: brittle across terminals).

### Decision: SwifTeaUI branch `main`
- **Rationale**: User requirement to track main; simplifies dependency management.
- **Alternatives considered**: Pin commit/branch (rejected unless instability appears; document gaps per FR-009).

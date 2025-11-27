# Research: TUI Design and UX Improvements

## Findings

### Decision: Enforce shared screen skeleton (header/body/status + hints)
- **Rationale**: Reduces navigation ambiguity and keeps focus/hints predictable across all flows.
- **Alternatives considered**: Ad-hoc per-screen layouts (rejected: inconsistent UX, harder to test).

### Decision: Use SwifTeaUI Table/List with density rules for 80-col terminals
- **Rationale**: Table supports focus styles and column control; density rules keep long lists readable on narrow terminals.
- **Alternatives considered**: Manual string rendering (rejected: brittle, inconsistent focus cues), custom renderer (rejected: reimplements components).

### Decision: Always-visible keyboard hints in status bar
- **Rationale**: Prevents mode confusion; aligns with accessibility and quick discovery of shortcuts.
- **Alternatives considered**: Contextual popups or hidden hints (rejected: discoverability and parity risks).

### Decision: Document UX patterns for future screens
- **Rationale**: Keeps new flows consistent and speeds review; provides a single reference for layout/hints/focus.
- **Alternatives considered**: Inline comments only (rejected: easily drift), tribal knowledge (rejected: non-repeatable).

### SwifTeaUI components and gaps
- Components to leverage: `Table`, `StatusBar`, `Text`, `VStack/HStack`, focus row styles.
- Current gaps: None identified; if richer progress/error widgets are needed, document for SwifTeaUI team before implementation.

# Data Model: SwifTeaUI-Driven TUI Flows

## Entities

### Toolchain
- **Identifier**: String (unique; corresponds to Swift toolchain identifier)
- **Version**: String (semantic version + channel label)
- **Channel**: Enum {stable, snapshot}
- **Location**: String (filesystem path)
- **Active**: Bool
- **Metadata**: Optional {installedAt, checksum/signature status, size}

### OperationSession
- **Type**: Enum {list, detail, switch, install, update, remove}
- **TargetIdentifier**: String (matches Toolchain.Identifier)
- **State**: Enum {pending, running, succeeded, failed, cancelled}
- **Progress**: Int 0-100 (updates at least every 5 seconds for long ops)
- **Message**: Optional String (current step or error cause)
- **LogPath**: Optional String (points to stdout/stderr/logs)
- **StartedAt / CompletedAt**: Timestamps

## Relationships
- OperationSession targets one Toolchain by Identifier (except list operations which target all).
- Active Toolchain is unique at any time (only one may be active).

## Validation Rules
- Toolchain.Identifier must be non-empty and unique.
- Removal of an active Toolchain requires confirmation and/or pre-switch.
- Progress must be bounded 0..100; State transitions must be valid (e.g., pending → running → succeeded|failed|cancelled).
- Install/update/remove requires writable target location; failures must preserve previously active toolchain state.

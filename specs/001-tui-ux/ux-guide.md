# UX Guide: Swiftly TUI

## Purpose
Define reusable patterns for layouts, keyboard hints, focus, density, and messaging so all TUI screens stay consistent.

## Layout Skeleton (All Screens)
- Header: product name + current screen title.
- Body: primary content (menu, list/table, detail, input, error/progress).
- Fixed baseline canvas: consistent width and baseline height (~18 lines) so screens don’t jump; use SwifTeaUI sizing/padding utilities (e.g., ZStack + spacer).
- Status: breadcrumbs on the left; context-specific keyboard hints on the right.

## Keyboard Conventions
- Navigation: numbers for menu jumps, `j`/`k` or arrows for list movement, `b` to go back, `q`/`0` to exit.
- Actions: `Enter`/`Space` to activate; per-screen actions (e.g., `s` to switch) documented inline.
- Hints: Always visible in the status bar; must match bindings in code.

## Focus & Accessibility
- Focused rows/inputs use consistent markers (row highlight + `>` prefix in text fallbacks).
- Focus persists when navigating back/forward; mixed input (numbers + arrows) must keep the same focus target.

## Density & Tables
- Default spacing: compact when ≥20 rows or terminal width ≤80 columns; otherwise relaxed spacing.
- Columns: identifier (flex), channel (fit), status (fit); truncate identifiers beyond ~32 characters with ellipsis.

## Input & Errors
- Inline validation/error messages retain focus; no clearing of user input on failure.
- Progress/error views keep hints visible and show log path when available.
- Use SwifTeaUI Spinner for in-flight states; add ProgressMeter when percentage is known.

## Themes & Framing
- Use SwifTeaUI `Border` + theme colors for frames (no custom ASCII borders).
- Use SwifTeaUI toasts for transient success/error/info; reserve modals for confirmations or critical messaging.
- Document any missing components (e.g., richer progress widgets) for the SwifTeaUI team.

## Empty States
- Provide actionable guidance (e.g., “No toolchains installed. Use Install (3) to add one.”).
- Keep hints visible and aligned with the status bar.

## Reviewer Checklist (apply per screen)
- Uses header/body/status skeleton.
- Keyboard hints match `mapKeyToAction` bindings.
- Focus markers visible and persistent.
- Table density/columns fit within 80 columns with ≥20 rows.
- Input/error states retain focus and show inline messages.

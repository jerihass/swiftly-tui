import SwifTeaUI

/// Accessibility cues (focus indicators, row styling).
enum AccessibilityStyles {
    /// Prefix used when rendering focused rows or inputs in plain text fallbacks.
    static func focusIndicator(for text: String) -> String {
        "> \(text)"
    }

    /// Returns the shared row style used across all table/list views.
    static func focusedRowStyle(hasFocus: Bool, theme: SwifTeaTheme = .basic) -> TableRowStyle? {
        hasFocus ? TableRowStyle.focusedWithMarkers(accent: theme.accent) : nil
    }
}

/// Centralized keyboard hints to keep visible StatusBar content in sync with bindings.
enum KeyboardHints {
    enum Context {
        case menu
        case list
        case detail
        case input
        case progress
        case result
        case error
    }

    /// Human-friendly hint line shown in the status bar.
    static func description(for context: Context) -> String {
        switch context {
        case .menu:
            return "1 list · 2 switch · 3 install · 4 uninstall · 5 update · 0/q exit"
        case .list:
            return "j/k/arrow move · Enter/Space open · # jump · / filter · 1 refresh · b back · Esc clear · 0/q exit"
        case .detail:
            return "s switch · b back · q exit"
        case .input:
            return "Enter submit · Esc cancel · q exit"
        case .progress:
            return "Working… q exit"
        case .result:
            return "1 refresh list · b back · 0/q exit"
        case .error:
            return "r retry · c cancel · b back · 0/q exit"
        }
    }
}

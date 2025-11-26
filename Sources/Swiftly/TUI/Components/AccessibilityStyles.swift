import SwifTeaUI

/// Accessibility cues (focus indicators, row styling).
enum AccessibilityStyles {
    static func focusIndicator(for text: String) -> String {
        "> \(text)"
    }

    static func focusedRowStyle(hasFocus: Bool) -> TableRowStyle? {
        hasFocus ? TableRowStyle.focusedWithMarkers() : nil
    }
}

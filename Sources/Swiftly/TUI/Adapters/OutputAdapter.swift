/// Ensures stdout/stderr separation and structured error messaging. Placeholder for future wiring.
enum OutputAdapter {
    static func info(_ message: String) -> String {
        message
    }

    static func error(_ message: String) -> String {
        "ERROR: \(message)"
    }
}

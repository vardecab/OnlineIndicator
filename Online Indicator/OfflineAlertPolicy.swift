/// Sends one alert after two consecutive failed checks, rearming after recovery.
struct OfflineAlertPolicy {
    private var consecutiveFailures = 0

    mutating func record(isConnected: Bool) -> Bool {
        if isConnected {
            consecutiveFailures = 0
            return false
        }

        // Saturate so an extended outage cannot overflow or send more alerts.
        guard consecutiveFailures < 2 else { return false }
        consecutiveFailures += 1
        return consecutiveFailures == 2
    }
}

// Run from the repository root:
// swiftc 'Online Indicator/OfflineAlertPolicy.swift' Tests/main.swift -o /tmp/online-indicator-policy-tests
// /tmp/online-indicator-policy-tests

func expectAlerts(_ checks: [Bool], _ expected: [Int]) {
    var policy = OfflineAlertPolicy()
    var alerts: [Int] = []
    for (index, connected) in checks.enumerated() {
        if policy.record(isConnected: connected) { alerts.append(index) }
    }
    precondition(alerts == expected, "Expected alerts at \(expected), got \(alerts)")
}

expectAlerts([true, true, true], [])
expectAlerts([false], [])
expectAlerts([false, false], [1])
expectAlerts([true, false, true, false, true], [])
expectAlerts(Array(repeating: false, count: 10_000), [1])
expectAlerts([false, false, true, false, false], [1, 4])
expectAlerts([false, true, false, false], [3])
print("All offline alert policy checks passed.")

// Run from the repository root:
// swiftc 'Online Indicator/OfflineAlertPolicy.swift' 'Online Indicator/OfflineAlertPosition.swift' Tests/main.swift -o /tmp/online-indicator-policy-tests
// /tmp/online-indicator-policy-tests
import Foundation
import CoreGraphics

func expectAlerts(_ checks: [Bool], _ expected: [Int]) {
    var policy = OfflineAlertPolicy()
    var alerts: [Int] = []
    var expectedActive = false
    for (index, connected) in checks.enumerated() {
        if policy.record(isConnected: connected) { alerts.append(index) }
        if connected { expectedActive = false }
        else if expected.contains(index) { expectedActive = true }
        precondition(policy.isAlertActive == expectedActive,
                     "Unexpected alert/recovery polling state at check \(index)")
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

let visibleFrame = NSRect(x: 100, y: 50, width: 1440, height: 900)
let alertSize = NSSize(width: 220, height: 62)
let expectedPositions: [(OfflineAlertPosition, NSPoint)] = [
    (.topLeft, NSPoint(x: 116, y: 872)),
    (.topCenter, NSPoint(x: 710, y: 872)),
    (.topRight, NSPoint(x: 1304, y: 872)),
    (.center, NSPoint(x: 710, y: 469)),
    (.bottomLeft, NSPoint(x: 116, y: 66)),
    (.bottomCenter, NSPoint(x: 710, y: 66)),
    (.bottomRight, NSPoint(x: 1304, y: 66))
]
for (position, expected) in expectedPositions {
    let origin = position.origin(in: visibleFrame, alertSize: alertSize)
    precondition(origin == expected, "Unexpected origin for \(position): \(origin)")
    precondition(visibleFrame.contains(NSRect(origin: origin, size: alertSize)))
}
print("All offline alert position checks passed.")

import Foundation

enum OfflineAlertPosition: String, CaseIterable, Identifiable {
    case topLeft, topCenter, topRight, center, bottomLeft, bottomCenter, bottomRight

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topLeft: "Top Left"
        case .topCenter: "Under Notch / Top Center"
        case .topRight: "Top Right"
        case .center: "Center"
        case .bottomLeft: "Bottom Left"
        case .bottomCenter: "Bottom Center"
        case .bottomRight: "Bottom Right"
        }
    }

    static var current: Self {
        let saved = UserDefaults.standard.string(forKey: "offlineAlertPosition") ?? ""
        return Self(rawValue: saved) ?? .topRight
    }

    /// Place the alert within the display's usable area, including screen padding.
    func origin(in visibleFrame: NSRect, alertSize: NSSize) -> NSPoint {
        let left = visibleFrame.minX + 16
        let right = visibleFrame.maxX - alertSize.width - 16
        let bottom = visibleFrame.minY + 16
        let top = visibleFrame.maxY - alertSize.height - 16
        let centerX = visibleFrame.midX - alertSize.width / 2
        let centerY = visibleFrame.midY - alertSize.height / 2

        let point: NSPoint
        switch self {
        case .topLeft: point = NSPoint(x: left, y: top)
        case .topCenter: point = NSPoint(x: centerX, y: top)
        case .topRight: point = NSPoint(x: right, y: top)
        case .center: point = NSPoint(x: centerX, y: centerY)
        case .bottomLeft: point = NSPoint(x: left, y: bottom)
        case .bottomCenter: point = NSPoint(x: centerX, y: bottom)
        case .bottomRight: point = NSPoint(x: right, y: bottom)
        }

        return NSPoint(
            x: max(visibleFrame.minX, min(point.x, visibleFrame.maxX - alertSize.width)),
            y: max(visibleFrame.minY, min(point.y, visibleFrame.maxY - alertSize.height))
        )
    }
}

extension Notification.Name {
    static let offlineAlertPositionChanged = Notification.Name("offlineAlertPositionChanged")
}

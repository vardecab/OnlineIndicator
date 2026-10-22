import AppKit
import SwiftUI

private enum OfflineAlertLayout {
    static let size = NSSize(width: 320, height: 88)
    static let cornerRadius: CGFloat = 14
    static let tint = NSColor(srgbRed: 1, green: 0.65, blue: 0.65, alpha: 0.35)
}

/// Keeps the outage visible without taking focus from the current app.
final class OfflineAlertManager {
    private var panel: NSPanel?
    private var screenObserver: NSObjectProtocol?

    func show() {
        guard panel == nil else { return }

        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: OfflineAlertLayout.size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isReleasedWhenClosed = false
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.contentView = makeContentView()
        self.panel = panel
        positionPanel()
        panel.orderFrontRegardless()

        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.positionPanel()
        }
    }

    private func makeContentView() -> NSView {
        let frame = NSRect(origin: .zero, size: OfflineAlertLayout.size)
        let content = NSHostingView(rootView: OfflineAlertView())
        content.frame = frame
        content.autoresizingMask = [.width, .height]

        if #available(macOS 26.0, *) {
            // Use the system material directly: macOS controls its glass appearance
            // and accessibility adjustments. Avoid a fixed blur or opacity layer.
            let glass = NSGlassEffectView(frame: frame)
            glass.cornerRadius = OfflineAlertLayout.cornerRadius
            glass.tintColor = OfflineAlertLayout.tint
            glass.contentView = content
            return glass
        }

        // Keep the existing macOS 14.6 minimum with a native vibrancy fallback.
        let material = NSVisualEffectView(frame: frame)
        material.material = .hudWindow
        material.blendingMode = .behindWindow
        material.state = .active
        material.wantsLayer = true
        material.layer?.cornerRadius = OfflineAlertLayout.cornerRadius
        material.layer?.masksToBounds = true

        let tint = NSView(frame: frame)
        tint.autoresizingMask = [.width, .height]
        tint.wantsLayer = true
        tint.layer?.backgroundColor = OfflineAlertLayout.tint.cgColor
        material.addSubview(tint)
        material.addSubview(content)
        return material
    }

    func dismiss() {
        panel?.orderOut(nil)
        panel = nil
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
            self.screenObserver = nil
        }
    }

    private func positionPanel() {
        guard let panel, let screen = panel.screen ?? NSScreen.main else { return }
        let visibleFrame = screen.visibleFrame
        panel.setFrameTopLeftPoint(NSPoint(
            x: visibleFrame.maxX - panel.frame.width - 16,
            y: visibleFrame.maxY - 16
        ))
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
    }
}

private struct OfflineAlertView: View {
    var body: some View {
        Button(action: openNetworkSettings) {
            HStack(spacing: 12) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(.primary)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Network is offline")
                        .font(.system(size: 13, weight: .semibold))
                    Text("Open Network Settings…")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .frame(width: OfflineAlertLayout.size.width,
                   height: OfflineAlertLayout.size.height, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Network is offline. Open Network settings to switch to a mobile hotspot or another connection.")
    }

    private func openNetworkSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Network-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
}

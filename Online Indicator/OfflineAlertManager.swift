import AppKit
import SwiftUI

/// Keeps the outage visible without taking focus from the current app.
final class OfflineAlertManager {
    private var panel: NSPanel?
    private var screenObserver: NSObjectProtocol?

    func show() {
        guard panel == nil else { return }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 148),
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
        panel.contentView = NSHostingView(rootView: OfflineAlertView())
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
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Network is offline")
                        .font(.headline)
                    Text("Switch to a mobile hotspot or another connection.")
                        .font(.subheadline)
                    Text("Open Network Settings…")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .frame(width: 360, height: 148, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityLabel("Network is offline. Open Network settings to switch to a mobile hotspot or another connection.")
    }

    private func openNetworkSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.Network-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }
}

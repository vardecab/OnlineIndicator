import AppKit
import SwiftUI

private enum OfflineAlertLayout {
    static let cornerRadius: CGFloat = 14
    static let tint = NSColor(srgbRed: 1, green: 0.6, blue: 0.6, alpha: 0.65)
}

/// Keeps the outage visible without taking focus from the current app.
final class OfflineAlertManager: NSObject {
    private var panel: NSPanel?
    private var screenObserver: NSObjectProtocol?
    private var displayedStatus: AppState.ConnectionStatus = .noNetwork

    func show(status: AppState.ConnectionStatus) {
        guard panel == nil else { update(status: status); return }
        displayedStatus = status
        let contentView = makeContentView()

        let panel = NSPanel(
            contentRect: contentView.frame,
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
        panel.contentView = contentView
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
        let content = NSHostingView(rootView: OfflineAlertView(status: displayedStatus))
        let frame = NSRect(origin: .zero, size: content.fittingSize)
        content.frame = frame
        content.autoresizingMask = [.width, .height]

        // A native button covers the full surface, including padding and empty
        // space, and accepts the first click while another app is active.
        let surface = NSView(frame: frame)
        surface.autoresizingMask = [.width, .height]
        // Native glass tint can be very subtle. A light color wash keeps the
        // warning visibly red while the system material remains underneath.
        let wash = NSView(frame: frame)
        wash.autoresizingMask = [.width, .height]
        wash.wantsLayer = true
        wash.layer?.backgroundColor = NSColor(srgbRed: 1, green: 0.48, blue: 0.48, alpha: 0.22).cgColor
        wash.layer?.cornerRadius = OfflineAlertLayout.cornerRadius
        surface.addSubview(wash)
        surface.addSubview(content)
        content.setAccessibilityHidden(true)
        let button = OfflineAlertButton(title: "", target: self, action: #selector(openWiFiSettings))
        button.frame = frame
        button.autoresizingMask = [.width, .height]
        button.isBordered = false
        button.focusRingType = .none
        button.setAccessibilityLabel("Network is offline. Open Wi-Fi settings to switch to a mobile hotspot or another connection.")
        surface.addSubview(button)

        if #available(macOS 26.0, *) {
            // macOS controls the native glass and its accessibility adjustments.
            let glass = NSGlassEffectView(frame: frame)
            glass.cornerRadius = OfflineAlertLayout.cornerRadius
            glass.tintColor = OfflineAlertLayout.tint
            glass.contentView = surface
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

        material.addSubview(surface)
        return material
    }

    func update(status: AppState.ConnectionStatus) {
        guard let panel, status != displayedStatus else { return }
        displayedStatus = status
        let contentView = makeContentView()
        panel.contentView = contentView
        panel.setContentSize(contentView.frame.size)
        positionPanel()
    }

    @objc private func openWiFiSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.wifi-settings-extension") {
            NSWorkspace.shared.open(url)
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

/// Allow one click anywhere on the alert even when its panel is inactive.
private final class OfflineAlertButton: NSButton {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}

private struct OfflineAlertView: View {
    let status: AppState.ConnectionStatus
    @State private var slot: IconPreferences.Slot

    init(status: AppState.ConnectionStatus) {
        self.status = status
        _slot = State(initialValue: IconPreferences.slot(for: status))
    }

    private var icon: IconPreferences.Slot {
        NSImage(systemSymbolName: slot.symbolName, accessibilityDescription: nil) != nil
            ? slot : IconPreferences.defaultSlot(for: status)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon.symbolName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color(nsColor: icon.color))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 5) {
                Text("Network is offline")
                    .font(.system(size: 13, weight: .semibold))
                Text("Open Wi-Fi Settings…")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Image(systemName: "arrow.up.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .fixedSize()
        .onReceive(NotificationCenter.default.publisher(for: .iconPreferencesChanged)) { _ in
            slot = IconPreferences.slot(for: status)
        }
    }
}

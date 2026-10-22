import Foundation

class AppState {

    static let shared = AppState()

    private let networkMonitor = NetworkMonitor()
    private let connectivityChecker = ConnectivityChecker()
    private let offlineAlert = OfflineAlertManager()
    private var offlineAlertPolicy = OfflineAlertPolicy()
    private var checkGeneration = 0

    private var refreshTimer: Timer?
    private var debounceTimer: Timer?

    enum ConnectionStatus {
        case connected
        case blocked
        case noNetwork
    }

    var statusUpdateHandler: ((ConnectionStatus) -> Void)?

    var checkNowResultHandler: ((ConnectionStatus) -> Void)?

    // Test mode is session-only so a relaunch always resumes real monitoring.
    private(set) var forceOffline = false

    func setForceOffline(_ enabled: Bool) {
        guard forceOffline != enabled else { return }
        forceOffline = enabled
        checkConnection()
    }

    var refreshInterval: TimeInterval {
        let saved = UserDefaults.standard.double(forKey: "refreshInterval")
        return saved == 0 ? 30 : saved
    }

    // MARK: - Public Start

    func start() {

        // Listen for network interface changes (WiFi off, Ethernet unplugged)
        networkMonitor.pathChangedHandler = { [weak self] in
            // Ignore a probe from the old network while the new path settles.
            self?.checkGeneration += 1
            self?.debouncedImmediateCheck()
        }

        networkMonitor.startMonitoring()

        startTimer()

        // Immediate outbound attempt on startup
        checkConnection()
    }

    // MARK: - Restart (when settings change)

    func restart() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        startTimer()
        checkConnection()
    }

    // MARK: - Immediate check (bypasses interval, triggered on demand)

    func checkNow() {
        checkConnection(onDemand: true)
    }

    // MARK: - Timer

    private func startTimer() {

        refreshTimer?.invalidate()

        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: refreshInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkConnection()
        }
    }

    // MARK: - Debounce for rapid network changes

    private func debouncedImmediateCheck() {

        debounceTimer?.invalidate()

        debounceTimer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: false
        ) { [weak self] _ in
            self?.checkConnection()
        }
    }

    // MARK: - Core Logic

    private func checkConnection(onDemand: Bool = false) {
        checkGeneration += 1
        let generation = checkGeneration

        if forceOffline || !networkMonitor.isConnected {
            publish(.noNetwork, onDemand: onDemand)
            return
        }

        connectivityChecker.checkOutboundConnection { [weak self] reachable in
            DispatchQueue.main.async {
                guard let self, self.checkGeneration == generation else { return }
                let status: ConnectionStatus = reachable ? .connected : .blocked
                self.publish(status, onDemand: onDemand)
            }
        }
    }

    private func publish(_ status: ConnectionStatus, onDemand: Bool) {
        if offlineAlertPolicy.record(isConnected: status == .connected) {
            offlineAlert.show(status: status)
        }
        if status == .connected {
            offlineAlert.dismiss()
        } else {
            offlineAlert.update(status: status)
        }
        statusUpdateHandler?(status)
        if onDemand { checkNowResultHandler?(status) }
    }
}

import Foundation

class ConnectivityChecker {

    static let defaultURLString = "http://captive.apple.com"

    static var monitoringURLString: String {
        let saved = UserDefaults.standard.string(forKey: "pingURL") ?? ""
        return saved.isEmpty ? defaultURLString : saved
    }

    private var currentTask: URLSessionDataTask?

    private let session = ConnectivityChecker.makeSession(timeout: 5)
    private let recoverySession = ConnectivityChecker.makeSession(timeout: 2.5)

    private static func makeSession(timeout: TimeInterval) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.httpMaximumConnectionsPerHost = 1
        configuration.httpAdditionalHeaders = ["Connection": "close"]
        return URLSession(configuration: configuration)
    }

    func checkOutboundConnection(fastRecovery: Bool = false, completion: @escaping (Bool) -> Void) {

        print("Attempting outbound connection to:", Self.monitoringURLString)

        guard let url = URL(string: Self.monitoringURLString) else {
            completion(false)
            return
        }

        currentTask?.cancel()
        currentTask = nil

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Finish recovery probes before the next 3-second tick, rather than
        // repeatedly cancelling a 5-second probe before it can complete.
        request.timeoutInterval = fastRecovery ? 2.5 : 5

        let activeSession = fastRecovery ? recoverySession : session
        let task = activeSession.dataTask(with: request) { [weak self] _, response, error in

            if let urlError = error as? URLError, urlError.code == .cancelled {

                return
            }

            self?.currentTask = nil

            if let error = error {
                print("Outbound Error:", error.localizedDescription)
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               (200...399).contains(httpResponse.statusCode) {
                completion(true)
            } else {
                completion(false)
            }
        }

        currentTask = task
        task.resume()
    }
}

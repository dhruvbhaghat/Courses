import Foundation
import Network

protocol ConnectivityMonitoring {
    var isConnected: Bool { get }
}

final class ConnectivityMonitor: ConnectivityMonitoring, @unchecked Sendable {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.example.learningdashboard.connectivity")
    private let lock = NSLock()
    private var connected = true

    var isConnected: Bool {
        lock.lock()
        defer { lock.unlock() }
        return connected
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.lock.lock()
            self.connected = path.status == .satisfied
            self.lock.unlock()
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

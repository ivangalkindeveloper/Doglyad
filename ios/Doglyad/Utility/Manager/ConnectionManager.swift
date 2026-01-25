import Network

protocol ConnectionManagerProtocol: AnyObject {
    func start()
    
    var isConnected: Bool { get }
    
    func stop()
}

final class ConnectionManager {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(
        qos: .utility
    )
    
    init() {
        self.monitor.pathUpdateHandler = { path in
            _ = path.status
        }
    }
}

extension ConnectionManager: ConnectionManagerProtocol {
    func start() -> Void {
        monitor.start(queue: queue)
    }
    
    var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }
    
    func stop() -> Void {
        monitor.cancel()
    }
}

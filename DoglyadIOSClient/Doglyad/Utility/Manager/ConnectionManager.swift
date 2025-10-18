//
//  ConnectionMonitor.swift
//  Doglyad
//
//  Created by Иван Галкин on 18.10.2025.
//

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
            let status = path.status
        }
    }
}

extension ConnectionManager: ConnectionManagerProtocol {
    func start() {
        monitor.start(queue: queue)
    }
    
    var isConnected: Bool {
        monitor.currentPath.status == .satisfied
    }
    
    func stop() {
        monitor.cancel()
    }
}

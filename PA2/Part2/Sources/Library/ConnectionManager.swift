//
//  SocketManager.swift
//  Assignment2
//
//  Created by Chris Martin on 4/28/17.
//
//

import Foundation

public class ConnectionManager {
    
    static let shared = ConnectionManager()
    
    private var communicators = [Int: Communicator]()
    
    func getCommunicator(using node: Node) -> Communicator {
        let address = node.address
        let port = node.port
        
        if let communicator = communicators[port] {
            return communicator
        }
        
        return getCommunicator(for: address, port: port)
    }
    
    func getCommunicator(for address: String, port: Int) -> Communicator {
        if let socket = communicators[port] {
            return socket
        }
        
        return Communicator(destination: address, port: port)
    }
    
    func closeAll() {
        for port in communicators.keys {
            killConnection(at: port)
        }
    }
    
    @discardableResult
    func killConnection(at port: Int) -> Bool {
        if communicators.removeValue(forKey: port) != nil {
            return true
        }
        return false
    }
    
    func register(communicator: Communicator) {
        let port = communicator.socket.port
        communicators[port] = communicator
    }
    
    func exists(port: Int) -> Bool {
        if communicators.index(forKey: port) != nil {
            return true
        }
        return false
    }
    
}

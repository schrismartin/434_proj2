//
//  NetworkLayer.swift
//  Assignment2
//
//  Created by Chris Martin on 4/26/17.
//
//

import Foundation
import Socket

final class Communicator {
    
    public var socket: SocketConnection
    
    fileprivate var bufferData = [String]()
    
    public convenience init(using node: Node) {
        let destination = node.address
        let port = node.port
        
        self.init(destination: destination, port: port)
        
        if socket.status == .closed {
            node.availablility = .unavailabile
        }
    }
    
    public init(destination: String, port: Int) {
        socket = SocketConnection(destination: destination, port: port)
    }
    
}

extension Communicator {
    
    func resetSocket() {
        let destination = socket.destination
        let port = socket.port
        
        socket = SocketConnection(destination: destination, port: port)
    }
    
}

// MARK: - Poll for Peers
extension Communicator {
    
    public func getPeer() -> Node? {
        do {
        
            let peerData = try getPeerString()
            return Node(payload: peerData)
        } catch {
            return getPeer()
        }
    }
    
    private func getPeerString() throws -> String {
        var peerData = bufferData.popFirst()
        while peerData == nil {
            try populateBuffer()
            peerData = bufferData.popFirst()
        }
        
        // If returns, peer data must not equal nil
        return peerData!
    }
    
    private func populateBuffer() throws {
        try sendPeerRequest()
        let data = try fetchPeerData()
        
        let string = String(data: data, encoding: .utf8)!
        bufferData = string.components(separatedBy: "\n")
        if let last = bufferData.last, last == "" {
            _ = bufferData.popLast() // Remove trailing empty string
        }
    }
    
    private func sendPeerRequest() throws {
        let peersRequest = "PEERS\n"
        do {
            if !socket.socket.remoteConnectionClosed {
                _ = try socket.socket.write(from: peersRequest)
            } else {
                resetSocket()
                _ = try socket.socket.write(from: peersRequest)
            }
        } catch {
            resetSocket()
            try sendPeerRequest()
        }
    }
    
    private func fetchPeerData() throws -> Data {
        var data = Data()
        try _ = socket.socket.read(into: &data)
        return data
    }
    
    private func decodePeer(from data: Data) throws -> Node? {
        if let payload = String(data: data, encoding: .utf8) {
            return Node(payload: payload)
        } else {
            throw AppError.communicationFailure
        }
    }
    
}

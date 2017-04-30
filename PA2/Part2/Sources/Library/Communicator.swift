//
//  NetworkLayer.swift
//  Assignment2
//
//  Created by Chris Martin on 4/26/17.
//
//

import Foundation
import Socket

/// Handles communication between the server and the client
final public class Communicator {
    
    /// Socket used to communicate
    public var socket: SocketConnection
    
    /// Sockets may return multiple peers at a time. This stores
    /// all data returned from a call, and `getPeer()` will pop from
    /// the buffer and replinish when necessary.
    fileprivate var bufferData = [String]()
    
    fileprivate var isListening = false
    
    fileprivate var node: Node?
    
    /// Create a `Communicator` meant to interface with a given node while
    /// setting the node's `availibility` flag based on connection status.
    ///
    /// - Parameter node: Node in which to talk to.
    public convenience init(using node: Node) {
        let destination = node.address
        let port = node.port
        
        self.init(destination: destination, port: port)
    }
    
    /// Create a socket that talks to a
    ///
    /// - Parameters:
    ///   - destination: IP Address acting as the destination of the request.
    ///   - port: Port number to connect to.
    public init(destination: String, port: Int) {
        socket = SocketConnection(destination: destination, port: port)
        ConnectionManager.shared.register(communicator: self)
        
        guard let node = NodeManager.shared.getNode(port: port) else { return }
        assignAvailability(for: node)
        self.node = node
    }
    
    deinit {
        ConnectionManager.shared.killConnection(at: socket.port)
    }
    
}

extension Communicator {
    
    typealias ListenHandler = (_ data: Data, _ port: Int) -> Void
    
    func listen(handler: @escaping ListenHandler) {
        guard socket.status == .open else { return }
        
        isListening = true
        while true {
            let data = fetchData()
            
            DispatchQueue.main.async {
                handler(data, self.socket.port)
            }
        }
    }
    
    func cancelListen() {
        isListening = false
    }
    
    /// Set a node's `availability` flag based on connectivity
    ///
    /// - Parameter node: Subject Node
    func assignAvailability(for node: Node) {
        switch socket.status {
        case .open: node.availablility = .available
        case .closed: node.availablility = .unavailabile
        }
    }
    
    /// Reset the used socket
    func resetSocket() {
        let destination = socket.destination
        let port = socket.port
        
        socket = SocketConnection(destination: destination, port: port)
    }
    
}

// MARK: - Poll for Peers
extension Communicator {
    
    /// Returns whether a node is unique
    public typealias NodeUniquenessEvaluator = (_ node: Node) -> Bool
    
    /// Get the peers of a node
    ///
    /// - Parameters:
    ///   - node: Subject Node
    ///   - count: Number of expected peer nodes (Default: 20)
    ///   - timeout: Number of times to poll unique node until passing
    ///   - evaluator: Determine whether node is unique
    /// - Returns: Set of peer nodes
    @discardableResult
    public func getPeers(of node: Node, count: Int = 20, timeout: Int? = nil, evaluator: NodeUniquenessEvaluator) -> Set<Node> {
        let timeout = timeout ?? 10
        var nodeSet = Set<Node>()
        guard socket.status == .open else { return nodeSet }
        
        var counter = 0
        while nodeSet.count != count, (counter < timeout || timeout == -1) {
            guard let peer = getPeer() else { continue }
            nodeSet.insert(peer)
            
            let isUnique = evaluator(peer)
            if isUnique {
                counter = 0
            } else {
                counter += 1
            }
        }
        
        return nodeSet
    }
    
    /// Return one peer node from the server. If one cannot be obtained,
    /// the function will recursively call itself until it has received one.
    ///
    /// - Returns: Peer node
    public func getPeer() -> Node? {
        let peerString = getPeerString()
        let peer = NodeManager.shared.getNode(using: peerString)
        
        if let node = node, let peer = peer {
            NodeManager.shared.registerPeers(for: node.port, with: peer.port)
        }
        
        return peer
    }
    
    /// Get a peer string from the buffer. If buffer is empty, repopulate the
    /// buffer using a call from the server.
    ///
    /// - Returns: Unparsed `PEERS` response string
    private func getPeerString() -> String {
        var peerData = bufferData.popFirst()
        
        // When while loop exits, peerData must have value
        while peerData == nil {
            populateBuffer()
            peerData = bufferData.popFirst()
        }
        
        return peerData!
    }
    
    /// Sends peer request and fetches the results. Stores result in buffer.
    private func populateBuffer() {
        sendPeerRequest()
        let data = fetchData()
        
        let string = String(data: data, encoding: .utf8)!
//        print(string)
        bufferData = string.components(separatedBy: "\n")
        if let last = bufferData.last, last == "" {
            _ = bufferData.popLast() // Remove trailing empty string
        }
    }
    
    /// Send `PEERS` request to server. Throws `fatalError` if socket cannot
    /// write to the port.
    private func sendPeerRequest() {
        let peersRequest = "PEERS\n"
//        print(peersRequest)
        do {
        _ = try socket.write(from: peersRequest)
        } catch {
            fatalError("sendPeerRequest was unable to write to socket "
                + "with destination port \(socket.port). (err: \(error))")
        }
    }
    
    /// Get the response from `PEERS` request from the port.
    ///
    /// - Returns: Returned data from socket in response to PEERS data.
    fileprivate func fetchData() -> Data {
        do {
            var data = Data()
            try _ = socket.read(into: &data)
            return data
        } catch {
            fatalError("fetchPeerData was unable to read from socket"
                + "with destination port \(socket.port). (err: \(error)")
        }
        
    }
    
}

//
//  Node.swift
//  Assignment2
//
//  Created by Chris Martin on 4/26/17.
//
//

import Foundation

/// Wrapper class for Node objects
public final class Node {
    
    static let defaultAddress = "160.36.57.98"
    
    /// Marks whether a node is or isn't available.
    ///
    /// - undetermined: Node has not been checked for availability
    /// - available: Node is available for connection.
    /// - unavailabile: Node is not available for connection.
    public enum Availability: Int {
        
        /// Node has not been checked for availability
        case undetermined = -1
        
        /// Node is available for connection
        case available = 1
        
        /// Node is unavailable for connection
        case unavailabile = 0
    }
    
    /// Node identifier
    public var id: String
    
    /// Source IP Address
    public var address: String
    
    /// Source Port
    public var port: Int
    
    /// Peers
    public var peers = Set<Node>()
    
    /// Marks whether the node can be connected to.
    public var availablility: Availability
    
    /// Create a new node using a raw string representing the node.
    ///
    /// - Parameter payload: String containing node id, ip address, and port.
    public convenience init?(payload: String) {
        // Trim payload before parsing
        let payload = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Get node id and source
        var data = payload.components(separatedBy: "@")
        guard data.count == 2 else { return nil }
        
        guard let id = data.popFirst(), let source = data.popFirst()
            else { return nil }
        
        // Get address and port from source
        var addressComponents = source.components(separatedBy: ":")
        guard addressComponents.count == 2 else { return nil }
        
        guard let address = addressComponents.popFirst(),
            let portString = addressComponents.popFirst(),
            let port = Int(portString)
            else { return nil }
        
        self.init(id: id, address: address, port: port, availability: .available)
    }
    
    /// Creates a new node from an id, address, port, and availablility enum.
    ///
    /// - Parameters:
    ///   - id: Identifier of the node, which is a 64-character hex string.
    ///   - address: IP address of node
    ///   - port: port of node
    ///   - availability: Whether a node can be connected to.
    public init(id: String, address: String, port: Int, availability: Availability) {
        self.id = id
        self.address = address
        self.port = port
        self.availablility = availability
        
        NodeManager.shared.register(node: self)
    }
}

extension Node: CustomStringConvertible {
    
    public var description: String {
        let peers = self.peers.map { $0.port }.sorted()
        return "\(port), \(id), \(peers)"
    }
    
}

extension Node: Hashable {
    
    public var hashValue: Int {
        return port
    }
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.port == rhs.port
    }
    
}

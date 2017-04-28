//
//  NodeCollection.swift
//  Assignment2
//
//  Created by Chris Martin on 4/28/17.
//
//

import Foundation

/// Collection of Peer Nodes
class NodeCollection {
    
    /// Peer Nodes
    public var nodes = Set<Node>()
    
    /// Queue for processing nodes
    private var processQueue = [Node]()
    
    /// Populate the collection with peer nodes
    ///
    /// - Parameters:
    ///   - destination: IP Address of known node in the system
    ///   - port: IP Address of known node in the system
    ///   - expected: Expected number of nodes in the system
    func populate(destination: String, port: Int, expected: Int? = nil) {
        
        getInitialNodes(destination: destination, port: port)
        
        // Get peers of each node until queue is empty or expected number of
        // nodes has been fulfilled
        while let node = processQueue.popFirst(), !nodes.isFull(expected: expected) {
            
            let communicator = Communicator(using: node)
            guard communicator.socket.status == .open else { continue }
            
            communicator.getPeers(of: node, evaluator: { (node) -> Bool in
                return logUnique(node: node)
            })
        }
        
    }
    
    /// Print the nodes
    func printNodes() {
        nodes
            .sorted{ $0.0.port < $0.1.port }
            .forEach { print($0) }
    }
    
    /// Seed the node set
    ///
    /// - Parameters:
    ///   - destination: Destination IP Address
    ///   - port: Destionation Port
    private func getInitialNodes(destination: String, port: Int) {
        let communicator = Communicator(destination: destination, port: port)
        guard let initialNode = communicator.getPeer() else { return }
        
        communicator.getPeers(of: initialNode) { (node) -> Bool in
            return logUnique(node: node)
        }
    }
    
    /// Log only unique nodes
    ///
    /// - Parameter node: Node to be logged
    /// - Returns: Whether the node was unique
    @discardableResult
    private func logUnique(node: Node) -> Bool {
        if !nodes.contains(node) {
            nodes.insert(node)
            processQueue.append(node)
            return true
        } else {
            return false
        }
    }
    
}

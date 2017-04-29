//
//  NodeCollection.swift
//  Assignment2
//
//  Created by Chris Martin on 4/28/17.
//
//

import Foundation

protocol NodeCollectionDelegate: class {
    
    func populationUpdated(percentage: Double)
    
}

/// Collection of Peer Nodes
class NodeCollection {
    
    typealias ProgressIndicator = (_ percent: Double) -> Void
    
    /// Peer Nodes
    public var nodes = Set<Node>()
    
    public weak var delegate: NodeCollectionDelegate?
    
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
            
            let communicator = ConnectionManager.shared.getCommunicator(using: node)
            guard communicator.socket.status == .open else { continue }
            
            communicator.getPeers(of: node, evaluator: { (node) -> Bool in
                let isUnique = logUnique(node: node)
                if isUnique { getPercentage(expecting: expected) }
                return isUnique
            })
        }
        
    }
    
    func listenAll() {
        for node in nodes {
            let communicator = ConnectionManager.shared.getCommunicator(using: node)
            
            DispatchQueue.global().async {
                communicator.listen(handler: { (data, port) in
                    print(port, String(data: data, encoding: .utf8)!)
                })
            }
            
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
        let communicator = ConnectionManager.shared.getCommunicator(for: destination, port: port)
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
    
    private func getPercentage(expecting: Int?) {
        if let expecting = expecting {
            let percentage = Double(nodes.count) / Double(expecting)
            delegate?.populationUpdated(percentage: percentage)
        }
    }
    
}

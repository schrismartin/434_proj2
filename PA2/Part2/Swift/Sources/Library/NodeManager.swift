//
//  NodeManager.swift
//  Assignment2
//
//  Created by Chris Martin on 4/30/17.
//
//

import Foundation

class NodeManager {
    
    public static let shared = NodeManager()
    
    private var nodes = [Int: Node]()
    
    private init() { }
    
    func getNode(using payload: String) -> Node? {
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
        
        return getNode(for: address, port: port, id: id)
    }
    
    func getNode(port: Int) -> Node? {
        return nodes[port]
    }
    
    func getNode(for address: String, port: Int, id: String) -> Node {
        if let node = nodes[port] {
            return node
        }
        
        return Node(id: id, address: address, port: port, availability: .available)
    }
    
    @discardableResult
    func registerPeers(for a: Int, with b: Int) -> Bool {
        guard let a = nodes[a], let b = nodes[b] else { return false }
        
        a.peers.insert(b)
        b.peers.insert(a)
        return true
    }
    
    func closeAll() {
        for port in nodes.keys {
            killConnection(at: port)
        }
    }
    
    @discardableResult
    func killConnection(at port: Int) -> Bool {
        if nodes.removeValue(forKey: port) != nil {
            return true
        }
        return false
    }
    
    func register(node: Node) {
        let port = node.port
        nodes[port] = node
    }
    
    func exists(port: Int) -> Bool {
        if nodes.index(forKey: port) != nil {
            return true
        }
        return false
    }
    
}

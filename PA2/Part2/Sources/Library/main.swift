//
//  main.swift
//  Assignment2
//
//  Created by Chris Martin on 4/26/17.
//  Copyright © 2017 Chris Martin. All rights reserved.
//

import Foundation
import Socket

class MainApplication {
    
    var nodeSet = Set<Node>()
    var nodeArray = [Node]()
    var closedNodes = Set<Node>()
    
    init(args: [String]) throws {
        
        try getInitialNodes()
        
        while let node = nodeArray.popFirst() {
            
            do {
                let communicator = Communicator(using: node)
                guard communicator.socket.status == .open else { continue }
                
                let uniques = try getAllPeers(of: node, using: communicator)
                print("Node \(node.port) is open and has \(uniques.count) descendent nodes. (total: \(nodeSet.count))")
            } catch let error as AppError {
                switch error {
                case .closedNode(port: _):
                    print("Node \(node.port) is closed.")
                    closedNodes.insert(node)
                default:
                    throw error
                }
            }
        }
        
        nodeSet
            .sorted{ $0.0.port < $0.1.port }
            .forEach { print($0) }
    }
    
    func getInitialNodes() throws {
        let communicator = Communicator(destination: "160.36.57.98", port: 15112)
        guard let node = communicator.getPeer() else { return }
        
        try getAllPeers(of: node, using: communicator)
    }
    
    @discardableResult
    func logUnique(node: Node) -> Bool {
        if !nodeSet.contains(node) {
            nodeSet.insert(node)
            nodeArray.append(node)
            return true
        } else {
            return false
        }
    }
    
    @discardableResult
    func getAllPeers(of node: Node, using communicator: Communicator, timeout: Int = 1000) throws -> Set<Node> {
        var nodeSet = Set<Node>()
        var counter = 0
        while nodeSet.count != 20, counter < timeout {
            guard let node = try communicator.getPeer() else { continue }
            nodeSet.insert(node)
            
            if logUnique(node: node) == true {
                counter = 0
            } else {
                counter += 1
            }
        }
        
        return nodeSet
    }
    
}



do {
    _ = try MainApplication(args: CommandLine.arguments)
} catch let error as Socket.Error {
    dump(error)
} catch {
    dump(error)
}

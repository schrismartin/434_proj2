//
//  MainApplication.swift
//  Assignment2
//
//  Created by Chris Martin on 4/28/17.
//
//

import Foundation
import Darwin

/// Main Application to be run.
class MainApplication: NodeCollectionDelegate {
    
    var collection = NodeCollection()
    
    /// Program execution point
    ///
    /// - Parameter args: Commandline arguments
    init(args: [String]) throws {
        
        let arguments = try Arguments(args: args)
        
        if let peerPath = arguments.outpeerPath {
            let peerHandler = FileHandler(path: peerPath)
            
            collection.delegate = self
            if arguments.all {
                collection.populate(destination: Node.defaultAddress, port: 15012, timeout: -1, expected: nil)
            } else {
                collection.populate(destination: Node.defaultAddress, port: 15012, timeout: arguments.timeout)
            }
            
            collection.printNodes(to: peerHandler)
        }
        
        if let peerPath = arguments.inpeerPath {
            let peerHandler = FileHandler(path: peerPath)
            if let collection = peerHandler.readNodes() {
                collection.delegate = self
                self.collection = collection
                
                if arguments.checkForPublic {
                    collection.getAvailability()
                }
                
                collection.printNodes(availability: arguments.checkForPublic)
            }
        }
        
        if let dataPath = arguments.dataPath {
            let dataHandler = FileHandler(path: dataPath)
            
            ConnectionManager.shared.closeAll()
            collection.listenAll { (data, port) in
                let string = String(data: data, encoding: .utf8)!
                let information = "\(Int(Date().timeIntervalSince1970)) \(port) \(string)"
                let data = information.data(using: .utf8)!
                
                dataHandler.appendToFile(data: data)
            }
            Utils.wait()
        }
    }
    
    func populationUpdated(number: Int, total: Int) {
        if total != -1 {
            let percentage = Double(number) / Double(total)
            let completed = String(format: "%3.0lf", arguments: [percentage * 100])
            fputs("Nodes Gathered: [\(completed)%] (\(number) / \(total))\r", stdout)
            fflush(stdout)
        } else {
            fputs("Nodes Gathered: [ \(number) ]\r", stdout)
            fflush(stdout)
        }
    }
    
}

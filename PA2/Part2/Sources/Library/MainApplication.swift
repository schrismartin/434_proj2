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
    
    /// Program execution point
    ///
    /// - Parameter args: Commandline arguments
    init(args: [String]) {
        let collection = NodeCollection()
        collection.delegate = self
        
        collection.populate(destination: "160.36.57.98", port: 15012, expected: 240)
        collection.printNodes()
    }
    
    func populationUpdated(percentage: Double) {
        let completed = String(format: "%3.0lf", arguments: [percentage * 100])
        fputs("Nodes Gathered: [\(completed)%]\r", stdout)
        fflush(stdout)
    }
    
}

//
//  MainApplication.swift
//  Assignment2
//
//  Created by Chris Martin on 4/28/17.
//
//

import Foundation

/// Main Application to be run.
class MainApplication {
    
    /// Program execution point
    ///
    /// - Parameter args: Commandline arguments
    init(args: [String]) {
        
        let collection = NodeCollection()
        collection.populate(destination: "160.36.57.98", port: 15012)
        collection.printNodes()
    }
    
}

//
//  Node.swift
//  Assignment2
//
//  Created by Chris Martin on 4/26/17.
//
//

import Foundation

public class Node {
    
    enum Availability: Int {
        case available = 1
        case unavailabile = 0
    }
    
    /// Node identifier
    var id: String
    
    /// Source IP Address
    var address: String
    
    /// Source Port
    var port: Int
    
    var availablility: Availability
    
    convenience init?(data: Data) {
        guard let payload = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        try self.init(payload: payload)
    }
    
    convenience init?(payload: String) {
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
    
    init(id: String, address: String, port: Int, availability: Availability) {
        self.id = id
        self.address = address
        self.port = port
        self.availablility = availability
    }
}

extension Node: CustomStringConvertible {
    
    public var description: String {
        return "\(port), \(id), \(availablility.rawValue)"
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

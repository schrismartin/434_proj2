//
//  Utilities.swift
//  CommandLineTemplate
//
//  Created by Chris Martin on 4/26/17.
//  Copyright © 2017 Chris Martin. All rights reserved.
//

import Foundation
import Darwin

/// Errors thrown during the lifetime of the application
///
/// - badArgc: Incorrect number of arguments
/// - badArgv: Unexpected argument sequence
enum AppError: Error {
    
    case invalidPayload
    case communicationFailure
    case closedNode(port: Int)
    
    /// Errors relating to command-line argument parsing
    ///
    /// - badArgc: Incorrect number of arguments
    /// - badArgv: Unexpected argument sequence
    
    enum ParseError: Error {
        case extractId(payload: String)
        case extractAddress(payload: String)
        case decode
    }
    
    enum Arguments: Error {
        case badArgc
        case badArgv
    }
    
    var localizedDescription: String {
        switch self {
        case .invalidPayload: return "An invalid payload was received from the destination."
        case .communicationFailure: return "There was a failure with the communication."
        case .closedNode(port: let port): return "Port \(port) closed."
        }
    }
}

/// Namespace providing numerous helper functions.
class Utils {
    
    /// This class should not be initialized.
    private init() { }
    
    /// Print the correct usage of the program.
    public class func usage() {
        print("usage: l n g Pm Pc")
        exit(-1)
    }
    
    /// Calculates the hashValue of an array of Hashable items
    ///
    /// - Parameter contents: Contents of the bitstring to hash
    /// - Returns: New hashValue of the bitstring.
    public class func xorHashes<T: Hashable>(contents: [T]) -> Int {
        return contents.reduce(0, { (prev, current) -> Int in
            return prev.hashValue ^ current.hashValue
        })
    }
    
}

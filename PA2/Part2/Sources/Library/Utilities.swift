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
internal enum AppError: Error {
    
    case invalidPayload
    case communicationFailure
    case closedNode(port: Int)
    
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
public class Utils {
    
    /// This class should not be initialized.
    private init() { }
    
    public static func wait() {
        while true { }
    }
    
    /// Print the correct usage of the program.
    public class func usage() {
        print("usage: args\n" +
            "    --read-peers filename    : Read peers list from a file\n" +
            "    --write-peers filename   : Write peers list to a file\n" +
            "    --data-path filename     : Listen to rounds, record to file\n" +
            "    --timeout                : Set the number of duplicate tries before moving to the next node" +
            "    --all                    : Wait until all 20 nodes have full peer lists\n" +
            "    --check                  : Check for availability when reading peers")
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

/// Struct containt program arguments
struct Arguments {
    
    var inpeerPath: String?
    var outpeerPath: String?
    var dataPath: String?
    var timeout: Int?
    var all = false
    var checkForPublic = false
    
    /// Create an arguments struct given an array of strings
    ///
    /// - Parameter args: Base array
    /// - Throws: `badArgc` or `badArgv`
    init(args: [String]) throws {
        var args = args
        args.popFirst() // Remove program name
        
        if args.count == 0 { Utils.usage() }
        
        while let arg = args.popFirst() {
            switch arg {
            case "--read-peers":
                inpeerPath = args.popFirst()
            case "--write-peers":
                outpeerPath = args.popFirst()
            case "--data-path":
                dataPath = args.popFirst()
            case "--timeout":
                if let string = args.popFirst() { timeout = Int(string) }
            case "--all":
                all = true
            case "--check":
                checkForPublic = true
            default:
                print("Unrecognized arg \(arg)")
                Utils.usage()
            }
        }
    }
}

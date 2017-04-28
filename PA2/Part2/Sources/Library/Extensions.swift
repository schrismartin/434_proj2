//
//  Extensions.swift
//  CommandLineTemplate
//
//  Created by Chris Martin on 4/26/17.
//  Copyright © 2017 Chris Martin. All rights reserved.
//

import Foundation

/// Error for type conversion
///
/// - fromString: Error for conversion to type from string.
enum InvalidConversion: Error {
    case fromString(value: String)
}

extension Bool {
    
    /// Initialize a boolean value as the result of a random-number-generator
    /// falling within the range of the probability.
    ///
    /// - Parameter probability: Probability of calculating true
    init?(probability: Double) {
        guard (0.0...1.0).contains(probability) else {
            return nil
        }
        
        let rand = Double(arc4random()) / Double(UINT32_MAX)
        self = (0.0...probability).contains(rand)
    }
}

extension Array {
    
    /// Remove the first element from an array
    ///
    /// - Returns: Value removed
    @discardableResult
    public mutating func popFirst() -> Element? {
        return count > 0 ? remove(at: 0) : nil
    }
    
}

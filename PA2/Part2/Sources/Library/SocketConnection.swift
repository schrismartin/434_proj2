//
//  SocketConnection.swift
//  Assignment2
//
//  Created by Chris Martin on 4/27/17.
//
//

import Foundation
import Socket

/// Object representing a socket's connection to a server node.
public final class SocketConnection {
    
    /// Status of the socket's connection
    ///
    /// - open: Socket is open.
    /// - closed: Socket could not be connected to.
    public enum Status {
        
        /// Socket is open
        case open
        
        /// Socket could not be connected to.
        case closed
    }
    
    /// Socket used to communicate.
    fileprivate var socket: Socket
    
    /// Status of the socket's connection.
    public var status: Status
    
    /// Destination IP Address for the socket.
    public var destination: String
    
    /// Destination port for the socket.
    public var port: Int
    
    /// Create a new connection using an IP Address and a Port.
    ///
    /// - Parameters:
    ///   - destination: IP Address of destination Node.
    ///   - port: Port of destination Node.
    public convenience init(destination: String, port: Int) {
        let socket = try! Socket.create(family: .inet, type: .stream, proto: .tcp)
        var status: SocketConnection.Status = .open
        
        do {
            try socket.connect(to: destination, port: Int32(port))
        } catch let error as Socket.Error {
            // Check for connection refused
            if error.errorCode == -9989 {
                status = .closed
            }
        } catch {
            // Crash the program if something weird happened here.
            fatalError("There was an unknown error with the communicator construction. (0)")
        }
        
        self.init(
            socket: socket,
            status: status,
            destination: destination,
            port: port
        )
    }
    
    /// Create a new socket connection
    ///
    /// - Parameters:
    ///   - socket: Socket used for connection
    ///   - status: Status of socket connection attempt
    ///   - destination: Destination IP address for socket.
    ///   - port: Destination Port for socket.
    private init(socket: Socket, status: Status, destination: String, port: Int) {
        self.socket = socket
        self.status = status
        self.destination = destination
        self.port = port
    }
    
    deinit {
        socket.close()
    }
}

extension SocketConnection {
    
    /// Write a string to the socket.
    ///
    /// - Parameter string: The string to write
    /// - Returns: Integer representing the number of bytes written.
    /// - Throws: Error passed from `Socket.write(from:)`
    @discardableResult
    public func write(from string: String) throws -> Int {
        return try socket.write(from: string)
    }
    
    /// Read data from the socket.
    ///
    /// - Parameter data: The buffer to return the data in.
    /// - Returns: The number of bytes returned to the buffer.
    /// - Throws: Error passed from `Socket.read(into:)`
    @discardableResult
    public func read(into data: inout Data) throws -> Int {
        return try socket.read(into: &data)
    }
    
}

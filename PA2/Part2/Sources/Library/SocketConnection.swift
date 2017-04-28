//
//  SocketConnection.swift
//  Assignment2
//
//  Created by Chris Martin on 4/27/17.
//
//

import Foundation
import Socket

class SocketConnection {
    enum Status {
        case open
        case closed
    }
    
    var socket: Socket
    var status: Status
    var destination: String
    var port: Int
    
    convenience init(destination: String, port: Int) {
        let socket = try! Socket.create(family: .inet, type: .stream, proto: .tcp)
        var status: SocketConnection.Status = .open
        
        do {
            try socket.connect(to: destination, port: Int32(port))
        } catch let error as Socket.Error {
            // Check for connection refused
            if error.errorCode == -9989 {
                print("Connection for port \(port) cannot be established because item at port is private.")
                status = .closed
            } else {
                print("Socket for port \(port) failed to bind.")
            }
        } catch {
            print("There was an unknown error with the communicator construction. (0)")
        }
        
        self.init(
            socket: socket,
            status: status,
            destination: destination,
            port: port
        )
    }
    
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

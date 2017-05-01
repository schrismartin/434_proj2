//
//  FileManager.swift
//  Assignment2
//
//  Created by Chris Martin on 4/30/17.
//
//

import Foundation

class FileHandler {
    
    private var fileManager = FileManager.default
    
    private var openUrl: URL
    
    init(path: String) {
        let currentDirectory = URL(string: fileManager.currentDirectoryPath)!
        let file = currentDirectory.appendingPathComponent(path)
        
        openUrl = file
    }
    
    @discardableResult
    func writeToFile(data: Data) -> Bool {
        do {
            let handle = try getFileHandleForWriting(at: openUrl)
            eraseContents(using: handle)
            handle.write(data)
            handle.closeFile()
            return true
        }
        catch {
            return false
        }
    }
    
    func readFromFile() -> Data? {
        do {
            let handle = try getFileHandleForReading(at: openUrl)
            return handle.readDataToEndOfFile()
        } catch {
            return nil
        }
    }
    
    @discardableResult
    func appendToFile(data: Data) -> Bool {
        do {
            let data = (String(data: data, encoding: .utf8)! + "\n").data(using: .utf8)!
            let handle = try getFileHandleForWriting(at: openUrl)
            handle.seekToEndOfFile()
            handle.write(data)
            handle.closeFile()
            return true
        } catch {
            return false
        }
    }
    
    func readNodes() -> NodeCollection? {
        guard let data = readFromFile() else { return nil }
        let string = String(data: data, encoding: .utf8)!
        
        var portList = [Int: Set<Int>]()
        let collection = NodeCollection()
        
        let lines = string.components(separatedBy: "\n")
        for line in lines where line != "" {
            var components = line.components(separatedBy: ", ")
            guard let portString = components.popFirst(), let port = Int(portString) else { assert(false) }
            guard let id = components.popFirst() else { assert(false) }
            let node = NodeManager.shared.getNode(for: Node.defaultAddress, port: port, id: id)
            collection.register(node: node)
            
            // reconstruct the array literal
            var arrayString = components.joined(separator: ", ")
            let frontIndex = arrayString.index(after: arrayString.startIndex)
            let backIndex = arrayString.index(before: arrayString.endIndex)
            arrayString = arrayString[frontIndex ..< backIndex]
            let sequence = arrayString.components(separatedBy: ", ")
            let ports = Set<Int>(sequence.flatMap { Int($0) })
            
            portList[port] = ports
        }
        
        for (port, ports) in portList {
            for peer in ports {
                NodeManager.shared.registerPeers(for: port, with: peer)
            }
        }
        
        print("Successfully imported \(collection.nodes.count) nodes from \(openUrl.relativePath)")
        
        return collection
    }
    
    @discardableResult
    public func eraseContents() -> Bool {
        do {
            let handle = try getFileHandleForWriting(at: openUrl)
            eraseContents(using: handle)
            handle.closeFile()
            return true
        } catch {
            return false
        }
    }
    
    private func eraseContents(using handle: FileHandle) {
        handle.truncateFile(atOffset: 0)
    }
    
    private func getFileHandleForReading(at url: URL) throws -> FileHandle {
        return try FileHandle(forReadingFrom: url)
    }
    
    private func getFileHandleForWriting(at url: URL) throws -> FileHandle {
        if fileManager.fileExists(atPath: url.absoluteString) {
            return try FileHandle(forWritingTo: url)
        } else {
            fileManager.createFile(atPath: url.absoluteString, contents: nil)
            return try FileHandle(forWritingTo: url)
        }
    }
    
}

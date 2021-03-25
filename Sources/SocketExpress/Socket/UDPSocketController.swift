//
//  UDPSocketController.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation
import os

enum UDPSocketControllerState {
    case ready
    case active
    case closed
    
    var isReady: Bool {
        self == .ready
    }
    
    var isActive: Bool {
        self == .active
    }
    
    var isClosed: Bool {
        self == .closed
    }
}

class UDPSocketController: UDPSocketControllerProtocol {
    private(set) var state: UDPSocketControllerState = .ready
    
    weak var delegate: UDPSocketControllerDelegate?
    
    private let socket: UDPSocketProtocol
    
    private let host: String
    private let port: UInt
    
    private let callbackQueue: OperationQueue
    private let socketListeningQueue = DispatchQueue(label: "com.roku.socket-express.listening.queue",  attributes: .concurrent)
    private let socketWriterQueue = DispatchQueue(label: "com.roku.socket-express..writer.queue",  attributes: .concurrent)
    
    init?(host: String,
          port: UInt,
          socketFactory: SocketFactoryProtocol,
          callbackQueue: OperationQueue) {
        guard let socket = socketFactory.createUDPSocket() else {
             return nil
         }
        
        self.host = host
        self.port = port
        self.socket = socket
        self.callbackQueue = callbackQueue
    }
    
    func write(message: String) {
        guard !state.isClosed else {
//            os_log(.info, "Attempting to write to a closed socket")
            return
        }
        
        let shouldStartListening = state.isReady
        state = .active
        
        if shouldStartListening {
            startListening(on: socketListeningQueue)
        }
        
        write(message: message, on: socketWriterQueue)
    }
    
    private func write(message: String, on queue: DispatchQueue) {
        queue.async {
            do {
                try self.socket.write(message, to: self.host, on: self.port)
            } catch {
                self.closeAndReportError(error)
            }
        }
    }
    
    // MARK: - Listen
    
    private func startListening(on queue: DispatchQueue) {
        queue.async {
            do {
                repeat {
                    var data = Data()
                    try self.socket.readDatagram(into: &data) //blocking call
                    self.reportResponseReceived(data)
                } while self.state.isActive
            } catch {
                if self.state.isActive { // ignore any errors for non-active sockets
                    self.closeAndReportError(error)
                }
            }
        }
    }
    
    private func reportResponseReceived(_ data: Data) {
        callbackQueue.addOperation {
           self.delegate?.controller(self, didReceiveResponse: data)
        }
    }
    
    // MARK: - Close
    
    private func closeAndReportError(_ error: Error) {
        close()
        callbackQueue.addOperation {
            self.delegate?.controller(self, didEncounterError: error)
        }
    }
    
    func close() {
        state = .closed
        socket.close()
    }
}

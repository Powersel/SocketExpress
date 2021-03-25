//
//  Socket+UDPSocketProtocol.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation
import Socket

extension Socket: UDPSocketProtocol {
    func write(_ string: String, to host: String, on port: UInt) throws {
        guard let signature = self.signature, signature.socketType == .datagram, signature.proto == .udp else {
            fatalError("Only UDP sockets can use this method")
        }
        
        guard let address = Socket.createAddress(for: host, on: Int32(port)) else {
            throw(UDPSocketError.addressCreationFailure)
        }
        do {
            try write(from: string, to: address)
        } catch {
            throw(UDPSocketError.writeError(underlayingError: error))
        }
    }
    
    func readDatagram(into data: inout Data) throws {
        guard let signature = self.signature, signature.socketType == .datagram, signature.proto == .udp else {
            fatalError("Only UDP sockets can use this method")
        }
        
        do {
            let (_,_) = try readDatagram(into: &data)
        } catch {
            throw(UDPSocketError.readError(underlayingError: error))
        }
    }
}

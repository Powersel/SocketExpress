//
//  UDPSocketProtocol.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation
import Socket

protocol UDPSocketProtocol {
    func write(_ string: String, to host: String, on port: UInt) throws
    func readDatagram(into data: inout Data) throws
    func close()
}

extension UDPSocketProtocol {
    static func createUDPSocket() throws -> UDPSocketProtocol {
        return try Socket.create(type: .datagram, proto: .udp)
    }
}

//
//  SocketFactory.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation
import Socket

protocol SocketFactoryProtocol {
    func createUDPSocket() -> UDPSocketProtocol?
}

class SocketFactory: SocketFactoryProtocol {
    func createUDPSocket() -> UDPSocketProtocol? {
        guard let socket = try? Socket.createUDPSocket() else {
            return nil
        }
        
        return socket
    }
}

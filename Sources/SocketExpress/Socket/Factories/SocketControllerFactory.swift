//
//  SocketControllerFactory.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

protocol SocketControllerFactoryProtocol {
    func createUDPSocketController(host: String,
                                   port: UInt,
                                   socketFactory: SocketFactoryProtocol,
                                   callbackQueue: OperationQueue) -> UDPSocketControllerProtocol?
}

final class SocketControllerFactory: SocketControllerFactoryProtocol {
    func createUDPSocketController(host: String,
                                   port: UInt,
                                   socketFactory: SocketFactoryProtocol,
                                   callbackQueue: OperationQueue) -> UDPSocketControllerProtocol? {
        UDPSocketController(host: host,
                            port: port,
                            socketFactory: socketFactory,
                            callbackQueue: callbackQueue)
    }
}

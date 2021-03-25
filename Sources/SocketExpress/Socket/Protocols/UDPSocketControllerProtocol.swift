//
//  UDPSocketControllerProtocol.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

protocol UDPSocketControllerProtocol: class {
    var state: UDPSocketControllerState { get }
    var delegate: UDPSocketControllerDelegate? { get set }
    
    func write(message: String)
    func close()
}

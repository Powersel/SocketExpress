//
//  UDPSocketControllerDelegate.swift
//  SocketExpress
//
//  Created by Sergiy Shevchuk on 25.03.2021.
//

import Foundation

protocol UDPSocketControllerDelegate: class {
    func controller(_ controller: UDPSocketControllerProtocol,
                    didReceiveResponse response: Data)
    func controller(_ controller: UDPSocketControllerProtocol,
                    didEncounterError error: Error)
}
